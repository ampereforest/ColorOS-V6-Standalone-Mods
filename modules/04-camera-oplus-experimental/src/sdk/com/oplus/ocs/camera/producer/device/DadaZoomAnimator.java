package com.oplus.ocs.camera.producer.device;

import android.os.Handler;
import android.os.Looper;
import android.os.SystemClock;
import android.util.Log;

/**
 * Smooth 90Hz drift-free perceptual log-space CONTROL_ZOOM_RATIO interpolator for Xiaomi 15 (dada)
 * CamX SAT logical camera 0 in both Photo (30fps) and Video (30/60fps) modes.
 * Runs strictly on CameraUnitControl's existing Looper — zero extra threads, zero polling loops.
 */
public final class DadaZoomAnimator {
    private static final String TAG = "DadaZoomAnim";
    private static final long FRAME_MS = 11L; // ~90Hz drift-free absolute-clock pacing

    private static Handler sAnimHandler;
    private static Runnable sPendingStep;
    private static volatile boolean sAnimating = false;
    private static float sStartRatio = 1.0f;
    private static float sCurrentRatio = 1.0f;
    private static float sTargetRatio = 1.0f;
    private static long sStartTimeMs = 0L;
    private static long sDurationMs = 240L;
    private static long sNextTickMs = 0L;
    private static long sLastRequestMs = 0L;
    private static Camera2Impl sActiveCam = null;
    private static Handler sCallbackHandler = null;
    private static int sStepCount = 0;

    private DadaZoomAnimator() {}

    public static boolean isAnimating() {
        return sAnimating;
    }

    public static void cancel() {
        if (sAnimHandler != null && sPendingStep != null) {
            sAnimHandler.removeCallbacks(sPendingStep);
        }
        sPendingStep = null;
        sAnimating = false;
        sActiveCam = null;
        sCallbackHandler = null;
    }

    public static void reset() {
        cancel();
        sStartRatio = 1.0f;
        sCurrentRatio = 1.0f;
        sTargetRatio = 1.0f;
        sLastRequestMs = 0L;
    }

    public static float onStillCaptureZoom(float rawTarget) {
        if (sAnimating) {
            float finalTarget = (rawTarget > 0.0f) ? rawTarget : sTargetRatio;
            cancel();
            sCurrentRatio = finalTarget;
            sTargetRatio = finalTarget;
            return finalTarget;
        }
        return rawTarget;
    }

    public static float onPreviewZoomRequest(Camera2Impl cam, float rawTarget, Handler cbHandler) {
        if (cam == null || !cam.dadaCanAnimateZoom()) {
            cancel();
            if (rawTarget > 0.0f) {
                sCurrentRatio = rawTarget;
                sTargetRatio = rawTarget;
            }
            return rawTarget;
        }

        float target = rawTarget;
        if (target < 0.6f) target = 0.6f;
        if (target > 10.0f) target = 10.0f;

        long now = SystemClock.uptimeMillis();
        long dtReq = now - sLastRequestMs;
        sLastRequestMs = now;

        // If already animating toward this same target (e.g. AE/AF startPreview refresh), keep running!
        if (sAnimating && sActiveCam == cam && Math.abs(target - sTargetRatio) < 0.002f) {
            return sCurrentRatio;
        }

        float cur = sCurrentRatio;
        if (cur < 0.6f || cur > 10.0f) {
            cur = 1.0f;
        }
        float diff = Math.abs(target - cur);

        // Tiny delta or continuous finger drag stream: apply immediately (zero scrub lag)
        if (diff < 0.015f || (diff < 0.08f && dtReq <= 60L)) {
            cancel();
            sCurrentRatio = target;
            sTargetRatio = target;
            return target;
        }

        Looper looper = Looper.myLooper();
        if (looper == null) {
            cancel();
            sCurrentRatio = target;
            sTargetRatio = target;
            return target;
        }

        // Start / smoothly retarget 90Hz drift-free log-space S-curve animation
        if (sAnimHandler == null || sAnimHandler.getLooper() != looper) {
            cancel();
            sAnimHandler = new Handler(looper);
        } else if (sPendingStep != null) {
            sAnimHandler.removeCallbacks(sPendingStep);
            sPendingStep = null;
        }

        // Tune duration to Xiaomi CamX SAT optical handoff timings so lens switches complete mid-glide
        boolean upToTele = (cur < 2.25f && target >= 2.50f);
        boolean downFromTele = (cur >= 2.50f && target < 2.25f);
        boolean crossUw = (cur < 0.95f && target >= 0.95f) || (cur >= 0.95f && target < 0.95f);

        long dur;
        if (upToTele) {
            // Tele pre-warm (W+NA -> W+T -> T+W) takes ~235-260ms; glide across 340ms so swap lands mid-motion
            dur = (diff >= 1.2f) ? 360L : 340L;
        } else if (crossUw) {
            dur = 300L;
        } else if (downFromTele) {
            dur = (diff >= 1.2f) ? 300L : 280L;
        } else if (diff >= 0.30f) {
            dur = 240L;
        } else {
            dur = 130L;
        }

        sActiveCam = cam;
        sCallbackHandler = cbHandler;
        sStartRatio = cur;
        sTargetRatio = target;
        sDurationMs = dur;
        // Advance start clock by 1 tick so Step 1 (now) and Step 2 (now + FRAME_MS) are strictly monotonic (zero Frame 1-2 stall)
        sStartTimeMs = now - FRAME_MS;
        sNextTickMs = now + FRAME_MS;
        sAnimating = true;
        sStepCount = 1;

        float t0 = (float) FRAME_MS / (float) dur;
        if (upToTele && cur >= 1.90f && t0 < 0.14f) {
            // Kick across ~2.09x on frame 1 so CamX immediately starts Tele pre-warm without delay
            t0 = 0.14f;
            sStartTimeMs = now - (long) (t0 * dur);
        }
        float firstRatio = interpSmoothLog(cur, target, t0);
        sCurrentRatio = firstRatio;

        Log.i(TAG, "start " + round3(cur) + " -> " + round3(target) + " dur=" + dur + "ms step1=" + round3(firstRatio));

        final Runnable stepRunnable = new Runnable() {
            @Override
            public void run() {
                if (!sAnimating || sActiveCam == null) {
                    return;
                }
                long nowMs = SystemClock.uptimeMillis();
                long elapsed = nowMs - sStartTimeMs;
                if (elapsed >= sDurationMs) {
                    float finalVal = sTargetRatio;
                    Camera2Impl targetCam = sActiveCam;
                    Handler targetCb = sCallbackHandler;
                    int steps = sStepCount + 1;
                    sCurrentRatio = finalVal;
                    sAnimating = false;
                    sPendingStep = null;
                    targetCam.dadaApplyAnimatedZoom(finalVal, targetCb);
                    Log.i(TAG, "done target=" + round3(finalVal) + " steps=" + steps);
                    return;
                }
                float t = (float) elapsed / (float) sDurationMs;
                if (t < 0.0f) t = 0.0f;
                if (t > 1.0f) t = 1.0f;
                float val = interpSmoothLog(sStartRatio, sTargetRatio, t);
                sCurrentRatio = val;
                sStepCount++;
                if (!sActiveCam.dadaApplyAnimatedZoom(val, sCallbackHandler)) {
                    cancel();
                    return;
                }
                if (sAnimHandler != null && sAnimating) {
                    sNextTickMs += FRAME_MS;
                    if (sNextTickMs <= nowMs) {
                        sNextTickMs = nowMs + FRAME_MS;
                    }
                    sAnimHandler.postAtTime(this, sNextTickMs);
                }
            }
        };
        sPendingStep = stepRunnable;
        sAnimHandler.postAtTime(stepRunnable, sNextTickMs);
        return firstRatio;
    }

    private static float interpSmoothLog(float start, float end, float t) {
        // Blended cosine S-curve (55%) + gentle quad ease-out (45%):
        // responsive launch (slope 0.90), smooth continuous mid-glide, silky cushioned stop (slope 0.0)
        double sCurve = 0.5 * (1.0 - Math.cos(Math.PI * (double) t));
        double inv = 1.0 - (double) t;
        double quadOut = 1.0 - inv * inv;
        double eased = 0.55 * sCurve + 0.45 * quadOut;
        double ratio = (double) start * Math.pow((double) end / (double) start, eased);
        float out = (float) ratio;
        if (out < 0.6f) out = 0.6f;
        if (out > 10.0f) out = 10.0f;
        return out;
    }

    private static float round3(float v) {
        return Math.round(v * 1000.0f) / 1000.0f;
    }
}
