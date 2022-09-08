"""
Generates a configurable android_binary target
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

_ASSETS_DIR = "src/main/assets"

def _generate_assets(package_name):
    asset_name = package_name.replace(".", "_") + "_asset"
    asset_file = "%s/%s.xml" % (_ASSETS_DIR, asset_name)
    native.genrule(
        name = asset_name,
        outs = [asset_file],
        cmd = """
cat << EOF > asset.txt
package="{package_name}">
EOF
cp asset.txt $@
            """.format(package_name = package_name),
    )
    return [asset_file]

def _layout_files(package_name, count, enable_data_binding):
    layouts = []
    content = """<?xml version="1.0" encoding="utf-8"?>
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
    """ if enable_data_binding else """<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical">

    <FrameLayout
        android:id="@+id/mainActivityRoot"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="vertical" />
</LinearLayout>
    """
    for layout_index in range(count):
        layout_name = package_name.replace(".", "_") + "_layout_" + str(layout_index)
        layout_file = "src/main/res/layout/%s.xml" % layout_name
        native.genrule(
            name = layout_name,
            outs = [layout_file],
            cmd = """
cat << EOF > Layout.xml
{content}
EOF
cp Layout.xml $@
        """.format(content = content),
        )
        layouts.append(layout_name)
    return layouts

def _values_files(package_name, count):
    values = []
    for value_index in range(count):
        value_name = package_name.replace(".", "_") + "_value_" + str(value_index)
        value_file = "src/main/res/values/%s.xml" % value_name
        native.genrule(
            name = value_name,
            outs = [value_file],
            cmd = """
cat << EOF > Values.xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="{value_name}">Test</string>
</resources>
EOF
cp Values.xml $@
        """.format(value_name = value_name),
        )
        values.append(value_name)
    return values

def gen_android_binary(
        name,
        custom_package,
        enable_data_binding,
        libraries,
        layouts,
        resources = 10):
    """Generate a android databinding target with lot of library modules

    Args:
        name: Name of the target
    """
    package_name = custom_package

    no_of_libraries = libraries
    no_of_layouts = layouts
    no_of_values = resources

    deps = []
    for lib_index in range(no_of_libraries):
        lib_package_name = package_name + ".lib" + str(lib_index)
        lib_name = "library_" + str(lib_index)
        native.android_library(
            name = "library_" + str(lib_index),
            custom_package = lib_package_name,
            enable_data_binding = enable_data_binding,
            assets_dir = _ASSETS_DIR,
            assets = _generate_assets(lib_package_name),
            manifest = _generate_manifest_xml(lib_package_name),
            resource_files = _layout_files(lib_package_name, no_of_layouts, enable_data_binding) +
                             _values_files(lib_package_name, no_of_values),
            deps = _DATABINDING_DEPS,
        )
        deps.append(":" + lib_name)

    native.android_binary(
        name = name,
        custom_package = package_name,
        enable_data_binding = enable_data_binding,
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
