
def _make_ffmpeg_wasm_impl(ctx):
    libs = [
         "libavformat", "libavcodec", "libavdevice", "libavfilter",
         "libavutil", "libpostproc", "libswresample", "libswscale",
    ]
    include_root = ctx.actions.declare_directory("include")
    lib_dir = ctx.actions.declare_directory("lib")
    third_party = ctx.actions.declare_directory("third_party")

    # Build Script
    build_file = ctx.expand_location("$(locations build-with-docker.sh)")
    script = ["set -euo pipefail; (cd $(dirname \"$1\"); ./build-with-docker.sh)"]
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
        execution_requirements = {
            "local": "1",
        },
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
