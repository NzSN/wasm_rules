# wasm_rules

bazel build //examples/ffmpeg:app --platforms=//wasm_toolchain:wasm64 --sandbox_writable_path=/ --action_env=EMSDK=/home/.../.emsdk
