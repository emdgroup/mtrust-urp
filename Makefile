run_demo: pub_demo
	cd urp_demo &&  flutter run

pub_demo:
	cd urp_demo && flutter pub get

local: install
	dart packages.dart local


analyze: 
	
	@ cd mtrust_urp_ble_strategy && flutter analyze
	@ cd mtrust_urp_core && flutter analyze
	@ cd mtrust_urp_usb_strategy && flutter analyze
	@ cd mtrust_urp_virtual_strategy && flutter analyze
	@ cd mtrust_urp_wifi_strategy && flutter analyze
	@ cd mtrust_urp_ui && flutter analyze

install:
	npm i

dependencies: 
	@ cd mtrust_urp_ble_strategy && flutter pub get
	@ cd mtrust_urp_core && flutter pub get
	@ cd mtrust_urp_usb_strategy && flutter pub get
	@ cd mtrust_urp_virtual_strategy && flutter pub get
	@ cd mtrust_urp_wifi_strategy && flutter pub get
	@ cd mtrust_urp_ui && flutter pub get