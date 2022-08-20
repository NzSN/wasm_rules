EMCCInfo = provider(
    doc = "Information about how to use emcc compiler",
    fields = ["compiler_path"],
)

def _emcc_toolchain_impl(ctx):
    toolchain_info = platform_common.ToolchainInfo(
        emccinfo = EMCCInfo(
            compiler_path = ctx.attr.compiler_path,
        )
    )

    return [toolchain_info]

emcc_toolchain = rule(
    implementation = _emcc_toolchain_impl,
    attrs = {
        "compiler_path": attr.string(),
    }
)
