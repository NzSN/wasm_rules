#include "libavformat/avformat.h"
#include "api.h"

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
