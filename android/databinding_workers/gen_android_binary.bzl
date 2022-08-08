"""
Generates a configurable android_binary target that uses Databinding
"""

_DATABINDING_DEPS = [
    "@maven//:androidx_annotation_annotation",
    "@maven//:androidx_databinding_databinding_adapters",
    "@maven//:androidx_databinding_databinding_common",
    "@maven//:androidx_databinding_databinding_runtime",
    "@maven//:androidx_databinding_viewbinding",
]

def _generate_manifest_xml(package_name):
    manifest_name = package_name.replace(".", "_") + "_manifest"
    manifest_file = "src/main/%s.xml" % manifest_name
    native.genrule(
        name = manifest_name,
        outs = [manifest_file],
        cmd = """
cat << EOF > AndroidManifest.xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="{package_name}">
</manifest>
EOF
cp AndroidManifest.xml $@
        """.format(package_name = package_name),
    )
    return manifest_file

def _layout_files(package_name, count):
    layouts = []
    for layout_index in range(count):
        layout_name = package_name.replace(".", "_") + "_layout_" + str(layout_index)
        layout_file = "src/main/res/layout/%s.xml" % layout_name
        native.genrule(
            name = layout_name,
            outs = [layout_file],
            cmd = """
cat << EOF > Layout.xml
<?xml version="1.0" encoding="utf-8"?>
<layout xmlns:android="http://schemas.android.com/apk/res/android">
    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:orientation="vertical">

        <FrameLayout
            android:id="@+id/mainActivityRoot"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:orientation="vertical" />
    </LinearLayout>
    <data>
        <import type="android.view.View" />
    </data>
</layout>
EOF
cp Layout.xml $@
        """.format(layout_file = layout_file),
        )
        layouts.append(layout_name)
    return layouts

def gen_android_binary(name, custom_package, libraries, layouts):
    """Generate a android databinding target with lot of library modules

    Args:
        name: Name of the target
    """
    package_name = custom_package

    no_of_libraries = libraries
    no_of_layouts = layouts

    deps = []
    for lib_index in range(no_of_libraries):
        lib_package_name = package_name + ".lib" + str(lib_index)
        lib_name = "library_" + str(lib_index)
        native.android_library(
            name = "library_" + str(lib_index),
            custom_package = lib_package_name,
            enable_data_binding = True,
            manifest = _generate_manifest_xml(lib_package_name),
            resource_files = _layout_files(lib_package_name, no_of_layouts),
            deps = _DATABINDING_DEPS,
        )
        deps.append(":" + lib_name)

    native.android_binary(
        name = name,
        custom_package = package_name,
        enable_data_binding = True,
        manifest = _generate_manifest_xml(package_name),
        manifest_values = {
            "versionCode": "1",
            "versionName": "1.0",
            "minSdkVersion": "21",
            "targetSdkVersion": "30",
            "applicationId": package_name,
        },
        multidex = "native",
        deps = deps + _DATABINDING_DEPS,
        visibility = [
            "//visibility:public",
        ],
    )
