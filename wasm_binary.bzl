def _wasm_binary_impl(ctx):
    jsfile = ctx.actions.declare_file(ctx.files.out[0].basename + ".js")
    wasmfile = ctx.actions.declare_file(ctx.files.out[0].basename + ".wasm")

    args=""

    for f in ctx.files.srcs:
        if (f.basename.split(".")[-1] != "h"):
           args += f.path + " "
        print(f.path)

    for f in ctx.files.deps:
        # Collect *.a
        args += f.path + " "

    args += "-o apngmerge.js"

    command = "emcc {}; mv apngmerge.js {}; mv apngmerge.wasm {}".format(args, jsfile.path, wasmfile.path)

    ctx.actions.run_shell(
        inputs = ctx.files.srcs,
        outputs = [jsfile, wasmfile],
        command = command,
        use_default_shell_env = True,
        execution_requirements = {
            "no-sandbox": "1",
            "local": "1",
        },

    )

    return [DefaultInfo(files = depset([jsfile, wasmfile]))]


wasm_binary = rule(
    implementation = _wasm_binary_impl,
    attrs = {
        "srcs": attr.label_list(allow_files = True),
        "deps": attr.label_list(allow_files = True),
        "out": attr.label(allow_single_file = True)
    }
)
