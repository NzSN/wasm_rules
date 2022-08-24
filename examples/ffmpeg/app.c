#include "libavformat/avformat.h"

void say(void);

int main(void) {
    say();

    AVFormatContext *ctx = avformat_alloc_context();
    printf("%p\n", ctx);

    return 0;
}
