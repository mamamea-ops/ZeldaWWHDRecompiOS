// Guest memory, RPX loading, function dispatch, logging and HLE registry.
#ifdef __APPLE__
#include <mach/mach.h>
#if !TARGET_OS_IPHONE
#include <mach/mach_vm.h>
#include <mach-o/ldsyms.h>
#else
#include <sys/mman.h>
#endif
#endif
#include "platform/host.h"
#include "write_watch.h"
#include <zlib.h>
#ifdef __ANDROID__
#include <android/log.h>
#endif
