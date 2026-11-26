.class public final Lcom/oplus/camera/util/DadaJpegSaver;
.super Ljava/lang/Object;
.source "DadaJpegSaver.java"


# static fields
.field private static final MIN_BYTES:I = 0x493e0

.field private static final TAG:Ljava/lang/String; = "DadaJpegSaver"

.field private static volatile sLastTimestamp:J


# direct methods
.method static constructor <clinit>()V
    .registers 2

    .line 34
    const-wide/16 v0, -0x1

    sput-wide v0, Lcom/oplus/camera/util/DadaJpegSaver;->sLastTimestamp:J

    return-void
.end method

.method private constructor <init>()V
    .registers 1

    .line 36
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 37
    return-void
.end method

.method static purgeAppPendingRows(Landroid/content/ContentResolver;Ljava/lang/String;)V
    .registers 11

    .line 163
    const-string v0, "purge("

    const-string v1, "DadaJpegSaver"

    .line 164
    nop

    .line 166
    const/4 v2, 0x0

    :try_start_6
    new-instance v3, Landroid/os/Bundle;

    invoke-direct {v3}, Landroid/os/Bundle;-><init>()V

    .line 167
    const-string v4, "android:query-arg-match-pending"

    const/4 v5, 0x3

    invoke-virtual {v3, v4, v5}, Landroid/os/Bundle;->putInt(Ljava/lang/String;I)V

    .line 168
    const-string v4, "android:query-arg-sql-selection"

    const-string v5, "relative_path=? AND _display_name LIKE \'IMG2%\' AND (_size IS NULL OR _size=0)"

    invoke-virtual {v3, v4, v5}, Landroid/os/Bundle;->putString(Ljava/lang/String;Ljava/lang/String;)V

    .line 170
    const-string v4, "android:query-arg-sql-selection-args"

    const-string v5, "DCIM/Camera/"

    filled-new-array {v5}, [Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v3, v4, v5}, Landroid/os/Bundle;->putStringArray(Ljava/lang/String;[Ljava/lang/String;)V

    .line 171
    sget-object v4, Landroid/provider/MediaStore$Images$Media;->EXTERNAL_CONTENT_URI:Landroid/net/Uri;

    const-string v5, "_id"

    filled-new-array {v5}, [Ljava/lang/String;

    move-result-object v5

    invoke-virtual {p0, v4, v5, v3, v2}, Landroid/content/ContentResolver;->query(Landroid/net/Uri;[Ljava/lang/String;Landroid/os/Bundle;Landroid/os/CancellationSignal;)Landroid/database/Cursor;

    move-result-object v3
    :try_end_2f
    .catchall {:try_start_6 .. :try_end_2f} :catchall_78

    .line 172
    const/4 v4, 0x0

    if-eqz v3, :cond_4e

    move v5, v4

    .line 173
    :goto_33
    :try_start_33
    invoke-interface {v3}, Landroid/database/Cursor;->moveToNext()Z

    move-result v6

    if-eqz v6, :cond_49

    .line 174
    sget-object v6, Landroid/provider/MediaStore$Images$Media;->EXTERNAL_CONTENT_URI:Landroid/net/Uri;

    invoke-interface {v3, v4}, Landroid/database/Cursor;->getLong(I)J

    move-result-wide v7

    invoke-static {v6, v7, v8}, Landroid/content/ContentUris;->withAppendedId(Landroid/net/Uri;J)Landroid/net/Uri;

    move-result-object v6

    .line 175
    invoke-virtual {p0, v6, v2, v2}, Landroid/content/ContentResolver;->delete(Landroid/net/Uri;Ljava/lang/String;[Ljava/lang/String;)I

    move-result v6

    add-int/2addr v5, v6

    .line 176
    goto :goto_33

    .line 173
    :cond_49
    move v4, v5

    goto :goto_4e

    .line 179
    :catchall_4b
    move-exception p0

    move-object v2, v3

    goto :goto_79

    .line 178
    :cond_4e
    :goto_4e
    new-instance p0, Ljava/lang/StringBuilder;

    invoke-direct {p0}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {p0, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-virtual {p0, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    const-string v2, "): deleted "

    invoke-virtual {p0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-virtual {p0, v4}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object p0

    const-string v2, " abandoned pending row(s)"

    invoke-virtual {p0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-virtual {p0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    invoke-static {v1, p0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_72
    .catchall {:try_start_33 .. :try_end_72} :catchall_4b

    .line 182
    if-eqz v3, :cond_98

    .line 183
    invoke-interface {v3}, Landroid/database/Cursor;->close()V

    goto :goto_98

    .line 179
    :catchall_78
    move-exception p0

    .line 180
    :goto_79
    :try_start_79
    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v3, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    const-string v0, ") failed"

    invoke-virtual {p1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-static {v1, p1, p0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I
    :try_end_93
    .catchall {:try_start_79 .. :try_end_93} :catchall_99

    .line 182
    if-eqz v2, :cond_98

    .line 183
    invoke-interface {v2}, Landroid/database/Cursor;->close()V

    .line 186
    :cond_98
    :goto_98
    return-void

    .line 182
    :catchall_99
    move-exception p0

    if-eqz v2, :cond_9f

    .line 183
    invoke-interface {v2}, Landroid/database/Cursor;->close()V

    .line 185
    :cond_9f
    throw p0
.end method

.method private static readLastZoomRatio()F
    .registers 2

    .line 190
    :try_start_0
    const-string v0, "com.oplus.ocs.camera.common.util.Util"

    invoke-static {v0}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;

    move-result-object v0

    .line 191
    const-string v1, "sDadaLastZoomRatio"

    invoke-virtual {v0, v1}, Ljava/lang/Class;->getField(Ljava/lang/String;)Ljava/lang/reflect/Field;

    move-result-object v0

    const/4 v1, 0x0

    invoke-virtual {v0, v1}, Ljava/lang/reflect/Field;->getFloat(Ljava/lang/Object;)F

    move-result v0
    :try_end_11
    .catchall {:try_start_0 .. :try_end_11} :catchall_12

    return v0

    .line 192
    :catchall_12
    move-exception v0

    .line 193
    const/high16 v0, 0x3f800000    # 1.0f

    return v0
.end method

.method public static save(Landroid/content/Context;[BIJ)V
    .registers 15

    .line 40
    if-eqz p0, :cond_223

    if-eqz p1, :cond_223

    array-length v0, p1

    const v1, 0x493e0

    if-ge v0, v1, :cond_c

    goto/16 :goto_223

    .line 44
    :cond_c
    const-class v0, Lcom/oplus/camera/util/DadaJpegSaver;

    monitor-enter v0

    .line 45
    :try_start_f
    sget-wide v1, Lcom/oplus/camera/util/DadaJpegSaver;->sLastTimestamp:J

    cmp-long v1, p3, v1

    if-nez v1, :cond_2f

    .line 46
    const-string p0, "DadaJpegSaver"

    new-instance p1, Ljava/lang/StringBuilder;

    invoke-direct {p1}, Ljava/lang/StringBuilder;-><init>()V

    const-string p2, "save: duplicate timestamp "

    invoke-virtual {p1, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1, p3, p4}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-static {p0, p1}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 47
    monitor-exit v0

    return-void

    .line 49
    :cond_2f
    sput-wide p3, Lcom/oplus/camera/util/DadaJpegSaver;->sLastTimestamp:J

    .line 50
    monitor-exit v0
    :try_end_32
    .catchall {:try_start_f .. :try_end_32} :catchall_220

    .line 52
    nop

    .line 53
    nop

    .line 55
    const/4 p3, 0x0

    :try_start_35
    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J

    move-result-wide v0

    .line 56
    new-instance p4, Ljava/io/File;

    invoke-virtual {p0}, Landroid/content/Context;->getCacheDir()Ljava/io/File;

    move-result-object v2

    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "dada_"

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3, v0, v1}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    move-result-object v3

    const-string v4, ".jpg"

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-direct {p4, v2, v3}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V
    :try_end_5b
    .catchall {:try_start_35 .. :try_end_5b} :catchall_1fe

    .line 57
    :try_start_5b
    new-instance v2, Ljava/io/FileOutputStream;

    invoke-direct {v2, p4}, Ljava/io/FileOutputStream;-><init>(Ljava/io/File;)V

    .line 58
    invoke-virtual {v2, p1}, Ljava/io/FileOutputStream;->write([B)V

    .line 59
    invoke-virtual {v2}, Ljava/io/FileOutputStream;->flush()V

    .line 60
    invoke-virtual {v2}, Ljava/io/FileOutputStream;->close()V
    :try_end_69
    .catchall {:try_start_5b .. :try_end_69} :catchall_1fb

    .line 63
    const/4 v2, 0x0

    const/4 v3, 0x1

    :try_start_6b
    new-instance v4, Landroid/media/ExifInterface;

    invoke-virtual {p4}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;

    move-result-object v5

    invoke-direct {v4, v5}, Landroid/media/ExifInterface;-><init>(Ljava/lang/String;)V

    .line 64
    new-instance v5, Ljava/text/SimpleDateFormat;

    const-string v6, "yyyy:MM:dd HH:mm:ss"

    sget-object v7, Ljava/util/Locale;->US:Ljava/util/Locale;

    invoke-direct {v5, v6, v7}, Ljava/text/SimpleDateFormat;-><init>(Ljava/lang/String;Ljava/util/Locale;)V

    new-instance v6, Ljava/util/Date;

    invoke-direct {v6, v0, v1}, Ljava/util/Date;-><init>(J)V

    invoke-virtual {v5, v6}, Ljava/text/SimpleDateFormat;->format(Ljava/util/Date;)Ljava/lang/String;

    move-result-object v5

    .line 65
    const-string v6, "Orientation"

    invoke-static {p2}, Lcom/oplus/camera/util/DadaJpegSaver;->toExifOrientation(I)I

    move-result p2

    invoke-static {p2}, Ljava/lang/String;->valueOf(I)Ljava/lang/String;

    move-result-object p2

    invoke-virtual {v4, v6, p2}, Landroid/media/ExifInterface;->setAttribute(Ljava/lang/String;Ljava/lang/String;)V

    .line 66
    const-string p2, "Make"

    const-string v6, "Xiaomi"

    invoke-virtual {v4, p2, v6}, Landroid/media/ExifInterface;->setAttribute(Ljava/lang/String;Ljava/lang/String;)V

    .line 67
    const-string p2, "Model"

    const-string v6, "Xiaomi 15"

    invoke-virtual {v4, p2, v6}, Landroid/media/ExifInterface;->setAttribute(Ljava/lang/String;Ljava/lang/String;)V

    .line 68
    const-string p2, "DateTime"

    invoke-virtual {v4, p2, v5}, Landroid/media/ExifInterface;->setAttribute(Ljava/lang/String;Ljava/lang/String;)V

    .line 69
    const-string p2, "DateTimeOriginal"

    invoke-virtual {v4, p2, v5}, Landroid/media/ExifInterface;->setAttribute(Ljava/lang/String;Ljava/lang/String;)V

    .line 70
    new-instance p2, Landroid/graphics/BitmapFactory$Options;

    invoke-direct {p2}, Landroid/graphics/BitmapFactory$Options;-><init>()V

    .line 71
    iput-boolean v3, p2, Landroid/graphics/BitmapFactory$Options;->inJustDecodeBounds:Z

    .line 72
    array-length v5, p1

    invoke-static {p1, v2, v5, p2}, Landroid/graphics/BitmapFactory;->decodeByteArray([BIILandroid/graphics/BitmapFactory$Options;)Landroid/graphics/Bitmap;

    .line 73
    iget p1, p2, Landroid/graphics/BitmapFactory$Options;->outWidth:I

    iget p2, p2, Landroid/graphics/BitmapFactory$Options;->outHeight:I

    invoke-static {p1, p2}, Ljava/lang/Math;->max(II)I

    move-result p1

    const/16 p2, 0xcc0

    if-ne p1, p2, :cond_c4

    move p1, v3

    goto :goto_c5

    :cond_c4
    move p1, v2

    .line 74
    :goto_c5
    if-eqz p1, :cond_d6

    .line 75
    const-string p1, "FocalLength"

    const-string p2, "283/100"

    invoke-virtual {v4, p1, p2}, Landroid/media/ExifInterface;->setAttribute(Ljava/lang/String;Ljava/lang/String;)V

    .line 76
    const-string p1, "FocalLengthIn35mmFilm"

    const-string p2, "21"

    invoke-virtual {v4, p1, p2}, Landroid/media/ExifInterface;->setAttribute(Ljava/lang/String;Ljava/lang/String;)V

    goto :goto_114

    .line 78
    :cond_d6
    invoke-static {}, Lcom/oplus/camera/util/DadaJpegSaver;->readLastZoomRatio()F

    move-result p1

    .line 79
    const p2, 0x3f733333    # 0.95f

    cmpg-float p2, p1, p2

    if-gez p2, :cond_f0

    .line 80
    const-string p1, "FocalLength"

    const-string p2, "216/100"

    invoke-virtual {v4, p1, p2}, Landroid/media/ExifInterface;->setAttribute(Ljava/lang/String;Ljava/lang/String;)V

    .line 81
    const-string p1, "FocalLengthIn35mmFilm"

    const-string p2, "14"

    invoke-virtual {v4, p1, p2}, Landroid/media/ExifInterface;->setAttribute(Ljava/lang/String;Ljava/lang/String;)V

    goto :goto_114

    .line 82
    :cond_f0
    const p2, 0x40233333    # 2.55f

    cmpl-float p1, p1, p2

    if-ltz p1, :cond_106

    .line 83
    const-string p1, "FocalLength"

    const-string p2, "900/100"

    invoke-virtual {v4, p1, p2}, Landroid/media/ExifInterface;->setAttribute(Ljava/lang/String;Ljava/lang/String;)V

    .line 84
    const-string p1, "FocalLengthIn35mmFilm"

    const-string p2, "60"

    invoke-virtual {v4, p1, p2}, Landroid/media/ExifInterface;->setAttribute(Ljava/lang/String;Ljava/lang/String;)V

    goto :goto_114

    .line 86
    :cond_106
    const-string p1, "FocalLength"

    const-string p2, "655/100"

    invoke-virtual {v4, p1, p2}, Landroid/media/ExifInterface;->setAttribute(Ljava/lang/String;Ljava/lang/String;)V

    .line 87
    const-string p1, "FocalLengthIn35mmFilm"

    const-string p2, "23"

    invoke-virtual {v4, p1, p2}, Landroid/media/ExifInterface;->setAttribute(Ljava/lang/String;Ljava/lang/String;)V

    .line 90
    :goto_114
    invoke-virtual {v4}, Landroid/media/ExifInterface;->saveAttributes()V
    :try_end_117
    .catchall {:try_start_6b .. :try_end_117} :catchall_118

    .line 93
    goto :goto_120

    .line 91
    :catchall_118
    move-exception p1

    .line 92
    :try_start_119
    const-string p2, "DadaJpegSaver"

    const-string v4, "save: exif failed"

    invoke-static {p2, v4, p1}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 95
    :goto_120
    new-instance p1, Ljava/lang/StringBuilder;

    invoke-direct {p1}, Ljava/lang/StringBuilder;-><init>()V

    const-string p2, "IMG_"

    invoke-virtual {p1, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1, v0, v1}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    move-result-object p1

    const-string p2, ".jpg"

    invoke-virtual {p1, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    .line 96
    new-instance p2, Landroid/content/ContentValues;

    invoke-direct {p2}, Landroid/content/ContentValues;-><init>()V

    .line 97
    const-string v4, "_display_name"

    invoke-virtual {p2, v4, p1}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/String;)V

    .line 98
    const-string v4, "mime_type"

    const-string v5, "image/jpeg"

    invoke-virtual {p2, v4, v5}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/String;)V

    .line 99
    const-string v4, "relative_path"

    const-string v5, "DCIM/Camera"

    invoke-virtual {p2, v4, v5}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/String;)V

    .line 100
    const-string v4, "datetaken"

    invoke-static {v0, v1}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object v0

    invoke-virtual {p2, v4, v0}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/Long;)V

    .line 101
    const-string v0, "is_pending"

    invoke-static {v3}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    invoke-virtual {p2, v0, v1}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/Integer;)V

    .line 103
    invoke-virtual {p0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object v0

    .line 104
    sget-object v1, Landroid/provider/MediaStore$Images$Media;->EXTERNAL_CONTENT_URI:Landroid/net/Uri;

    invoke-virtual {v0, v1, p2}, Landroid/content/ContentResolver;->insert(Landroid/net/Uri;Landroid/content/ContentValues;)Landroid/net/Uri;

    move-result-object p2
    :try_end_16d
    .catchall {:try_start_119 .. :try_end_16d} :catchall_1fb

    .line 105
    if-nez p2, :cond_17b

    .line 106
    :try_start_16f
    const-string p1, "DadaJpegSaver"

    const-string v0, "save: insert returned null"

    invoke-static {p1, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_176
    .catchall {:try_start_16f .. :try_end_176} :catchall_1f9

    .line 150
    nop

    .line 152
    invoke-virtual {p4}, Ljava/io/File;->delete()Z

    .line 107
    return-void

    .line 110
    :cond_17b
    :try_start_17b
    new-instance v1, Ljava/io/FileInputStream;

    invoke-direct {v1, p4}, Ljava/io/FileInputStream;-><init>(Ljava/io/File;)V

    .line 111
    invoke-virtual {v0, p2}, Landroid/content/ContentResolver;->openOutputStream(Landroid/net/Uri;)Ljava/io/OutputStream;

    move-result-object v4

    .line 112
    const/high16 v5, 0x10000

    new-array v5, v5, [B

    .line 113
    const-wide/16 v6, 0x0

    .line 115
    :goto_18a
    invoke-virtual {v1, v5}, Ljava/io/InputStream;->read([B)I

    move-result v8

    if-lez v8, :cond_196

    .line 116
    invoke-virtual {v4, v5, v2, v8}, Ljava/io/OutputStream;->write([BII)V

    .line 117
    int-to-long v8, v8

    add-long/2addr v6, v8

    goto :goto_18a

    .line 119
    :cond_196
    invoke-virtual {v1}, Ljava/io/InputStream;->close()V

    .line 120
    invoke-virtual {v4}, Ljava/io/OutputStream;->flush()V

    .line 121
    invoke-virtual {v4}, Ljava/io/OutputStream;->close()V

    .line 123
    new-instance v1, Landroid/content/ContentValues;

    invoke-direct {v1}, Landroid/content/ContentValues;-><init>()V

    .line 124
    const-string v4, "is_pending"

    invoke-static {v2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-virtual {v1, v4, v2}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/Integer;)V

    .line 125
    invoke-virtual {v0, p2, v1, p3, p3}, Landroid/content/ContentResolver;->update(Landroid/net/Uri;Landroid/content/ContentValues;Ljava/lang/String;[Ljava/lang/String;)I

    .line 126
    const-string v1, "DadaJpegSaver"

    invoke-static {p2}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v2

    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, "save: committed "

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, v6, v7}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    move-result-object v4

    const-string v5, " bytes to "

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    const-string v4, " name="

    invoke-virtual {v2, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-static {v1, p1}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 127
    const-string p1, "now"

    invoke-static {v0, p1}, Lcom/oplus/camera/util/DadaJpegSaver;->purgeAppPendingRows(Landroid/content/ContentResolver;Ljava/lang/String;)V

    .line 128
    nop

    .line 129
    new-instance p1, Ljava/lang/Thread;

    new-instance v1, Lcom/oplus/camera/util/DadaJpegSaver$1;

    invoke-direct {v1, v0}, Lcom/oplus/camera/util/DadaJpegSaver$1;-><init>(Landroid/content/ContentResolver;)V

    const-string v0, "DadaPendingPurge"

    invoke-direct {p1, v1, v0}, Ljava/lang/Thread;-><init>(Ljava/lang/Runnable;Ljava/lang/String;)V

    .line 139
    invoke-virtual {p1, v3}, Ljava/lang/Thread;->setDaemon(Z)V

    .line 140
    invoke-virtual {p1}, Ljava/lang/Thread;->start()V
    :try_end_1f8
    .catchall {:try_start_17b .. :try_end_1f8} :catchall_1f9

    .line 150
    goto :goto_215

    .line 141
    :catchall_1f9
    move-exception p1

    goto :goto_201

    :catchall_1fb
    move-exception p1

    move-object p2, p3

    goto :goto_201

    :catchall_1fe
    move-exception p1

    move-object p2, p3

    move-object p4, p2

    .line 142
    :goto_201
    :try_start_201
    const-string v0, "DadaJpegSaver"

    const-string v1, "save: failed"

    invoke-static {v0, v1, p1}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I
    :try_end_208
    .catchall {:try_start_201 .. :try_end_208} :catchall_219

    .line 143
    if-eqz p2, :cond_213

    .line 145
    :try_start_20a
    invoke-virtual {p0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object p0

    invoke-virtual {p0, p2, p3, p3}, Landroid/content/ContentResolver;->delete(Landroid/net/Uri;Ljava/lang/String;[Ljava/lang/String;)I
    :try_end_211
    .catchall {:try_start_20a .. :try_end_211} :catchall_212

    .line 147
    goto :goto_213

    .line 146
    :catchall_212
    move-exception p0

    .line 150
    :cond_213
    :goto_213
    if-eqz p4, :cond_218

    .line 152
    :goto_215
    invoke-virtual {p4}, Ljava/io/File;->delete()Z

    .line 155
    :cond_218
    return-void

    .line 150
    :catchall_219
    move-exception p0

    if-eqz p4, :cond_21f

    .line 152
    invoke-virtual {p4}, Ljava/io/File;->delete()Z

    .line 154
    :cond_21f
    throw p0

    .line 50
    :catchall_220
    move-exception p0

    :try_start_221
    monitor-exit v0
    :try_end_222
    .catchall {:try_start_221 .. :try_end_222} :catchall_220

    throw p0

    .line 41
    :cond_223
    :goto_223
    const-string p0, "DadaJpegSaver"

    if-nez p1, :cond_229

    const/4 p1, -0x1

    goto :goto_22a

    :cond_229
    array-length p1, p1

    :goto_22a
    new-instance p2, Ljava/lang/StringBuilder;

    invoke-direct {p2}, Ljava/lang/StringBuilder;-><init>()V

    const-string p3, "save: skipped, len="

    invoke-virtual {p2, p3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p2

    invoke-virtual {p2, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-static {p0, p1}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 42
    return-void
.end method

.method private static toExifOrientation(I)I
    .registers 2

    .line 198
    const/16 v0, 0x5a

    if-ne p0, v0, :cond_6

    .line 199
    const/4 p0, 0x6

    return p0

    .line 201
    :cond_6
    const/16 v0, 0xb4

    if-ne p0, v0, :cond_c

    .line 202
    const/4 p0, 0x3

    return p0

    .line 204
    :cond_c
    const/16 v0, 0x10e

    if-ne p0, v0, :cond_13

    .line 205
    const/16 p0, 0x8

    return p0

    .line 207
    :cond_13
    const/4 p0, 0x1

    return p0
.end method
