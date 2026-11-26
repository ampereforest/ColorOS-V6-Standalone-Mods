.class Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator$1;
.super Ljava/lang/Object;
.source "DadaZoomAnimator.java"

# interfaces
.implements Ljava/lang/Runnable;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->onPreviewZoomRequest(Lcom/oplus/ocs/camera/producer/device/Camera2Impl;FLandroid/os/Handler;)F
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# direct methods
.method constructor <init>()V
    .registers 1

    .line 161
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .registers 7

    .line 164
    invoke-static {}, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->-$$Nest$sfgetsAnimating()Z

    move-result v0

    if-eqz v0, :cond_d3

    invoke-static {}, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->-$$Nest$sfgetsActiveCam()Lcom/oplus/ocs/camera/producer/device/Camera2Impl;

    move-result-object v0

    if-nez v0, :cond_e

    goto/16 :goto_d3

    .line 167
    :cond_e
    invoke-static {}, Landroid/os/SystemClock;->uptimeMillis()J

    move-result-wide v0

    .line 168
    invoke-static {}, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->-$$Nest$sfgetsStartTimeMs()J

    move-result-wide v2

    sub-long v2, v0, v2

    .line 169
    invoke-static {}, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->-$$Nest$sfgetsDurationMs()J

    move-result-wide v4

    cmp-long v4, v2, v4

    if-ltz v4, :cond_67

    .line 170
    invoke-static {}, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->-$$Nest$sfgetsTargetRatio()F

    move-result v0

    .line 171
    invoke-static {}, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->-$$Nest$sfgetsActiveCam()Lcom/oplus/ocs/camera/producer/device/Camera2Impl;

    move-result-object v1

    .line 172
    invoke-static {}, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->-$$Nest$sfgetsCallbackHandler()Landroid/os/Handler;

    move-result-object v2

    .line 173
    invoke-static {}, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->-$$Nest$sfgetsStepCount()I

    move-result v3

    add-int/lit8 v3, v3, 0x1

    .line 174
    invoke-static {v0}, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->-$$Nest$sfputsCurrentRatio(F)V

    .line 175
    const/4 v4, 0x0

    invoke-static {v4}, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->-$$Nest$sfputsAnimating(Z)V

    .line 176
    const/4 v4, 0x0

    invoke-static {v4}, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->-$$Nest$sfputsPendingStep(Ljava/lang/Runnable;)V

    .line 177
    invoke-virtual {v1, v0, v2}, Lcom/oplus/ocs/camera/producer/device/Camera2Impl;->dadaApplyAnimatedZoom(FLandroid/os/Handler;)Z

    .line 178
    invoke-static {v0}, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->-$$Nest$smround3(F)F

    move-result v0

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "done target="

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(F)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, " steps="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    const-string v1, "DadaZoomAnim"

    invoke-static {v1, v0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    .line 179
    return-void

    .line 181
    :cond_67
    long-to-float v2, v2

    invoke-static {}, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->-$$Nest$sfgetsDurationMs()J

    move-result-wide v3

    long-to-float v3, v3

    div-float/2addr v2, v3

    .line 182
    const/4 v3, 0x0

    cmpg-float v4, v2, v3

    if-gez v4, :cond_74

    move v2, v3

    .line 183
    :cond_74
    const/high16 v3, 0x3f800000    # 1.0f

    cmpl-float v4, v2, v3

    if-lez v4, :cond_7b

    move v2, v3

    .line 184
    :cond_7b
    invoke-static {}, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->-$$Nest$sfgetsStartRatio()F

    move-result v3

    invoke-static {}, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->-$$Nest$sfgetsTargetRatio()F

    move-result v4

    invoke-static {v3, v4, v2}, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->-$$Nest$sminterpSmoothLog(FFF)F

    move-result v2

    .line 185
    invoke-static {v2}, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->-$$Nest$sfputsCurrentRatio(F)V

    .line 186
    invoke-static {}, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->-$$Nest$sfgetsStepCount()I

    move-result v3

    add-int/lit8 v3, v3, 0x1

    invoke-static {v3}, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->-$$Nest$sfputsStepCount(I)V

    .line 187
    invoke-static {}, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->-$$Nest$sfgetsActiveCam()Lcom/oplus/ocs/camera/producer/device/Camera2Impl;

    move-result-object v3

    invoke-static {}, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->-$$Nest$sfgetsCallbackHandler()Landroid/os/Handler;

    move-result-object v4

    invoke-virtual {v3, v2, v4}, Lcom/oplus/ocs/camera/producer/device/Camera2Impl;->dadaApplyAnimatedZoom(FLandroid/os/Handler;)Z

    move-result v2

    if-nez v2, :cond_a5

    .line 188
    invoke-static {}, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->cancel()V

    .line 189
    return-void

    .line 191
    :cond_a5
    invoke-static {}, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->-$$Nest$sfgetsAnimHandler()Landroid/os/Handler;

    move-result-object v2

    if-eqz v2, :cond_d2

    invoke-static {}, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->-$$Nest$sfgetsAnimating()Z

    move-result v2

    if-eqz v2, :cond_d2

    .line 192
    invoke-static {}, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->-$$Nest$sfgetsNextTickMs()J

    move-result-wide v2

    const-wide/16 v4, 0xb

    add-long/2addr v2, v4

    invoke-static {v2, v3}, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->-$$Nest$sfputsNextTickMs(J)V

    .line 193
    invoke-static {}, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->-$$Nest$sfgetsNextTickMs()J

    move-result-wide v2

    cmp-long v2, v2, v0

    if-gtz v2, :cond_c7

    .line 194
    add-long/2addr v0, v4

    invoke-static {v0, v1}, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->-$$Nest$sfputsNextTickMs(J)V

    .line 196
    :cond_c7
    invoke-static {}, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->-$$Nest$sfgetsAnimHandler()Landroid/os/Handler;

    move-result-object v0

    invoke-static {}, Lcom/oplus/ocs/camera/producer/device/DadaZoomAnimator;->-$$Nest$sfgetsNextTickMs()J

    move-result-wide v1

    invoke-virtual {v0, p0, v1, v2}, Landroid/os/Handler;->postAtTime(Ljava/lang/Runnable;J)Z

    .line 198
    :cond_d2
    return-void

    .line 165
    :cond_d3
    :goto_d3
    return-void
.end method
