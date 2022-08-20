def _wasm_binary_impl(ctx):
    tool = ctx.toolchains["//wasm_toolchain:emcc_toolchain"].emccinfo
    command = "%s" % (tool.compiler_path)
    print(command)


wasm_binary = rule(
    implementation = _wasm_binary_impl,
    attrs = {
        "srcs": attr.label_list(allow_files = True),
        "deps": attr.label_list(allow_files = True),
        "out": attr.label_list(allow_files = True),
    },
    toolchains = ["//wasm_toolchain:emcc_toolchain"],
)
