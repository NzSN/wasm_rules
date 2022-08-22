load(":make_script.bzl", "make_library_script")

def _wasm_library_impl(ctx):
    tool = ctx.toolchains["//wasm_toolchain:emcc_toolchain"]

    libfile = ctx.actions.declare_file(ctx.attr.name + ".a")
    script_text = make_library_script(tool, ctx.files.srcs, [], libfile)

    runfiles_files = ctx.files.srcs

    for dep in ctx.attr.deps:
        dep_runfiles = dep[OutputGroupInfo]._hidden_top_level_INTERNAL_.to_list()
        runfiles_files = runfiles_files + dep_runfiles
    
    runfiles = ctx.runfiles(files = runfiles_files)

    ctx.actions.run_shell(
        inputs = runfiles_files,
        outputs = [libfile],
        command = script_text,
        use_default_shell_env = True,
        execution_requirements = {
            "local": "1"
        }
    )

    return [DefaultInfo(files = depset([libfile], transitive = [depset(ctx.files.deps)]),
						runfiles = runfiles)]

wasm_library = rule(
    implementation = _wasm_library_impl,
    attrs = {
        "srcs": attr.label_list(allow_files = True),
        "deps": attr.label_list(allow_files = True),
        "copts": attr.string_list(),
    },
    toolchains = ["//wasm_toolchain:emcc_toolchain"]
)
