
def _make_ffmpeg_wasm_impl(ctx):
    libs = [
         "libavformat", "libavcodec", "libavdevice", "libavfilter",
         "libavutil", "libpostproc", "libswresample", "libswscale",
    ]
    out_files = []
    include_root = ctx.actions.declare_directory("include")

    for lib in libs:
        out_files.append(ctx.actions.declare_file(lib+".a"))

    third_party = ctx.actions.declare_directory("third_party")

    # Build Script
    build_file = ctx.expand_location("$(locations build-with-docker.sh)")
    script = ["(cd $(dirname \"$1\"); ./build-with-docker.sh)"]
    for file in out_files:
        script.append(
            "cp $(dirname \"$1\")/" + \
                file.basename.split(".")[0] + "/" + \
                file.basename + " " + \
                file.path
        )
    script.append("cp $(dirname \"$1\")/build/lib/* " + third_party.path)

    for lib in libs:
        script.append("cp -r $(dirname \"$1\")/" + lib + " " + include_root.path)

    script_text = "\n".join(script)

    ctx.actions.run_shell(
        inputs = ctx.files.srcs,
        outputs = out_files + [third_party] + [include_root],
        command = script_text,
        arguments = [build_file],
        use_default_shell_env = True,
        execution_requirements = {
            "local": "1",
        },
        progress_message = "Build ffmpeg.wasm-core",
    )

    return [DefaultInfo(files = depset(out_files + [include_root] + [third_party])),
            OutputGroupInfo(include = depset([include_root]),
                            lib = depset([third_party]))]


make_ffmpeg_wasm = rule(
    implementation = _make_ffmpeg_wasm_impl,
    attrs = {
        "srcs": attr.label_list(allow_files = True),
    }
)
