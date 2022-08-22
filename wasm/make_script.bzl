
def make_library_script(tool, srcs, copts, libfile):
    tool_info = tool.emccinfo
    script = []
    script.append("%s" % tool_info.compiler_path)

    # Compile all sources into object file
    script.append("-c")

    # Add compile options
    for copt in copts:
        script.append(copt)

    # Add source files
    for src in srcs:
        script.append(src.path)

    script.append(";")
    script.append("emar rcs %s *.o" % libfile.path)

    script_text = " ".join(script)

    return script_text
