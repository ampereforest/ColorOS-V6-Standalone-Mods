.class Lcom/oplus/camera/util/DadaJpegSaver$1;
.super Ljava/lang/Object;
.source "DadaJpegSaver.java"

# interfaces
.implements Ljava/lang/Runnable;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/oplus/camera/util/DadaJpegSaver;->save(Landroid/content/Context;[BIJ)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic val$fcr:Landroid/content/ContentResolver;


# direct methods
.method constructor <init>(Landroid/content/ContentResolver;)V
    .registers 2
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()V"
        }
    .end annotation

    .line 129
    iput-object p1, p0, Lcom/oplus/camera/util/DadaJpegSaver$1;->val$fcr:Landroid/content/ContentResolver;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .registers 3

    .line 133
    const-wide/16 v0, 0x5dc

    :try_start_2
    invoke-static {v0, v1}, Ljava/lang/Thread;->sleep(J)V
    :try_end_5
    .catch Ljava/lang/InterruptedException; {:try_start_2 .. :try_end_5} :catch_6

    .line 135
    goto :goto_7

    .line 134
    :catch_6
    move-exception v0

    .line 136
    :goto_7
    iget-object v0, p0, Lcom/oplus/camera/util/DadaJpegSaver$1;->val$fcr:Landroid/content/ContentResolver;

    const-string v1, "late"

    invoke-static {v0, v1}, Lcom/oplus/camera/util/DadaJpegSaver;->purgeAppPendingRows(Landroid/content/ContentResolver;Ljava/lang/String;)V

    .line 137
    return-void
.end method
