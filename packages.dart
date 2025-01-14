import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec/pubspec.dart';
import 'package:yaml_modify/yaml_modify.dart';

void main(List<String> args) {
  var parser = ArgParser();

  parser.addFlag("changed-only", abbr: "c", defaultsTo: false);

  final runner = CommandRunner("packages", "Manage mtrust_urp packages")
    ..addCommand(SetDependenciesCmd())
    ..addCommand(UpdateUrpTypesCmd())
    ..addCommand(InstallCmd())
    ..addCommand(TestCmd())
    ..addCommand(AnalyzeCmd());

  runner.run(args).catchError((error) {
    if (error is! UsageException) throw error;
    print(error);
    exit(64); // Exit code 64 indicates a usage error.
  });
}

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

// Command definitions
class SetDependenciesCmd extends Command {
  @override
  String get name => "set-deps";

  @override
  String get description => "Set all packages dependencies to local or hosted";

  SetDependenciesCmd() {
    argParser.addOption("source", abbr: "s", allowed: ["local", "hosted"]);
  }

  @override
  Future<void> run() async {
    setDependencies(argResults?.option("source") == "local");
  }
}

class UpdateUrpTypesCmd extends Command {
  @override
  String get name => "update-urp-types";

  @override
  String get description => "Update mtrust_urp_types in all packages";

  @override
  Future<void> run() async {
    updateUrpTypes();
  }
}

class InstallCmd extends Command {
  @override
  String get name => "install";

  @override
  String get description => "Run flutter pub get in all packages";

  InstallCmd() {
    argParser.addFlag("changed-only", abbr: "c", defaultsTo: false);
  }

  @override
  Future<void> run() async {
    install(argResults!.flag("changed-only"));
  }
}

class TestCmd extends Command {
  @override
  String get name => "test";

  @override
  String get description => "Run flutter test in all packages";

  TestCmd() {
    argParser.addFlag("changed-only", abbr: "c", defaultsTo: false);
  }

  @override
  Future<void> run() async {
    test(argResults!.flag("changed-only"));
  }
}

class AnalyzeCmd extends Command {
  @override
  String get name => "analyze";

  @override
  String get description => "Run flutter analyze in all packages";

  AnalyzeCmd() {
    argParser.addFlag("changed-only", abbr: "c", defaultsTo: false);
  }

  @override
  Future<void> run() async {
    analyze(argResults!.flag("changed-only"));
  }
}
