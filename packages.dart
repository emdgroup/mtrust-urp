import 'dart:convert';
import 'dart:io';

import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec/pubspec.dart';
import 'package:yaml_modify/yaml_modify.dart';

final subPackages = [
  "mtrust_urp_ble_strategy",
  "mtrust_urp_core",
  "mtrust_urp_usb_strategy",
  "mtrust_urp_virtual_strategy",
  "mtrust_urp_wifi_strategy",
  "mtrust_urp_ui"
];

void main(List<String> args) {
  bool local = args.firstOrNull == "local";

  final packageVersion =
      jsonDecode(File("package.json").readAsStringSync())["version"] as String;

  final version = VersionConstraint.parse("^$packageVersion");

  for (var subPackage in subPackages) {
    final pubSpecFile = File("$subPackage/pubspec.yaml");
    var pubSpec = PubSpec.fromYamlString(pubSpecFile.readAsStringSync());

    final root = subPackage.split("/").map((e) => "..").join("/");

    for (final dependency in pubSpec.dependencies.entries) {
      if (subPackages.contains(dependency.key)) {
        if (local) {
          pubSpec.dependencies[dependency.key] = PathReference(
            "$root/${dependency.key}",
          );
        } else {
          pubSpec.dependencies[dependency.key] = HostedReference(version);
        }
      }
    }

    for (final dependency in pubSpec.devDependencies.entries) {
      if (subPackages.contains(dependency.key)) {
        if (local) {
          pubSpec.devDependencies[dependency.key] = PathReference(
            "$root/${dependency.key}",
          );
        } else {
          pubSpec.devDependencies[dependency.key] = HostedReference(version);
        }
      }
    }

    final json = pubSpec.toJson();

    json["version"] = packageVersion;

    pubSpecFile.writeAsStringSync(toYamlString(json));
  }
}
