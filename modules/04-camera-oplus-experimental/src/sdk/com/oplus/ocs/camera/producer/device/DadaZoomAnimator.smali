.class public final Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;
.super Ljava/lang/Object;
.source "DadaZoomAnimator.java"


# static fields
.field private static final FRAME_MS:J = 0xbL

.field private static final TAG:Ljava/lang/String; = "DadaZoomAnim"

.field private static sActiveCam:Lcom/oplus/ocs/camera/producer/device/Camera2Impl;

.field private static sAnimHandler:Landroid/os/Handler;

.field private static volatile sAnimating:Z

.field private static sCallbackHandler:Landroid/os/Handler;

.field private static sCurrentRatio:F

.field private static sDurationMs:J

.field private static sLastRequestMs:J

.field private static sNextTickMs:J

.field private static sPendingStep:Ljava/lang/Runnable;

.field private static sStartRatio:F

.field private static sStartTimeMs:J

.field private static sStepCount:I

.field private static sTargetRatio:F


# direct methods
.method static bridge synthetic -$$Nest$sfgetsActiveCam()Lcom/oplus/ocs/camera/producer/device/Camera2Impl;
    .registers 1

    sget-object v0, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sActiveCam:Lcom/oplus/ocs/camera/producer/device/Camera2Impl;

    return-object v0
.end method

.method static bridge synthetic -$$Nest$sfgetsAnimHandler()Landroid/os/Handler;
    .registers 1

    sget-object v0, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sAnimHandler:Landroid/os/Handler;

    return-object v0
.end method

.method static bridge synthetic -$$Nest$sfgetsAnimating()Z
    .registers 1

    sget-boolean v0, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sAnimating:Z

    return v0
.end method

.method static bridge synthetic -$$Nest$sfgetsCallbackHandler()Landroid/os/Handler;
    .registers 1

    sget-object v0, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sCallbackHandler:Landroid/os/Handler;

    return-object v0
.end method

.method static bridge synthetic -$$Nest$sfgetsDurationMs()J
    .registers 2

    sget-wide v0, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sDurationMs:J

    return-wide v0
.end method

.method static bridge synthetic -$$Nest$sfgetsNextTickMs()J
    .registers 2

    sget-wide v0, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sNextTickMs:J

    return-wide v0
.end method

.method static bridge synthetic -$$Nest$sfgetsStartRatio()F
    .registers 1

    sget v0, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sStartRatio:F

    return v0
.end method

.method static bridge synthetic -$$Nest$sfgetsStartTimeMs()J
    .registers 2

    sget-wide v0, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sStartTimeMs:J

    return-wide v0
.end method

.method static bridge synthetic -$$Nest$sfgetsStepCount()I
    .registers 1

    sget v0, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sStepCount:I

    return v0
.end method

.method static bridge synthetic -$$Nest$sfgetsTargetRatio()F
    .registers 1

    sget v0, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sTargetRatio:F

    return v0
.end method

.method static bridge synthetic -$$Nest$sfputsAnimating(Z)V
    .registers 1

    sput-boolean p0, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sAnimating:Z

    return-void
.end method

.method static bridge synthetic -$$Nest$sfputsCurrentRatio(F)V
    .registers 1

    sput p0, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sCurrentRatio:F

    return-void
.end method

.method static bridge synthetic -$$Nest$sfputsNextTickMs(J)V
    .registers 2

    sput-wide p0, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sNextTickMs:J

    return-void
.end method

.method static bridge synthetic -$$Nest$sfputsPendingStep(Ljava/lang/Runnable;)V
    .registers 1

    sput-object p0, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sPendingStep:Ljava/lang/Runnable;

    return-void
.end method

.method static bridge synthetic -$$Nest$sfputsStepCount(I)V
    .registers 1

    sput p0, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sStepCount:I

    return-void
.end method

.method static bridge synthetic -$$Nest$sminterpSmoothLog(FFF)F
    .registers 3

    invoke-static {p0, p1, p2}, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->interpSmoothLog(FFF)F

    move-result p0

    return p0
.end method

.method static bridge synthetic -$$Nest$smround3(F)F
    .registers 1

    invoke-static {p0}, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->round3(F)F

    move-result p0

    return p0
.end method

.method static constructor <clinit>()V
    .registers 5

    .line 19
    const/4 v0, 0x0

    sput-boolean v0, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sAnimating:Z

    .line 20
    const/high16 v1, 0x3f800000    # 1.0f

    sput v1, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sStartRatio:F

    .line 21
    sput v1, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sCurrentRatio:F

    .line 22
    sput v1, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sTargetRatio:F

    .line 23
    const-wide/16 v1, 0x0

    sput-wide v1, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sStartTimeMs:J

    .line 24
    const-wide/16 v3, 0xf0

    sput-wide v3, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sDurationMs:J

    .line 25
    sput-wide v1, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sNextTickMs:J

    .line 26
    sput-wide v1, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sLastRequestMs:J

    .line 27
    const/4 v1, 0x0

    sput-object v1, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sActiveCam:Lcom/oplus/ocs/camera/producer/device/Camera2Impl;

    .line 28
    sput-object v1, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sCallbackHandler:Landroid/os/Handler;

    .line 29
    sput v0, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sStepCount:I

    return-void
.end method

.method private constructor <init>()V
    .registers 1

    .line 31
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method public static cancel()V
    .registers 2

    .line 38
    sget-object v0, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sAnimHandler:Landroid/os/Handler;

    if-eqz v0, :cond_f

    sget-object v0, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sPendingStep:Ljava/lang/Runnable;

    if-eqz v0, :cond_f

    .line 39
    sget-object v0, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sAnimHandler:Landroid/os/Handler;

    sget-object v1, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sPendingStep:Ljava/lang/Runnable;

    invoke-virtual {v0, v1}, Landroid/os/Handler;->removeCallbacks(Ljava/lang/Runnable;)V

    .line 41
    :cond_f
    const/4 v0, 0x0

    sput-object v0, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sPendingStep:Ljava/lang/Runnable;

    .line 42
    const/4 v1, 0x0

    sput-boolean v1, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sAnimating:Z

    .line 43
    sput-object v0, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sActiveCam:Lcom/oplus/ocs/camera/producer/device/Camera2Impl;

    .line 44
    sput-object v0, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sCallbackHandler:Landroid/os/Handler;

    .line 45
    return-void
.end method

.method private static interpSmoothLog(FFF)F
    .registers 11

    .line 208
    float-to-double v0, p2

    const-wide v2, 0x400921fb54442d18L    # Math.PI

    mul-double/2addr v2, v0

    invoke-static {v2, v3}, Ljava/lang/Math;->cos(D)D

    move-result-wide v2

    const-wide/high16 v4, 0x3ff0000000000000L    # 1.0

    sub-double v2, v4, v2

    const-wide/high16 v6, 0x3fe0000000000000L    # 0.5

    mul-double/2addr v2, v6

    .line 209
    sub-double v0, v4, v0

    .line 210
    mul-double/2addr v0, v0

    sub-double/2addr v4, v0

    .line 211
    const-wide v0, 0x3fe199999999999aL    # 0.55

    mul-double/2addr v2, v0

    const-wide v0, 0x3fdccccccccccccdL    # 0.45

    mul-double/2addr v4, v0

    add-double/2addr v2, v4

    .line 212
    float-to-double v0, p0

    float-to-double p0, p1

    div-double/2addr p0, v0

    invoke-static {p0, p1, v2, v3}, Ljava/lang/Math;->pow(DD)D

    move-result-wide p0

    mul-double/2addr v0, p0

    .line 213
    double-to-float p0, v0

    .line 214
    const p1, 0x3f19999a    # 0.6f

    cmpg-float p2, p0, p1

    if-gez p2, :cond_34

    move p0, p1

    .line 215
    :cond_34
    const/high16 p1, 0x41200000    # 10.0f

    cmpl-float p2, p0, p1

    if-lez p2, :cond_3b

    move p0, p1

    .line 216
    :cond_3b
    return p0
.end method

.method public static isAnimating()Z
    .registers 1

    .line 34
    sget-boolean v0, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sAnimating:Z

    return v0
.end method

.method public static onPreviewZoomRequest(Lcom/oplus/ocs/camera/producer/device/Camera2Impl;FLandroid/os/Handler;)F
    .registers 16

    .line 67
    if-eqz p0, :cond_187

    invoke-virtual {p0}, Lcom/oplus/ocs/camera/producer/device/Camera2Impl;->dadaCanAnimateZoom()Z

    move-result v0

    if-nez v0, :cond_a

    goto/16 :goto_187

    .line 76
    :cond_a
    nop

    .line 77
    const v0, 0x3f19999a    # 0.6f

    cmpg-float v1, p1, v0

    if-gez v1, :cond_13

    move p1, v0

    .line 78
    :cond_13
    const/high16 v1, 0x41200000    # 10.0f

    cmpl-float v2, p1, v1

    if-lez v2, :cond_1a

    move p1, v1

    .line 80
    :cond_1a
    invoke-static {}, Landroid/os/SystemClock;->uptimeMillis()J

    move-result-wide v2

    .line 81
    sget-wide v4, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sLastRequestMs:J

    sub-long v4, v2, v4

    .line 82
    sput-wide v2, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sLastRequestMs:J

    .line 85
    sget-boolean v6, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sAnimating:Z

    if-eqz v6, :cond_3e

    sget-object v6, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sActiveCam:Lcom/oplus/ocs/camera/producer/device/Camera2Impl;

    if-ne v6, p0, :cond_3e

    sget v6, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sTargetRatio:F

    sub-float v6, p1, v6

    invoke-static {v6}, Ljava/lang/Math;->abs(F)F

    move-result v6

    const v7, 0x3b03126f    # 0.002f

    cmpg-float v6, v6, v7

    if-gez v6, :cond_3e

    .line 86
    sget p0, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sCurrentRatio:F

    return p0

    .line 89
    :cond_3e
    sget v6, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sCurrentRatio:F

    .line 90
    cmpg-float v0, v6, v0

    if-ltz v0, :cond_48

    cmpl-float v0, v6, v1

    if-lez v0, :cond_4a

    .line 91
    :cond_48
    const/high16 v6, 0x3f800000    # 1.0f

    .line 93
    :cond_4a
    sub-float v0, p1, v6

    invoke-static {v0}, Ljava/lang/Math;->abs(F)F

    move-result v0

    .line 96
    const v1, 0x3c75c28f    # 0.015f

    cmpg-float v1, v0, v1

    if-ltz v1, :cond_17f

    const v1, 0x3da3d70a    # 0.08f

    cmpg-float v1, v0, v1

    if-gez v1, :cond_66

    const-wide/16 v7, 0x3c

    cmp-long v1, v4, v7

    if-gtz v1, :cond_66

    goto/16 :goto_17f

    .line 103
    :cond_66
    invoke-static {}, Landroid/os/Looper;->myLooper()Landroid/os/Looper;

    move-result-object v1

    .line 104
    if-nez v1, :cond_74

    .line 105
    invoke-static {}, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->cancel()V

    .line 106
    sput p1, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sCurrentRatio:F

    .line 107
    sput p1, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sTargetRatio:F

    .line 108
    return p1

    .line 112
    :cond_74
    sget-object v4, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sAnimHandler:Landroid/os/Handler;

    if-eqz v4, :cond_90

    sget-object v4, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sAnimHandler:Landroid/os/Handler;

    invoke-virtual {v4}, Landroid/os/Handler;->getLooper()Landroid/os/Looper;

    move-result-object v4

    if-eq v4, v1, :cond_81

    goto :goto_90

    .line 115
    :cond_81
    sget-object v1, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sPendingStep:Ljava/lang/Runnable;

    if-eqz v1, :cond_9a

    .line 116
    sget-object v1, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sAnimHandler:Landroid/os/Handler;

    sget-object v4, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sPendingStep:Ljava/lang/Runnable;

    invoke-virtual {v1, v4}, Landroid/os/Handler;->removeCallbacks(Ljava/lang/Runnable;)V

    .line 117
    const/4 v1, 0x0

    sput-object v1, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sPendingStep:Ljava/lang/Runnable;

    goto :goto_9a

    .line 113
    :cond_90
    :goto_90
    invoke-static {}, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->cancel()V

    .line 114
    new-instance v4, Landroid/os/Handler;

    invoke-direct {v4, v1}, Landroid/os/Handler;-><init>(Landroid/os/Looper;)V

    sput-object v4, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sAnimHandler:Landroid/os/Handler;

    .line 121
    :cond_9a
    :goto_9a
    const/high16 v1, 0x40100000    # 2.25f

    cmpg-float v4, v6, v1

    const/high16 v5, 0x40200000    # 2.5f

    const/4 v7, 0x0

    const/4 v8, 0x1

    if-gez v4, :cond_aa

    cmpl-float v4, p1, v5

    if-ltz v4, :cond_aa

    move v4, v8

    goto :goto_ab

    :cond_aa
    move v4, v7

    .line 122
    :goto_ab
    cmpl-float v5, v6, v5

    if-ltz v5, :cond_b5

    cmpg-float v1, p1, v1

    if-gez v1, :cond_b5

    move v1, v8

    goto :goto_b6

    :cond_b5
    move v1, v7

    .line 123
    :goto_b6
    const v5, 0x3f733333    # 0.95f

    cmpg-float v9, v6, v5

    if-gez v9, :cond_c1

    cmpl-float v9, p1, v5

    if-gez v9, :cond_c9

    :cond_c1
    cmpl-float v9, v6, v5

    if-ltz v9, :cond_ca

    cmpg-float v5, p1, v5

    if-gez v5, :cond_ca

    :cond_c9
    move v7, v8

    .line 126
    :cond_ca
    const v5, 0x3f99999a    # 1.2f

    if-eqz v4, :cond_d9

    .line 128
    cmpl-float v0, v0, v5

    if-ltz v0, :cond_d6

    const-wide/16 v0, 0x168

    goto :goto_f6

    :cond_d6
    const-wide/16 v0, 0x154

    goto :goto_f6

    .line 129
    :cond_d9
    const-wide/16 v9, 0x12c

    if-eqz v7, :cond_df

    .line 130
    move-wide v0, v9

    goto :goto_f6

    .line 131
    :cond_df
    if-eqz v1, :cond_ea

    .line 132
    cmpl-float v0, v0, v5

    if-ltz v0, :cond_e7

    move-wide v0, v9

    goto :goto_f6

    :cond_e7
    const-wide/16 v0, 0x118

    goto :goto_f6

    .line 133
    :cond_ea
    const v1, 0x3e99999a    # 0.3f

    cmpl-float v0, v0, v1

    if-ltz v0, :cond_f4

    .line 134
    const-wide/16 v0, 0xf0

    goto :goto_f6

    .line 136
    :cond_f4
    const-wide/16 v0, 0x82

    .line 139
    :goto_f6
    sput-object p0, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sActiveCam:Lcom/oplus/ocs/camera/producer/device/Camera2Impl;

    .line 140
    sput-object p2, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sCallbackHandler:Landroid/os/Handler;

    .line 141
    sput v6, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sStartRatio:F

    .line 142
    sput p1, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sTargetRatio:F

    .line 143
    sput-wide v0, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sDurationMs:J

    .line 145
    const-wide/16 v9, 0xb

    sub-long v11, v2, v9

    sput-wide v11, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sStartTimeMs:J

    .line 146
    add-long/2addr v9, v2

    sput-wide v9, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sNextTickMs:J

    .line 147
    sput-boolean v8, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sAnimating:Z

    .line 148
    sput v8, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sStepCount:I

    .line 150
    long-to-float p0, v0

    const/high16 p2, 0x41300000    # 11.0f

    div-float/2addr p2, p0

    .line 151
    if-eqz v4, :cond_128

    const v4, 0x3ff33333    # 1.9f

    cmpl-float v4, v6, v4

    if-ltz v4, :cond_128

    const v4, 0x3e0f5c29    # 0.14f

    cmpg-float v5, p2, v4

    if-gez v5, :cond_128

    .line 153
    nop

    .line 154
    mul-float/2addr p0, v4

    float-to-long v7, p0

    sub-long/2addr v2, v7

    sput-wide v2, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sStartTimeMs:J

    move p2, v4

    .line 156
    :cond_128
    invoke-static {v6, p1, p2}, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->interpSmoothLog(FFF)F

    move-result p0

    .line 157
    sput p0, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sCurrentRatio:F

    .line 159
    invoke-static {v6}, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->round3(F)F

    move-result p2

    invoke-static {p1}, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->round3(F)F

    move-result p1

    invoke-static {p0}, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->round3(F)F

    move-result v2

    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "start "

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3, p2}, Ljava/lang/StringBuilder;->append(F)Ljava/lang/StringBuilder;

    move-result-object p2

    const-string v3, " -> "

    invoke-virtual {p2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p2

    invoke-virtual {p2, p1}, Ljava/lang/StringBuilder;->append(F)Ljava/lang/StringBuilder;

    move-result-object p1

    const-string p2, " dur="

    invoke-virtual {p1, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1, v0, v1}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    move-result-object p1

    const-string p2, "ms step1="

    invoke-virtual {p1, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1, v2}, Ljava/lang/StringBuilder;->append(F)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    const-string p2, "DadaZoomAnim"

    invoke-static {p2, p1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    .line 161
    new-instance p1, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator$1;

    invoke-direct {p1}, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator$1;-><init>()V

    .line 200
    sput-object p1, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sPendingStep:Ljava/lang/Runnable;

    .line 201
    sget-object p2, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sAnimHandler:Landroid/os/Handler;

    sget-wide v0, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sNextTickMs:J

    invoke-virtual {p2, p1, v0, v1}, Landroid/os/Handler;->postAtTime(Ljava/lang/Runnable;J)Z

    .line 202
    return p0

    .line 97
    :cond_17f
    :goto_17f
    invoke-static {}, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->cancel()V

    .line 98
    sput p1, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sCurrentRatio:F

    .line 99
    sput p1, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sTargetRatio:F

    .line 100
    return p1

    .line 68
    :cond_187
    :goto_187
    invoke-static {}, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->cancel()V

    .line 69
    const/4 p0, 0x0

    cmpl-float p0, p1, p0

    if-lez p0, :cond_193

    .line 70
    sput p1, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sCurrentRatio:F

    .line 71
    sput p1, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sTargetRatio:F

    .line 73
    :cond_193
    return p1
.end method

.method public static onStillCaptureZoom(F)F
    .registers 2

    .line 56
    sget-boolean v0, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sAnimating:Z

    if-eqz v0, :cond_14

    .line 57
    const/4 v0, 0x0

    cmpl-float v0, p0, v0

    if-lez v0, :cond_a

    goto :goto_c

    :cond_a
    sget p0, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sTargetRatio:F

    .line 58
    :goto_c
    invoke-static {}, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->cancel()V

    .line 59
    sput p0, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sCurrentRatio:F

    .line 60
    sput p0, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sTargetRatio:F

    .line 61
    return p0

    .line 63
    :cond_14
    return p0
.end method

.method public static reset()V
    .registers 2

    .line 48
    invoke-static {}, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->cancel()V

    .line 49
    const/high16 v0, 0x3f800000    # 1.0f

    sput v0, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sStartRatio:F

    .line 50
    sput v0, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sCurrentRatio:F

    .line 51
    sput v0, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sTargetRatio:F

    .line 52
    const-wide/16 v0, 0x0

    sput-wide v0, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->sLastRequestMs:J

    .line 53
    return-void
.end method

.method private static round3(F)F
    .registers 2

    .line 220
    const/high16 v0, 0x447a0000    # 1000.0f

    mul-float/2addr p0, v0

    invoke-static {p0}, Ljava/lang/Math;->round(F)I

    move-result p0

    int-to-float p0, p0

    div-float/2addr p0, v0

    return p0
.end method
