.PHONY: get get-example lint fix format test run clean

get:
	flutter pub get

get-example:
	flutter pub get --directory=example

lint:
	flutter analyze

fix:
	dart fix --apply

format:
	dart format lib test

test:
	flutter test

run:
	flutter run --directory=example

clean:
	flutter clean
	flutter clean --directory=example
