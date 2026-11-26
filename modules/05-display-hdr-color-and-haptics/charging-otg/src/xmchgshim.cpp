#include <android/binder_ibinder.h>
#include <android/binder_parcel.h>
#include <android/binder_status.h>
#include <android/log.h>
#include <dlfcn.h>
#include <errno.h>
#include <fcntl.h>
#include <pthread.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>
#include <unistd.h>

#define LOG_TAG "XmChgShim"
#define ICHARGER_DESCRIPTOR "vendor.oplus.hardware.charger.ICharger"
#define DEFAULT_SERVICE "vendor.oplus.hardware.charger.ICharger/default"
#define ORIGHAL_SERVICE "vendor.oplus.hardware.charger.ICharger/orighal"

#define CC_TOGGLE_PATH "/sys/class/xm_power/typec/cc_toggle"
#define TYPEC_DATA_ROLE_PATH "/sys/class/typec/port0/data_role"
#define REVERSE_CHG_MODE_PATH "/sys/class/qcom-battery/reverse_chg_mode"
#define CHARGE_ENABLE_PATH "/sys/class/xm_power/charger/charge_interface/charge_enable"
#define BATTERY_CAP_PATH "/sys/class/power_supply/battery/capacity"

enum {
    TX_GET_PSY_OTG_ONLINE = 0x2b,    // 43
    TX_GET_PSY_OTG_SWITCH = 0x2c,    // 44
    TX_SET_PSY_OTG_SWITCH = 0x5b,    // 91
    TX_GET_WIRELESS_TX_ENABLE = 0x49,// 73
    TX_SET_WIRELESS_TX_ENABLE = 0x69,// 105
    TX_SET_CHG_CONFIG = 0x7f         // 127: setChgConfig(int flag, String extra, int callname)
};

typedef int32_t (*add_service_fn)(AIBinder* binder, const char* instance);
typedef AIBinder* (*wait_service_fn)(const char* instance);
typedef AIBinder* (*check_service_fn)(const char* instance);
typedef void (*set_threads_fn)(uint32_t numThreads);
typedef void (*void_fn)(void);

static add_service_fn g_add_service = nullptr;
static wait_service_fn g_wait_service = nullptr;
static check_service_fn g_check_service = nullptr;
static set_threads_fn g_set_threads = nullptr;
static void_fn g_start_pool = nullptr;
static void_fn g_join_pool = nullptr;

static pthread_mutex_t g_orig_lock = PTHREAD_MUTEX_INITIALIZER;
static AIBinder* g_orig_binder = nullptr;
static AIBinder_Class* g_icharger_class = nullptr;

static bool string_alloc(void* stringData, int32_t length, char** outBuffer) {
    char** dst = static_cast<char**>(stringData);
    if (length < 0) {
        *dst = nullptr;
        *outBuffer = nullptr;
        return true;
    }
    char* buf = static_cast<char*>(malloc(static_cast<size_t>(length) + 1));
    if (!buf) return false;
    buf[length] = '\0';
    *dst = buf;
    *outBuffer = buf;
    return true;
}

static int read_sysfs_buf(const char* path, char* buf, size_t sz) {
    int fd = open(path, O_RDONLY | O_CLOEXEC);
    if (fd < 0) return -errno;
    ssize_t n = read(fd, buf, sz - 1);
    int saved = errno;
    close(fd);
    if (n < 0) return -saved;
    buf[n] = '\0';
    return static_cast<int>(n);
}

static int write_sysfs_str(const char* path, const char* str) {
    int fd = open(path, O_WRONLY | O_CLOEXEC);
    if (fd < 0) {
        int err = errno;
        __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, "open %s failed: %s", path, strerror(err));
        return -err;
    }
    size_t len = strlen(str);
    ssize_t n = write(fd, str, len);
    int err = errno;
    close(fd);
    if (n != static_cast<ssize_t>(len)) {
        __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, "write %s (%s) failed: %s", path, str, strerror(err));
        return -err;
    }
    return 0;
}

static int write_sysfs_01(const char* path, int enable) {
    return write_sysfs_str(path, enable ? "1" : "0");
}

static int read_battery_capacity(void) {
    char buf[32];
    int n = read_sysfs_buf(BATTERY_CAP_PATH, buf, sizeof(buf));
    if (n <= 0) return -1;
    return atoi(buf);
}

static int read_cc_toggle(void) {
    char buf[32];
    int n = read_sysfs_buf(CC_TOGGLE_PATH, buf, sizeof(buf));
    if (n <= 0) return 0;
    return atoi(buf) != 0 ? 1 : 0;
}

static int read_otg_online(void) {
    char buf[64];
    int n = read_sysfs_buf(TYPEC_DATA_ROLE_PATH, buf, sizeof(buf));
    if (n > 0 && strstr(buf, "[host]") != nullptr) return 1;
    return 0;
}

static int read_reverse_chg(void) {
    char buf[32];
    int n = read_sysfs_buf(REVERSE_CHG_MODE_PATH, buf, sizeof(buf));
    if (n <= 0) return 0;
    return atoi(buf) != 0 ? 1 : 0;
}

/*
 * Vote on all Xiaomi 15 MCA charging stages in charge_enable:
 *   - buck     : wired buck charger
 *   - quick    : wired 80W HyperCharge / USB-PD PPS direct charge pump (prevents 5000mA bleed!)
 *   - wl_buck  : wireless buck charger
 *   - wl_quick : wireless fast charge pump
 * Value 0 = stop charging (true 0mA bypass while charger powers system), 1 = allow charging.
 */
static int vote_charge_enable(const char* client, int enable) {
    static const char* const kStages[] = {"buck", "quick", "wl_buck", "wl_quick"};
    int val = enable ? 1 : 0;
    int primary_rc = 0;
    for (size_t i = 0; i < sizeof(kStages) / sizeof(kStages[0]); ++i) {
        char cmd[64];
        snprintf(cmd, sizeof(cmd), "%s %s %d", client, kStages[i], val);
        int rc = write_sysfs_str(CHARGE_ENABLE_PATH, cmd);
        if (i < 2 && rc != 0 && primary_rc == 0) {
            primary_rc = rc;
        }
    }
    return primary_rc;
}

static void read_charge_enable_oneline(char* out, size_t sz) {
    memset(out, 0, sz);
    read_sysfs_buf(CHARGE_ENABLE_PATH, out, sz);
    for (char* p = out; *p; ++p) {
        if (*p == '\n' || *p == '\r') *p = ' ';
    }
}

static AIBinder* acquire_orig_hal(void) {
    pthread_mutex_lock(&g_orig_lock);
    if (g_orig_binder && AIBinder_isAlive(g_orig_binder)) {
        AIBinder_incStrong(g_orig_binder);
        AIBinder* ret = g_orig_binder;
        pthread_mutex_unlock(&g_orig_lock);
        return ret;
    }
    if (g_orig_binder) {
        AIBinder_decStrong(g_orig_binder);
        g_orig_binder = nullptr;
    }
    AIBinder* b = g_check_service ? g_check_service(ORIGHAL_SERVICE) : nullptr;
    if (!b && g_wait_service) {
        b = g_wait_service(ORIGHAL_SERVICE);
    }
    if (b) {
        if (g_icharger_class && !AIBinder_associateClass(b, g_icharger_class)) {
            __android_log_print(ANDROID_LOG_WARN, LOG_TAG, "AIBinder_associateClass failed");
        }
        g_orig_binder = b;
        AIBinder_incStrong(g_orig_binder);
    }
    pthread_mutex_unlock(&g_orig_lock);
    return b;
}

static binder_status_t forward_to_orighal(transaction_code_t code, const AParcel* in, AParcel* out) {
    AIBinder* orig = acquire_orig_hal();
    if (!orig) {
        __android_log_print(ANDROID_LOG_WARN, LOG_TAG, "orighal unavailable for tx=0x%x", code);
        return STATUS_NAME_NOT_FOUND;
    }
    AParcel* fwdIn = nullptr;
    binder_status_t st = AIBinder_prepareTransaction(orig, &fwdIn);
    if (st != STATUS_OK || !fwdIn) {
        AIBinder_decStrong(orig);
        return st != STATUS_OK ? st : STATUS_FAILED_TRANSACTION;
    }
    int32_t pos = AParcel_getDataPosition(in);
    int32_t sz = AParcel_getDataSize(in);
    if (sz > pos && pos >= 0) {
        st = AParcel_appendFrom(in, fwdIn, pos, sz - pos);
        if (st != STATUS_OK) {
            AParcel_delete(fwdIn);
            AIBinder_decStrong(orig);
            return st;
        }
    }
    AParcel* fwdOut = nullptr;
    st = AIBinder_transact(orig, code, &fwdIn, &fwdOut, 0);
    if (st == STATUS_DEAD_OBJECT) {
        pthread_mutex_lock(&g_orig_lock);
        if (g_orig_binder == orig) {
            AIBinder_decStrong(g_orig_binder);
            g_orig_binder = nullptr;
        }
        pthread_mutex_unlock(&g_orig_lock);
    }
    AIBinder_decStrong(orig);
    if (fwdOut) {
        int32_t outSz = AParcel_getDataSize(fwdOut);
        if (outSz > 0) {
            binder_status_t cp = AParcel_appendFrom(fwdOut, out, 0, outSz);
            if (st == STATUS_OK && cp != STATUS_OK) st = cp;
        }
        AParcel_delete(fwdOut);
    }
    return st;
}

/*
 * Ask orighal -> IMiCharge to clear smart_night=0 (soc_limit=1) with 0 AVCs.
 */
static void clear_orighal_smart_night(void) {
    AIBinder* orig = acquire_orig_hal();
    if (!orig) return;
    AParcel* in = nullptr;
    AParcel* out = nullptr;
    if (AIBinder_prepareTransaction(orig, &in) == STATUS_OK && in) {
        const char* offExtra = "2++0+80";
        AParcel_writeInt32(in, 14);
        AParcel_writeString(in, offExtra, static_cast<int32_t>(strlen(offExtra)));
        AParcel_writeInt32(in, 2);
        AIBinder_transact(orig, TX_SET_CHG_CONFIG, &in, &out, 0);
        if (out) AParcel_delete(out);
    }
    AIBinder_decStrong(orig);
}

static int parse_int_after_key(const char* extra, const char* key) {
    const char* p = strstr(extra, key);
    if (!p) return -1;
    p += strlen(key);
    if (*p < '0' || *p > '9') return -1;
    return atoi(p);
}

static void* shim_on_create(void* args) { return args; }
static void shim_on_destroy(void* /*userData*/) {}

static binder_status_t shim_on_transact(AIBinder* /*binder*/,
                                        transaction_code_t code,
                                        const AParcel* in,
                                        AParcel* out) {
    if (code == TX_GET_PSY_OTG_ONLINE) {
        int online = read_otg_online();
        AParcel_writeInt32(out, 0);
        AParcel_writeInt32(out, online);
        return STATUS_OK;
    }
    if (code == TX_GET_PSY_OTG_SWITCH) {
        int sw = read_cc_toggle();
        AParcel_writeInt32(out, 0);
        AParcel_writeInt32(out, sw);
        return STATUS_OK;
    }
    if (code == TX_SET_PSY_OTG_SWITCH) {
        char* arg = nullptr;
        binder_status_t st = AParcel_readString(in, &arg, string_alloc);
        int enable = 0;
        if (st == STATUS_OK && arg != nullptr) {
            if (strcmp(arg, "1") == 0 || strcasecmp(arg, "true") == 0) {
                enable = 1;
            }
        }
        free(arg);
        int rc = write_sysfs_01(CC_TOGGLE_PATH, enable);
        __android_log_print(ANDROID_LOG_INFO, LOG_TAG,
                            "setPsyOtgSwitch(%d) rc=%d cc_toggle=%d",
                            enable, rc, read_cc_toggle());
        AParcel_writeInt32(out, 0);
        AParcel_writeInt32(out, (rc == 0) ? 0 : -1);
        return STATUS_OK;
    }
    if (code == TX_GET_WIRELESS_TX_ENABLE) {
        const char* state = read_reverse_chg() ? "enable" : "disable";
        AParcel_writeInt32(out, 0);
        AParcel_writeString(out, state, static_cast<int32_t>(strlen(state)));
        return STATUS_OK;
    }
    if (code == TX_SET_WIRELESS_TX_ENABLE) {
        char* arg = nullptr;
        binder_status_t st = AParcel_readString(in, &arg, string_alloc);
        int enable = 0;
        if (st == STATUS_OK && arg != nullptr) {
            if (strcmp(arg, "1") == 0 || strcasecmp(arg, "true") == 0 || strcasecmp(arg, "enable") == 0) {
                enable = 1;
            }
        }
        free(arg);
        int rc = write_sysfs_01(REVERSE_CHG_MODE_PATH, enable);
        AParcel_writeInt32(out, 0);
        AParcel_writeInt32(out, (rc == 0) ? 0 : -1);
        return STATUS_OK;
    }
    if (code == TX_SET_CHG_CONFIG) {
        int32_t savedPos = AParcel_getDataPosition(in);
        int32_t flag = -1;
        char* extra = nullptr;
        binder_status_t st1 = AParcel_readInt32(in, &flag);
        binder_status_t st2 = (st1 == STATUS_OK) ? AParcel_readString(in, &extra, string_alloc) : st1;

        if (st1 == STATUS_OK && st2 == STATUS_OK && extra != nullptr) {
            /*
             * TASK 3: Bypass Charging (flag == 25)
             * Votes on ALL 4 Xiaomi MCA stages (buck, quick, wl_buck, wl_quick) so 80W
             * HyperCharge / USB-PD PPS charge pumps stop at 0mA instead of bleeding 5000mA.
             * Also honors optional threshold=<N>/level=<N>/soc=<N> if provided in payload.
             */
            if (flag == 25) {
                int bypass = -1;
                if (strstr(extra, "switch=1") != nullptr || strcmp(extra, "1") == 0) {
                    bypass = 1;
                } else if (strstr(extra, "switch=0") != nullptr || strcmp(extra, "0") == 0) {
                    bypass = 0;
                }
                if (bypass >= 0) {
                    int cap = read_battery_capacity();
                    int thresh = parse_int_after_key(extra, "threshold=");
                    if (thresh < 0) thresh = parse_int_after_key(extra, "level=");
                    if (thresh < 0) thresh = parse_int_after_key(extra, "soc=");
                    if (thresh < 0) thresh = parse_int_after_key(extra, "value=");
                    if (bypass == 1 && thresh > 0 && cap >= 0 && cap < thresh) {
                        bypass = 0;
                    }
                    int rc = vote_charge_enable("bypass", bypass ? 0 : 1);
                    char cur[160];
                    read_charge_enable_oneline(cur, sizeof(cur));
                    __android_log_print(ANDROID_LOG_INFO, LOG_TAG,
                                        "setChgConfig(flag=25, extra=%s, cap=%d, thresh=%d) -> bypass=%d rc=%d now='%s'",
                                        extra, cap, thresh, bypass, rc, cur);
                    free(extra);
                    AParcel_writeInt32(out, 0);
                    AParcel_writeInt32(out, (rc == 0) ? 0 : -1);
                    return STATUS_OK;
                }
            }

            /*
             * TASK 2: Custom Charging Limit switch/level (flag == 14, "2++<sw>+<limit>")
             * Never rely on Xiaomi's sticky hardcoded-80% smart_night node.
             * Always clear smart_night=0 via orighal -> IMiCharge, and enforce exact
             * chosen limit (80/85/90/95%) using independent client 'chg_limit' on charge_enable.
             */
            if (flag == 14) {
                int sw = -1;
                int limit = 80;
                if (sscanf(extra, "2++%d+%d", &sw, &limit) >= 1 && (sw == 0 || sw == 1)) {
                    clear_orighal_smart_night();
                    int cap = read_battery_capacity();
                    int allow_chg = 1;
                    if (sw == 1 && limit > 0 && cap >= 0 && cap >= limit) {
                        allow_chg = 0;
                    }
                    int rc = vote_charge_enable("chg_limit", allow_chg);
                    char cur[160];
                    read_charge_enable_oneline(cur, sizeof(cur));
                    __android_log_print(ANDROID_LOG_INFO, LOG_TAG,
                                        "setChgConfig(flag=14, extra=%s, cap=%d, sw=%d, limit=%d) -> chg_limit=%d rc=%d now='%s'",
                                        extra, cap, sw, limit, allow_chg, rc, cur);
                    free(extra);
                    AParcel_writeInt32(out, 0);
                    AParcel_writeInt32(out, (rc == 0) ? 0 : -1);
                    return STATUS_OK;
                }
            }

            /*
             * TASK 2: Smart/Regular Charge Protection stop/resume (flag == 5, "4++<stop>+<limit>+...")
             * Clear smart_night=0 and vote client 'chg_limit' cleanly so disable immediately resumes
             * charging to 100% without unplugging/replugging.
             */
            if (flag == 5) {
                int stop = -1;
                int limit = 80;
                if (sscanf(extra, "4++%d+%d", &stop, &limit) >= 1 && (stop == 0 || stop == 1)) {
                    clear_orighal_smart_night();
                    int allow_chg = (stop == 1) ? 0 : 1;
                    int rc = vote_charge_enable("chg_limit", allow_chg);
                    char cur[160];
                    read_charge_enable_oneline(cur, sizeof(cur));
                    __android_log_print(ANDROID_LOG_INFO, LOG_TAG,
                                        "setChgConfig(flag=5, extra=%s, stop=%d, limit=%d) -> chg_limit=%d rc=%d now='%s'",
                                        extra, stop, limit, allow_chg, rc, cur);
                    free(extra);
                    AParcel_writeInt32(out, 0);
                    AParcel_writeInt32(out, (rc == 0) ? 0 : -1);
                    return STATUS_OK;
                }
            }
        }
        free(extra);
        AParcel_setDataPosition(in, savedPos);
    }
    return forward_to_orighal(code, in, out);
}

static bool load_binder_ndk_apex_symbols(void) {
    void* handle = dlopen("libbinder_ndk.so", RTLD_NOW);
    if (!handle) {
        __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, "dlopen libbinder_ndk: %s", dlerror());
        return false;
    }
    g_add_service = reinterpret_cast<add_service_fn>(dlsym(handle, "AServiceManager_addService"));
    g_wait_service = reinterpret_cast<wait_service_fn>(dlsym(handle, "AServiceManager_waitForService"));
    g_check_service = reinterpret_cast<check_service_fn>(dlsym(handle, "AServiceManager_checkService"));
    g_set_threads = reinterpret_cast<set_threads_fn>(dlsym(handle, "ABinderProcess_setThreadPoolMaxThreadCount"));
    g_start_pool = reinterpret_cast<void_fn>(dlsym(handle, "ABinderProcess_startThreadPool"));
    g_join_pool = reinterpret_cast<void_fn>(dlsym(handle, "ABinderProcess_joinThreadPool"));
    if (!g_add_service || !g_wait_service || !g_set_threads || !g_join_pool) {
        __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, "missing binder_ndk runtime symbols");
        return false;
    }
    return true;
}

int main(void) {
    if (!load_binder_ndk_apex_symbols()) {
        return 1;
    }
    g_set_threads(4);
    if (g_start_pool) g_start_pool();

    AIBinder_Class* clazz = AIBinder_Class_define(
        ICHARGER_DESCRIPTOR, shim_on_create, shim_on_destroy, shim_on_transact);
    if (!clazz) {
        __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, "AIBinder_Class_define failed");
        return 1;
    }
    g_icharger_class = clazz;
    acquire_orig_hal();
    vote_charge_enable("bypass", 1);
    vote_charge_enable("chg_limit", 1);
    AIBinder* binder = AIBinder_new(clazz, nullptr);
    if (!binder) {
        __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, "AIBinder_new failed");
        return 1;
    }
    int32_t st = g_add_service(binder, DEFAULT_SERVICE);
    __android_log_print(ANDROID_LOG_INFO, LOG_TAG,
                        "registered %s st=%d cc_toggle=%d cap=%d",
                        DEFAULT_SERVICE, st, read_cc_toggle(), read_battery_capacity());
    g_join_pool();
    AIBinder_decStrong(binder);
    return 0;
}
