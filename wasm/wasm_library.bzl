load(":make_script.bzl", "make_library_script")

def _wasm_library_impl(ctx):
    tool = ctx.toolchains["//wasm_toolchain:emcc_toolchain"]

    libfile = ctx.actions.declare_file(ctx.attr.name + ".a")
    script_text = make_library_script(tool, ctx.files.srcs, [], libfile)

    runfiles = ctx.runfiles(files = ctx.files.srcs)

    for dep in ctx.attr.deps:
        runfiles = runfiles.merge(dep[DefaultInfo].default_runfiles)

    ctx.actions.run_shell(
        inputs = runfiles.files,
        outputs = [libfile],
        command = script_text,
        use_default_shell_env = True,
        execution_requirements = {
            "local": "1"
        }
    )

    return DefaultInfo(files = depset([libfile]),
						runfiles = runfiles)

wasm_library = rule(
    implementation = _wasm_library_impl,
    attrs = {
        "srcs": attr.label_list(allow_files = True),
        "deps": attr.label_list(),
        "copts": attr.string_list(),
    },
    toolchains = ["//wasm_toolchain:emcc_toolchain"]
)
