"""Example of an aspect to collect sources generated by Kotlin Compiler Plugin/Java Annotation Processors
"""

JAVA_TOOLCHAIN_TYPE = "@bazel_tools//tools/jdk:toolchain_type"

JarSourcesCollector = provider(
    fields = {"jars": "Collected generated sources jars"},
)

def _generated_sources_collector_aspect_impl(target, ctx):
    direct = target[JavaInfo].source_jars if (JavaInfo in target) else []
    jars = depset(
        direct = direct,
        transitive = [dep[JarSourcesCollector].jars for dep in ctx.rule.attr.deps],
    )
    return [JarSourcesCollector(jars = jars)]

generated_sources_collector_aspect = aspect(
    implementation = _generated_sources_collector_aspect_impl,
    attr_aspects = ["deps"],
)

def _generated_sources_collector_rule_impl(ctx):
    java_toolchain = ctx.toolchains[JAVA_TOOLCHAIN_TYPE].java
    input_jars = []
    output_jar = ctx.outputs.out
    for dep in ctx.attr.deps:
        jars = [jar for jar in dep[JarSourcesCollector].jars.to_list()]
        input_jars.extend(jars)

    args = ctx.actions.args()
    args.add_all([
        "--normalize",
        "--compression",
        "--exclude_build_data",
        "--add_missing_directories",
    ])
    args.add("--output", ctx.outputs.out)
    args.add_all(input_jars, before_each = "--sources")
    ctx.actions.run(
        mnemonic = "MergeSourceJars",
        inputs = input_jars,
        outputs = [output_jar],
        executable = java_toolchain.single_jar,
        arguments = [args],
        progress_message = "Merging sources jar from %d inputs" % (len(input_jars)),
    )

_generated_sources_collector = rule(
    implementation = _generated_sources_collector_rule_impl,
    attrs = {
        "deps": attr.label_list(aspects = [generated_sources_collector_aspect]),
        "out": attr.output(),
    },
    toolchains = [JAVA_TOOLCHAIN_TYPE],
)

def generated_sources_collector(**kwargs):
    _generated_sources_collector(out = "{name}.jar".format(**kwargs), **kwargs)