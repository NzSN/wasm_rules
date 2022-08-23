load(":make_script.bzl", "make_library_script")

def _wasm_library_impl(ctx):
    tool = ctx.toolchains["//wasm_toolchain:emcc_toolchain"]

    hdrs = []
    srcs = ctx.files.srcs + ctx.files.deps
    libfile = ctx.actions.declare_file(ctx.attr.name + ".a")

    script_text = make_library_script(tool, srcs, ctx.files.deps, [], libfile)

    for dep in ctx.attr.deps:
        hdrs = hdrs + dep[OutputGroupInfo].include.to_list()

    ctx.actions.run_shell(
        inputs = srcs + hdrs,
        outputs = [libfile],
        command = script_text,
        use_default_shell_env = True,
    )

    return [DefaultInfo(files = depset([libfile])),
            OutputGroupInfo(include = ctx.files.hdrs)]

wasm_library = rule(
    implementation = _wasm_library_impl,
    attrs = {
        "srcs": attr.label_list(allow_files = True),
        "hdrs": attr.label_list(allow_files = True),
        "deps": attr.label_list(),
        "copts": attr.string_list(),
    },
    toolchains = ["//wasm_toolchain:emcc_toolchain"]
)
