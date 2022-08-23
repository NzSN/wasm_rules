
def emcc_compile(tool, srcs, copts, output):
    info = tool.emccinfo

    script = []
    script.append("%s %s" % (info.compiler_path, " ".join(copts)))
    script.append("%s" % " ".join([src.path for src in srcs]))

    if output != None:
       script.append("-o %s" % output.path)

    return " ".join(script)

def make_library_script(tool, srcs, deps, copts, libfile):
    tool_info = tool

    script_texts = []

    # Compile object file
    script_texts.append(emcc_compile(tool, srcs, copts + ["-c"], None))

    # Extract objects from deps
    for dep in deps:
        script_texts.append("emar x %s" % dep.path)

    # Build archive
    script_texts.append("emar rcs %s *.o" % libfile.path)

    script_text = ";".join(script_texts)

    return script_text

def make_binary_script(tool, srcs, dep_targets, copts, libfile):
    tool_info = tool.emccinfo

    script_texts = []

    # Handle dependencies
    for dep in dep_targets:
        output = dep[DefaultInfo].files.to_list()[0]
        srcs = srcs + [output]

    # Build binary
    script_texts.append(emcc_compile(tool, srcs, copts, libfile))

    text = "; \\\n".join(script_texts)
    print(text)

    return text
