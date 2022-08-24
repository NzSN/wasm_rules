load(":make_script.bzl", "make_library_script")

def _wasm_library_impl(ctx):
    tool = ctx.toolchains["//wasm_toolchain:emcc_toolchain"]

    hdrs = []
    srcs = [src for src in ctx.files.srcs]
    dep_outputs = []
    copts = [copt for copt in ctx.attr.copts]
    input_files = ctx.files.srcs + ctx.files.deps
    libfile = ctx.actions.declare_file(ctx.attr.name + ".a")
    libdirs = []
    includedir = []

    for dep in ctx.attr.deps:
        # Collect output of dependences
        dep_outputs += dep[OutputGroupInfo].outputs.to_list()

        # Handle dep hdrs
        hdrs = dep[OutputGroupInfo].include.to_list()
        input_files += hdrs

        # Add include paths
        incs = dep[OutputGroupInfo].include_dir.to_list()
        for inc in incs:
            copts.append("-I%s" % inc.path)
        includedir += incs

        libdirs += dep[OutputGroupInfo].lib_dir.to_list()

    srcs += dep_outputs
    script_text = make_library_script(tool, srcs, ctx.files.deps, copts, libfile)

    ctx.actions.run_shell(
        inputs = input_files,
        outputs = [libfile],
        command = script_text,
        use_default_shell_env = True,
    )

    return [DefaultInfo(files = depset([libfile] + ctx.files.hdrs + hdrs, transitive = [depset(ctx.files.deps)])),
            OutputGroupInfo(outputs = depset([libfile], transitive = [depset(dep_outputs)]),
                            lib_dir = depset(libdirs),
                            include_dir = depset(includedir),
                            include = depset(ctx.files.hdrs, transitive=[depset(hdrs)]))]

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
