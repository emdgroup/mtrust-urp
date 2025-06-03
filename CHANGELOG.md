# Changelog

All notable changes to this project will be documented in this file. See [commit-and-tag-version](https://github.com/absolute-version/commit-and-tag-version) for commit guidelines.

## [9.2.0](https://github.com/emdgroup/mtrust-urp/compare/v9.0.1...v9.2.0) (2025-05-11)


### Features

* add an example for development of the urp ui ([3acf7f2](https://github.com/emdgroup/mtrust-urp/commit/3acf7f270892abaa7c68a4018122d8e31f1207ef))
* clean up last connected UI, SEC preview with gradient cut-off ([29fdc26](https://github.com/emdgroup/mtrust-urp/commit/29fdc26857ed72fa8e9005c5fe5dcae5e2658d54))


### Bug Fixes

* prevent split frame submit button showing ([1fd701b](https://github.com/emdgroup/mtrust-urp/commit/1fd701be3e8715005a7918e12b06a49fac9a70eb))

## [9.0.1](https://github.com/emdgroup/mtrust-urp/compare/v9.0.0...v9.0.1) (2025-03-28)


### Bug Fixes

* history ([0103bde](https://github.com/emdgroup/mtrust-urp/commit/0103bdef24140a0d825dfaea7c95667a543faec9))
* Version issue ([40d1682](https://github.com/emdgroup/mtrust-urp/commit/40d1682392692c876863b20a9001d6f861154046))

## [9.0.0](https://github.com/emdgroup/mtrust-urp/compare/bdc12b041f825b1dcb304117c46f44bff329dd5f...v9.0.0) (2025-03-28)


### ⚠ BREAKING CHANGES

* BREAKING CHANGE: change CmdWrapper to abstract class
* all methods in CmdWrapper now return the UrpCoreCommand

### Features

* add commit-check job to GitHub Actions workflow ([21d674d](https://github.com/emdgroup/mtrust-urp/commit/21d674d71b6e5bc9668f47f3f1cff3c616d8f7e8))
* add package_checker script and integrate into publish workflow ([8bca03b](https://github.com/emdgroup/mtrust-urp/commit/8bca03b056f6f968e8925f1e457dc2523b414837))
* api exception ([165f83a](https://github.com/emdgroup/mtrust-urp/commit/165f83a4c23ae3b1464c824b66179119c85ddee3))
* token ([#7](https://github.com/emdgroup/mtrust-urp/issues/7)) ([062f221](https://github.com/emdgroup/mtrust-urp/commit/062f221a114a13cddc8deba451d204fdc67421b7))


### Bug Fixes

* API Exception ([090a6bc](https://github.com/emdgroup/mtrust-urp/commit/090a6bc3446d41b1fac7213ceb2a80aa909f51d4))
* API Service status code ([49cd860](https://github.com/emdgroup/mtrust-urp/commit/49cd860b33abbe0e2c3886b76c80409a8701acba))
* BREAKING CHANGE: change CmdWrapper to abstract class ([bbdccdf](https://github.com/emdgroup/mtrust-urp/commit/bbdccdfd2ea5857fa0683a8d9a00192a2cb05725))
* clean up logging ([1e5bee7](https://github.com/emdgroup/mtrust-urp/commit/1e5bee7e73f0d2d16e211dad432bf6e2a9043514))
* empty-commit ([5fc6e6e](https://github.com/emdgroup/mtrust-urp/commit/5fc6e6e97bb1a8112c432da4d5a020a83a85ac37))
* remove adding commands to queue as they need to be wrapped in a device specific command wrapper ([73bfa3a](https://github.com/emdgroup/mtrust-urp/commit/73bfa3ac0aed88b950b553756989d19644891f76))
* remove adding commands to queue as they need to be wrapped in a device specific command wrapper ([bdc12b0](https://github.com/emdgroup/mtrust-urp/commit/bdc12b041f825b1dcb304117c46f44bff329dd5f))
* remove ChargingStationCmdWrapper ([ffa56b5](https://github.com/emdgroup/mtrust-urp/commit/ffa56b5dc51bf24d80a470002deb2920d17756db))
* status code ([ed18fff](https://github.com/emdgroup/mtrust-urp/commit/ed18fff949c0ed50a49a86764f58976bf8f20d79))
* validation of urp-core ([#8](https://github.com/emdgroup/mtrust-urp/issues/8)) ([21fdc6b](https://github.com/emdgroup/mtrust-urp/commit/21fdc6b56e42601d4d82de31abce103a6f760de7))
