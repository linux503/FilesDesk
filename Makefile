.PHONY: build test release icons

build:
	xcodebuild -project FilesDesk.xcodeproj -scheme FilesDesk -destination "platform=macOS" -configuration Debug CODE_SIGN_IDENTITY=- build

test:
	xcodebuild test -project FilesDesk.xcodeproj -scheme FilesDesk -destination "platform=macOS" -configuration Debug CODE_SIGN_IDENTITY=-

release:
	@test -n "$(VERSION)" || (echo "make release VERSION=1.0.1" && false)
	bash scripts/release.sh $(VERSION)
