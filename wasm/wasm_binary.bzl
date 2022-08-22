
def _is_wasm(file):
    return file.basename.split(".")[-1] == "wasm"

def _wasm_binary_impl(ctx):

    tool = ctx.toolchains["//wasm_toolchain:emcc_toolchain"].emccinfo

    script = []
    srcs   = []
    deps   = ctx.files.deps
    out_js_file = ctx.actions.declare_file(ctx.attr.name + ".js")
    out_wasm_file = ctx.actions.declare_file(ctx.attr.name + ".wasm")

    # Collect source files
    for src in ctx.files.srcs:
        ext = src.basename.split(".")[-1]
        if ext == "c" or ext == "cc":
            srcs.append(src)

    script.append("%s" % tool.compiler_path)

    # Add source files
    for src in srcs:
        script.append(src.path)

    # Add deps
    for dep in deps:
        script.append(dep.path)

    # Add link compile opts
    for copt in ctx.attr.copts:
        script.append(copt)

    # Add output flag
    script.append("-o %s" % out_js_file.path)

    script_text = " ".join(script)

    ctx.actions.run_shell(
        inputs = ctx.files.srcs,
        outputs = [out_js_file, out_wasm_file],
        command = script_text,
        use_default_shell_env = True,
        execution_requirements = {
            "local": "1"
        }
    )

    return [DefaultInfo(files = depset([out_js_file, out_wasm_file]))]


wasm_binary = rule(
    implementation = _wasm_binary_impl,
    attrs = {
        "srcs": attr.label_list(allow_files = True),
        "deps": attr.label_list(allow_files = True),
        "copts": attr.string_list(),
    },
    toolchains = ["//wasm_toolchain:emcc_toolchain"],
)
