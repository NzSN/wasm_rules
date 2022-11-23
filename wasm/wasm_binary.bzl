load(":make_script.bzl", "make_library_script")
load(":make_script.bzl", "make_binary_script")

def _is_wasm(file):
    return file.basename.split(".")[-1] == "wasm"

def _wasm_binary_impl(ctx):

    tool = ctx.toolchains["//wasm_toolchain:emcc_toolchain"]

    script = []
    srcs   = []
    copts  = [copt for copt in ctx.attr.copts]
    inputs = ctx.files.srcs + ctx.files.deps + ctx.files.hdrs

    deps   = ctx.files.deps
    out_js_file = ctx.actions.declare_file(ctx.attr.name + ".js")
    out_wasm_file = ctx.actions.declare_file(ctx.attr.name + ".wasm")

    # Collect source files
    srcs = [src for src in ctx.files.srcs]

    # Collect headers
    hdrs = [] + ctx.files.hdrs
    for dep in ctx.attr.deps:
        hdrs += dep[OutputGroupInfo].include.to_list()
        srcs += dep[OutputGroupInfo].outputs.to_list()

    script_text = make_binary_script(
        tool, srcs, ctx.attr.deps, copts, out_js_file)

    ctx.actions.run_shell(
        inputs = inputs,
        outputs = [out_js_file, out_wasm_file],
        command = script_text,
        use_default_shell_env = True,
    )

    return [DefaultInfo(files = depset([out_js_file, out_wasm_file]))]


wasm_binary = rule(
    implementation = _wasm_binary_impl,
    attrs = {
        "srcs": attr.label_list(allow_files = True),
        "hdrs": attr.label_list(allow_files = True),
        "deps": attr.label_list(),
        "copts": attr.string_list(),
    },
    toolchains = ["//wasm_toolchain:emcc_toolchain"],
)
