### Bazel Playground

Try locally

1. Install bazelisk `brew install bazelisk`
2. Build a bazel binary
   with `bazelisk b -c opt //src:bazel //tools/android/runtime_deps:android_tools.tar.gz`
3. Copy `bazel-bin/src/bazel` to this repo's `tools/bazel`
4. Extract android tools to `tools/android`
   with `tar -xf bazel-bin/tools/android/runtime_deps/android_tools.tar.gz -C <path to this repo>/bazel-playground/tools/android`
5. Use `bazelisk query //...` to find targets to build.