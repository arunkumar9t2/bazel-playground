workspace(name = "bazel_playground")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

RULES_JVM_EXTERNAL_TAG = "4.2"

RULES_JVM_EXTERNAL_SHA = "cd1a77b7b02e8e008439ca76fd34f5b07aecb8c752961f9640dea15e9e5ba1ca"

http_archive(
    name = "rules_jvm_external",
    sha256 = RULES_JVM_EXTERNAL_SHA,
    strip_prefix = "rules_jvm_external-%s" % RULES_JVM_EXTERNAL_TAG,
    url = "https://github.com/bazelbuild/rules_jvm_external/archive/%s.zip" % RULES_JVM_EXTERNAL_TAG,
)

load("@rules_jvm_external//:defs.bzl", "maven_install")

maven_install(
    artifacts = [
        "com.google.dagger:dagger:2.41",
        "com.google.dagger:dagger-compiler:2.41",
        "com.google.dagger:dagger-producers:2.41",
        "com.squareup.anvil:compiler:2.4.0",
        "com.squareup.anvil:annotations:2.4.0",
        "dev.arunkumar:scabbard-processor:0.5.0",
        "androidx.databinding:databinding-adapters:7.1.2",
        "androidx.databinding:databinding-common:7.1.2",
        "androidx.databinding:databinding-compiler:7.1.2",
        "androidx.databinding:databinding-runtime:7.1.2",
        "javax.inject:javax.inject:1",
        "junit:junit:4.13",
    ],
    excluded_artifacts = [
        "org.jetbrains.kotlin:kotlin-stdlib",
        "org.jetbrains.kotlin:kotlin-stdlib-jdk8",
        "org.jetbrains.kotlin:kotlin-stdlib-jdk7",
        "org.jetbrains.kotlin:kotlin-compiler-embeddable",
        "org.jetbrains.kotlin:kotlin-reflect",
        "org.jetbrains.kotlin:kotlin-script-runtime",
    ],
    repositories = [
        "https://maven.google.com",
        "https://jcenter.bintray.com/",
        "https://repo1.maven.org/maven2",
    ],
)

RULES_KOTLIN_VERSION = "1.7.0-RC-3"

RULES_KOTLIN_SHA = "f033fa36f51073eae224f18428d9493966e67c27387728b6be2ebbdae43f140e"

http_archive(
    name = "io_bazel_rules_kotlin",
    sha256 = RULES_KOTLIN_SHA,
    urls = ["https://github.com/bazelbuild/rules_kotlin/releases/download/v%s/rules_kotlin_release.tgz" % RULES_KOTLIN_VERSION],
)

load("@io_bazel_rules_kotlin//kotlin:repositories.bzl", "kotlin_repositories")

kotlin_repositories()

load("@io_bazel_rules_kotlin//kotlin:core.bzl", "kt_register_toolchains")

kt_register_toolchains()

android_sdk_repository(
    name = "androidsdk",
    api_level = 30,
    build_tools_version = "30.0.2",
)

android_ndk_repository(
    name = "androidndk",
    api_level = 30,
)

bind(
    name = "databinding_annotation_processor",
    actual = "//tools/databinding:databinding_annotation_processor",
)
