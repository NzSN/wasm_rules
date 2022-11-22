#include "libavformat/avformat.h"

#ifndef EM_PORT_API
#if defined(__EMSCRIPTEN__)
#include <emscripten.h>
#if defined(__cplusplus)
#define EM_PORT_API(rettype) extern "C" rettype EMSCRIPTEN_KEEPALIVE
#else
#define EM_PORT_API(rettype) rettype EMSCRIPTEN_KEEPALIVE
#endif
#else
#if defined(__cplusplus)
#define EM_PORT_API(rettype) extern "C" rettype
#else
#define EM_PORT_API(rettype) rettype
#endif
#endif
#endif

void say(void);

EM_PORT_API(int) doing(void) {
    say();

    AVFormatContext *ctx = avformat_alloc_context();
    printf("%p\n", ctx);

    return 0;
}

int main(void) {
    doing();
}
