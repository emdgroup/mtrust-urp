import 'dart:io';

import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec/pubspec.dart';
import 'package:yaml_modify/yaml_modify.dart';

final subPackages = [
  "mtrust_urp_ble_strategy",
  "mtrust_urp_core",
  "mtrust_urp_usb_strategy",
  "mtrust_urp_wifi_strategy",
  "mtrust_urp_virtual_strategy",
];

void main(List<String> args) {
  var version = args.firstOrNull ?? "";

  for (var subPackage in subPackages) {
    final pubSpecFile = File("$subPackage/pubspec.yaml");
    final pubSpec = PubSpec.fromYamlString(pubSpecFile.readAsStringSync());

    if (pubSpec.dependencies.keys.contains("mtrust-urp-types")) {
      pubSpec.dependencies["mtrust_urp_types"] = ExternalHostedReference(
        "mtrust_urp_types",
        "https://merckgroup.jfrog.io/artifactory/api/pub/dice-mtrust-pub-dev-local",
        VersionConstraint.parse(version),
      );
    }

    final json = pubSpec.toJson();
    json["version"] = version.toString();
    pubSpecFile.writeAsStringSync(toYamlString(json));
  }
}
