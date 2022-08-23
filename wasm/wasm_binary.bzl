load(":make_script.bzl", "make_library_script")
load(":make_script.bzl", "make_binary_script")

def _is_wasm(file):
    return file.basename.split(".")[-1] == "wasm"

def _wasm_binary_impl(ctx):

    tool = ctx.toolchains["//wasm_toolchain:emcc_toolchain"]

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

    deps_ = [dep[DefaultInfo].files.to_list()[0] for dep in ctx.attr.deps]

    script_text = make_binary_script(
        tool, srcs, ctx.attr.deps, ctx.attr.copts, out_js_file)

    ctx.actions.run_shell(
        inputs = ctx.files.srcs + deps_,
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
        "deps": attr.label_list(),
        "copts": attr.string_list(),
    },
    toolchains = ["//wasm_toolchain:emcc_toolchain"],
)
