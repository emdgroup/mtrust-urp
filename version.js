const fs = require("fs");
const path = require("path");
const yaml = require("yaml");

const version = require("./package.json").version;


fs.writeFileSync(path.join(__dirname, "mtrust_urp_core/lib/src/version.dart"), `///Version of the library\nString version = 'v${version}';\n`);


const pubspecs = [
    "mtrust_urp_core/pubspec.yaml",
    "mtrust_urp_ble_strategy/pubspec.yaml",
    "mtrust_urp_wifi_strategy/pubspec.yaml",
    "mtrust_urp_usb_strategy/pubspec.yaml",
    "mtrust_urp_virtual_strategy/pubspec.yaml",
    "mtrust_urp_ui/pubspec.yaml",
];

for (const pubspecPath of pubspecs) {

    const pubspec = yaml.parse(fs.readFileSync(path.join(__dirname, pubspecPath), "utf8"));

    pubspec.version = version;

    fs.writeFileSync(path.join(__dirname, pubspecPath), yaml.stringify(pubspec));

    console.log(`Wrote version ${version} to  ${pubspecPath}`);

}


// Make dependency on urp_core version specific

const strategies = [
    "mtrust_urp_ble_strategy/pubspec.yaml",
    "mtrust_urp_wifi_strategy/pubspec.yaml",
    "mtrust_urp_usb_strategy/pubspec.yaml",
    "mtrust_urp_virtual_strategy/pubspec.yaml",
    "mtrust_urp_ui/pubspec.yaml",
];

for (const strategyPath of strategies) {

    const pubspec = yaml.parse(fs.readFileSync(path.join(__dirname, strategyPath), "utf8"));

    pubspec.dependencies.mtrust_urp_core = {
        hosted: "https://merckgroup.jfrog.io/artifactory/api/pub/dice-mtrust-pub-dev-local",
        version: "^"+version
    }

    fs.writeFileSync(path.join(__dirname, strategyPath), yaml.stringify(pubspec));

    console.log(`Wrote dependency on urp_core ${version} to  ${strategyPath}`);
}



