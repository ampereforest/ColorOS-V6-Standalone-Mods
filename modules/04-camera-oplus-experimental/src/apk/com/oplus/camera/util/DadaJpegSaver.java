package com.oplus.camera.util;

import android.content.ContentResolver;
import android.content.ContentUris;
import android.content.ContentValues;
import android.database.Cursor;
import android.graphics.BitmapFactory;
import android.os.Bundle;
import android.content.Context;
import android.media.ExifInterface;
import android.net.Uri;
import android.provider.MediaStore;
import android.util.Log;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

/**
 * dada: commits the JPEG delivered by the camera SDK on a non-OPPO HAL.
 *
 * The stock save chain (ThumbnailHelper -> ThumbnailCategory -> APS metadata) never
 * runs on this platform because no OPPO APS pipeline exists, so the MediaStore row is
 * created and abandoned. This helper writes the exact byte[] into DCIM/Camera itself.
 */
public final class DadaJpegSaver {
    private static final String TAG = "DadaJpegSaver";
    private static final int MIN_BYTES = 300000;
    private static volatile long sLastTimestamp = -1L;

    private DadaJpegSaver() {
    }

    public static void save(Context context, byte[] jpeg, int orientation, long timestamp) {
        if (context == null || jpeg == null || jpeg.length < MIN_BYTES) {
            Log.w(TAG, "save: skipped, len=" + (jpeg == null ? -1 : jpeg.length));
            return;
        }
        synchronized (DadaJpegSaver.class) {
            if (timestamp == sLastTimestamp) {
                Log.w(TAG, "save: duplicate timestamp " + timestamp);
                return;
            }
            sLastTimestamp = timestamp;
        }

        File tmp = null;
        Uri uri = null;
        try {
            long now = System.currentTimeMillis();
            tmp = new File(context.getCacheDir(), "dada_" + now + ".jpg");
            FileOutputStream fos = new FileOutputStream(tmp);
            fos.write(jpeg);
            fos.flush();
            fos.close();

            try {
                ExifInterface exif = new ExifInterface(tmp.getAbsolutePath());
                String when = new SimpleDateFormat("yyyy:MM:dd HH:mm:ss", Locale.US).format(new Date(now));
                exif.setAttribute(ExifInterface.TAG_ORIENTATION, String.valueOf(toExifOrientation(orientation)));
                exif.setAttribute(ExifInterface.TAG_MAKE, "Xiaomi");
                exif.setAttribute(ExifInterface.TAG_MODEL, "Xiaomi 15");
                exif.setAttribute(ExifInterface.TAG_DATETIME, when);
                exif.setAttribute(ExifInterface.TAG_DATETIME_ORIGINAL, when);
                BitmapFactory.Options bo = new BitmapFactory.Options();
                bo.inJustDecodeBounds = true;
                BitmapFactory.decodeByteArray(jpeg, 0, jpeg.length, bo);
                boolean front = Math.max(bo.outWidth, bo.outHeight) == 3264;
                if (front) {
                    exif.setAttribute(ExifInterface.TAG_FOCAL_LENGTH, "283/100");
                    exif.setAttribute(ExifInterface.TAG_FOCAL_LENGTH_IN_35MM_FILM, "21");
                } else {
                    float z = readLastZoomRatio();
                    if (z < 0.95f) {
                        exif.setAttribute(ExifInterface.TAG_FOCAL_LENGTH, "216/100");
                        exif.setAttribute(ExifInterface.TAG_FOCAL_LENGTH_IN_35MM_FILM, "14");
                    } else if (z >= 2.55f) {
                        exif.setAttribute(ExifInterface.TAG_FOCAL_LENGTH, "900/100");
                        exif.setAttribute(ExifInterface.TAG_FOCAL_LENGTH_IN_35MM_FILM, "60");
                    } else {
                        exif.setAttribute(ExifInterface.TAG_FOCAL_LENGTH, "655/100");
                        exif.setAttribute(ExifInterface.TAG_FOCAL_LENGTH_IN_35MM_FILM, "23");
                    }
                }
                exif.saveAttributes();
            } catch (Throwable t) {
                Log.w(TAG, "save: exif failed", t);
            }

            String name = "IMG_" + now + ".jpg";
            ContentValues cv = new ContentValues();
            cv.put("_display_name", name);
            cv.put("mime_type", "image/jpeg");
            cv.put("relative_path", "DCIM/Camera");
            cv.put("datetaken", Long.valueOf(now));
            cv.put("is_pending", Integer.valueOf(1));

            ContentResolver cr = context.getContentResolver();
            uri = cr.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, cv);
            if (uri == null) {
                Log.e(TAG, "save: insert returned null");
                return;
            }

            InputStream in = new FileInputStream(tmp);
            OutputStream out = cr.openOutputStream(uri);
            byte[] buf = new byte[65536];
            long total = 0L;
            int n;
            while ((n = in.read(buf)) > 0) {
                out.write(buf, 0, n);
                total += n;
            }
            in.close();
            out.flush();
            out.close();

            ContentValues done = new ContentValues();
            done.put("is_pending", Integer.valueOf(0));
            cr.update(uri, done, null, null);
            Log.e(TAG, "save: committed " + total + " bytes to " + uri + " name=" + name);
            purgeAppPendingRows(cr, "now");
            final ContentResolver fcr = cr;
            Thread t = new Thread(new Runnable() {
                @Override
                public void run() {
                    try {
                        Thread.sleep(1500L);
                    } catch (InterruptedException ignored) {
                    }
                    purgeAppPendingRows(fcr, "late");
                }
            }, "DadaPendingPurge");
            t.setDaemon(true);
            t.start();
        } catch (Throwable t) {
            Log.e(TAG, "save: failed", t);
            if (uri != null) {
                try {
                    context.getContentResolver().delete(uri, null, null);
                } catch (Throwable ignored) {
                }
            }
        } finally {
            if (tmp != null) {
                //noinspection ResultOfMethodCallIgnored
                tmp.delete();
            }
        }
    }

    /**
     * The stock save chain inserts its own "IMG<yyyyMMddHHmmss>.jpg" row with is_pending=1 and never
     * writes it on this HAL (no APS), leaving a 0-byte item in the gallery. Our rows are named
     * "IMG_<millis>.jpg", so only the abandoned stock rows match "IMG2%".
     */
    static void purgeAppPendingRows(ContentResolver cr, String tag) {
        Cursor c = null;
        int deleted = 0;
        try {
            Bundle q = new Bundle();
            q.putInt(MediaStore.QUERY_ARG_MATCH_PENDING, MediaStore.MATCH_ONLY);
            q.putString(ContentResolver.QUERY_ARG_SQL_SELECTION,
                    "relative_path=? AND _display_name LIKE 'IMG2%' AND (_size IS NULL OR _size=0)");
            q.putStringArray(ContentResolver.QUERY_ARG_SQL_SELECTION_ARGS, new String[]{"DCIM/Camera/"});
            c = cr.query(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, new String[]{"_id"}, q, null);
            if (c != null) {
                while (c.moveToNext()) {
                    Uri u = ContentUris.withAppendedId(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, c.getLong(0));
                    deleted += cr.delete(u, null, null);
                }
            }
            Log.w(TAG, "purge(" + tag + "): deleted " + deleted + " abandoned pending row(s)");
        } catch (Throwable t) {
            Log.w(TAG, "purge(" + tag + ") failed", t);
        } finally {
            if (c != null) {
                c.close();
            }
        }
    }

    private static float readLastZoomRatio() {
        try {
            Class<?> c = Class.forName("com.oplus.ocs.camera.common.util.Util");
            return c.getField("sDadaLastZoomRatio").getFloat(null);
        } catch (Throwable t) {
            return 1.0f;
        }
    }

    private static int toExifOrientation(int degrees) {
        if (degrees == 90) {
            return 6;
        }
        if (degrees == 180) {
            return 3;
        }
        if (degrees == 270) {
            return 8;
        }
        return 1;
    }
}
