load("//wasm_utils:utils.bzl", "is_archive")

def emcc_compile(tool, srcs, copts, output):
    info = tool.emccinfo

    script = []
    script.append("set -euo pipefail; %s %s" % (info.compiler_path, " ".join(copts)))
    script.append("%s" % " ".join([src.path for src in srcs]))

    if output != None:
       script.append("-o %s" % output.path)

    return " ".join(script)

def make_library_script(tool, srcs, deps, copts, libfile):
    tool_info = tool

    script_texts = []

    srcs = [f for f in srcs if not is_archive(f) and f.is_source]

    # Compile object file
    script_texts.append(emcc_compile(tool, srcs, copts + ["-c"], None))
    script_texts.append("emar rcs %s *.o" % libfile.path)
    script_text = ";".join(script_texts)

    return script_text

def make_binary_script(tool, srcs, dep_targets, copts, libfile):
    tool_info = tool.emccinfo

    copts_ = [copt for copt in copts]
    script_texts = []

    # Handle dependencies
    for dep in dep_targets:
        # Handle include path
        include_dirs = dep[OutputGroupInfo].include_dir.to_list()
        for dir in include_dirs:
            copts_.append("-I%s" % dir.path)

        # Handle link path
        link_paths = dep[OutputGroupInfo].lib_dir.to_list()
        for lpath in link_paths:
            copts_.append("-L%s" % lpath.path)

    # Build binary
    script_texts.append(emcc_compile(tool, srcs, copts_, libfile))

    text = "; \\\n".join(script_texts)

    return text
