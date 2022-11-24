
def _wasm_deploy_impl(ctx):
    target = ctx.attr.target
    shell_commands = ""

    for s in ctx.files.srcs:
        shell_commands += "echo Copying %s to %s\n" % (s.short_path, target)
        shell_commands += "mkdir -p %s\n" % (target)
        shell_commands += "cp -p %s %s\n" % (s.short_path, target)

    ctx.actions.write(
        output = ctx.outputs.executable,
        is_executable = True,
        content = shell_commands,
    )
    runfiles = ctx.runfiles(files = ctx.files.srcs)
    return DefaultInfo(
        executable = ctx.outputs.executable,
        runfiles = runfiles,
    )

wasm_deploy = rule(
    executable = True,
    implementation = _wasm_deploy_impl,
    attrs = {
        "srcs": attr.label_list(allow_files = True),
        "target": attr.string(doc = "Deployment target directory"),
    }
)
