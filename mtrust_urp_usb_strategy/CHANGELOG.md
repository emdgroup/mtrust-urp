# Changelog

All notable changes to this project will be documented in this file. See [commit-and-tag-version](https://github.com/absolute-version/commit-and-tag-version) for commit guidelines.

## [9.1.0-10](https://github.com/emdgroup/mtrust-urp/compare/v9.1.0-9...v9.1.0-10) (2025-06-10)

## [9.1.0-9](https://github.com/emdgroup/mtrust-urp/compare/v9.1.0-8...v9.1.0-9) (2025-06-06)

## [9.1.0-8](https://github.com/emdgroup/mtrust-urp/compare/v9.1.0-7...v9.1.0-8) (2025-06-06)

## [9.1.0-7](https://github.com/emdgroup/mtrust-urp/compare/v9.1.0-6...v9.1.0-7) (2025-06-06)


### Bug Fixes

* add exception for mtu sizes smaller than 512 bytes ([7de8532](https://github.com/emdgroup/mtrust-urp/commit/7de8532dfe9a874b737a7bc4f5e8eddc1086386d))
* check mtu size after connection ([5937c0e](https://github.com/emdgroup/mtrust-urp/commit/5937c0e22c63c1f394afc0dd76a39a7b254a28b4))

## [9.1.0-6](https://github.com/emdgroup/mtrust-urp/compare/v9.0.1...v9.1.0-6) (2025-06-04)


### Features

* add an example for development of the urp ui ([3acf7f2](https://github.com/emdgroup/mtrust-urp/commit/3acf7f270892abaa7c68a4018122d8e31f1207ef))
* clean up last connected UI, SEC preview with gradient cut-off ([29fdc26](https://github.com/emdgroup/mtrust-urp/commit/29fdc26857ed72fa8e9005c5fe5dcae5e2658d54))
* liquid flutter 22 ([#27](https://github.com/emdgroup/mtrust-urp/issues/27)) ([1628255](https://github.com/emdgroup/mtrust-urp/commit/1628255b7a64a8634f917e76059465e5fa495b07))


### Bug Fixes

*  versioning uses wrong action path ([#31](https://github.com/emdgroup/mtrust-urp/issues/31)) ([4c6a1a3](https://github.com/emdgroup/mtrust-urp/commit/4c6a1a38b8a05dd89b2adf877854cccbe2183302))
* adjust chunk size according to actual mtu size ([b6845af](https://github.com/emdgroup/mtrust-urp/commit/b6845af13abbe7a83b2b61470082a089abf7c589))
* crop the reader using the png source file to prevent flickering ([de0cfb5](https://github.com/emdgroup/mtrust-urp/commit/de0cfb580fe8d6b0df5fe015a91fd91c4439fb55))
* prevent split frame submit button showing ([1fd701b](https://github.com/emdgroup/mtrust-urp/commit/1fd701be3e8715005a7918e12b06a49fac9a70eb))
* publish dependencies ([#34](https://github.com/emdgroup/mtrust-urp/issues/34)) ([7f6399e](https://github.com/emdgroup/mtrust-urp/commit/7f6399e4b13f13fc2331baa01c3ff5bdca9449b3))
* publish dependencies ([#35](https://github.com/emdgroup/mtrust-urp/issues/35)) ([b9ae8df](https://github.com/emdgroup/mtrust-urp/commit/b9ae8df4555726d7a923e0f91f7f6487e9e9ba24))

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
