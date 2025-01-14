/* Utility to work with all packages
  
  dart run packages.dart 
    install - Install all packages dependencies
    test - Run tests in all packages
    analyze - Analyze all packages
    set-deps [local] - Set all packages dependencies to local or hosted
    update-urp-types - Update all packages dependencies to the latest version of mtrust_urp_types
*/
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec/pubspec.dart';
import 'package:yaml_modify/yaml_modify.dart';

List<String> changedPackagesOnly() {
  final result = Process.runSync("git", "diff --name-only --cached".split(" "));

  if (result.exitCode != 0) {
    print("Error running git diff --name-only --cached");
    exit(result.exitCode);
  }

  final changedPackages = <String>[];

  LineSplitter.split(result.stdout as String).forEach((line) {
    if (line.startsWith("mtrust_urp_")) {
      changedPackages.add(line.split("/").first);
    }
  });

  return changedPackages;
}

final subPackages = [
  "mtrust_urp_ble_strategy",
  "mtrust_urp_core",
  "mtrust_urp_usb_strategy",
  "mtrust_urp_virtual_strategy",
  "mtrust_urp_wifi_strategy",
  "mtrust_urp_ui"
];

void runAll(String cmd, List<String> args,
    {Set<String> exclude = const {}, bool changedOnly = false}) {
  final packages = changedOnly ? changedPackagesOnly() : subPackages;

  for (var subPackage in packages.where((e) => !exclude.contains(e))) {
    print("> Running $cmd ${args.join(" ")} in $subPackage");
    final result = Process.runSync(cmd, args, workingDirectory: subPackage);

    if (result.exitCode != 0) {
      print("Error running $cmd ${args.join(" ")} in $subPackage");

      exit(result.exitCode);
    }
  }
}

void install(bool changedOnly) {
  runAll("flutter", ["pub", "get"], changedOnly: changedOnly);
}

void test(bool changedOnly) {
  runAll("flutter", ["test"], changedOnly: changedOnly);
}

void analyze(bool changedOnly) {
  runAll("flutter", ["analyze"], changedOnly: changedOnly);
}

void updateUrpTypes() {
  runAll("flutter", ["pub", "upgrade", "mtrust_urp_types"],
      exclude: {"mtrust_urp_ui"});
}

void setDependencies(bool local) {
  if (local) {
    print("Setting all packages dependencies to local");
  } else {
    print("Setting all packages dependencies to hosted");
  }

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

    if (local) {
      json["publish_to"] = "none";
    } else {
      json.remove("publish_to");
    }

    pubSpecFile.writeAsStringSync(toYamlString(json));
  }
}

void main(List<String> args) {
  var parser = ArgParser();

  parser.addFlag("changed-only", abbr: "c", defaultsTo: false);

  parser.addCommand("install");
  parser.addCommand("test");
  parser.addCommand("analyze");
  final setDeps = parser.addCommand("set-deps");
  setDeps.addOption("source", abbr: "s", allowed: ["local", "hosted"]);

  parser.addCommand("update-urp-types");

  var results = parser.parse(args);

  if (results.command != null) {
    switch (results.command!.name) {
      case "install":
        install(results.flag("changed-only"));
        break;
      case "test":
        test(results.flag("changed-only"));
        break;
      case "analyze":
        analyze(results.flag("changed-only"));
        break;
      case "set-deps":
        setDependencies(results.command!["source"] == "local");
        break;
      case "update-urp-types":
        updateUrpTypes();
        break;
    }
    return;
  }
  print("Invalid command");

  print(parser.usage);
}
