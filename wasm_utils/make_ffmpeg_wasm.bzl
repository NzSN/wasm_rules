
SUPPORT_FEATURES = [ "mp3mp4", "apng", "webm" ]

def _script_configure(root_dir, features):
    script = []

    features = [
        feature for feature in features
        if feature in SUPPORT_FEATURES]

    if len(features) > 0:
       # Disable all features
       script.append("sed -i -r '/run-all()/,/main/ s/(build-.*)/#\\1/' build.sh")
       script.append("sed -i -r 's/#build-ffmpeg/build-ffmpeg/' build.sh")
       script.append("(cd wasm/build-scripts/; \
                       sed -i -r 's/(--enable-gpl)/--disable-everything\\n\\1/' configure-ffmpeg.sh; \
                       sed -i -r 's/(--enable-.*)/#\\1/' configure-ffmpeg.sh)")

    for feature in features:
        script.append(configures[feature]())

    script_text = ("(cd %s; cp .build.sh build.sh; cp .configure-ffmpeg.sh wasm/build-scripts/configure-ffmpeg.sh; " % root_dir) + "; \\\n".join(script) + ")"

    return script_text

def _configure_mp3mp4():
    return "sed -i -r 's/#(build-(zlib|x264|lame|fdk-aac|vorbis|opus|ogg))/\\1/' build.sh; \
            (cd wasm/build-scripts; \
             sed -i -r 's/#(--enable-(gpl|nonfree|zlib|libx264|libmp3lame|libfdk-aac|libvorbis|libopus))/\\1/' configure-ffmpeg.sh; \
             sed -i '/--enable-gpl/ i --enable-muxer=mp3,mp4,adts \\n\
                                      --enable-demuxer=mp3,mov,matroska \\n\
                                      --enable-encoder=libx264,libmp3lame,aac* \\n\
                                      --enable-decoder=h264*,mp3,aac*,ac3*,opus,vorbis \\n\
                                      --enable-filter=abuffer,amix,abuffersink,aresample,aformat,atrim,adelay,aloop,volume,asetpts,afade \\n\
                                      --enable-protocol=file' configure-ffmpeg.sh)"

def _configure_apng():
    pass

def _configure_webm():
    pass


def _make_ffmpeg_wasm_impl(ctx):
    libs = [
         "libavformat", "libavcodec", "libavdevice", "libavfilter",
         "libavutil", "libpostproc", "libswresample", "libswscale",
    ]
    include_root = ctx.actions.declare_directory("include")
    lib_dir = ctx.actions.declare_directory("lib")
    third_party = ctx.actions.declare_directory("third_party")

    build_file = ctx.expand_location("$(locations build.sh)")
    ffmpeg_root = "/".join(build_file.split("/")[0:-1])

    script = [
        # Reset repository to default status
        "(cd $(dirname \"$1\"); git reset --hard HEAD)"
    ]

    # Configure ffmpeg
    if len(ctx.features) > 0:
       script.append(_script_configure(ffmpeg_root, ctx.features))

    # Build Script
    script.append("set -euo pipefail; (cd $(dirname \"$1\"); ./build.sh)")
    for lib in libs:
        script.append(
            "cp $(dirname \"$1\")/" + lib + "/" + lib + ".a " + lib_dir.path
        )
    script.append("cp $(dirname \"$1\")/build/lib/*.a " + third_party.path)

    for lib in libs:
        script.append("cp -r $(dirname \"$1\")/" + lib + " " + include_root.path)

    script_text = "\n".join(script)

    outputs = [lib_dir, third_party, include_root]

    ctx.actions.run_shell(
        inputs = ctx.files.srcs,
        outputs = outputs,
        command = script_text,
        arguments = [build_file],
        use_default_shell_env = True,
        progress_message = "Build ffmpeg.wasm-core",
    )

    return [DefaultInfo(files = depset(outputs)),
            OutputGroupInfo(outputs = depset([]),
                            include_dir = depset([include_root]),
                            lib_dir = depset([third_party, lib_dir]),
                            include = depset([]))]


make_ffmpeg_wasm = rule(
    implementation = _make_ffmpeg_wasm_impl,
    attrs = {
        "srcs": attr.label_list(allow_files = True),
    }
)


configures = {
    "mp3mp4" : _configure_mp3mp4,
    "apng"   : _configure_apng,
    "webm"   : _configure_webm,
}
