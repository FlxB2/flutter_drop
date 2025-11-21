default:
	just --list

run:
	cd example && \
	flutter run -d macos

release:
	cd example && flutter run -d macos --release

profile:
	cd example && flutter run -d macos --profile

observe:
	cd example && flutter run -d macos --observe

build:
	cd example && flutter build macos

dependencies:
	cd example && flutter packages get

update:
	cd example && flutter pub outdated
