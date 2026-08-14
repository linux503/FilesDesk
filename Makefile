.PHONY: build test universal release icons

icons:
	bash scripts/generate-icons.sh

build:
	xcodebuild -project FilesDesk.xcodeproj -scheme FilesDesk -destination "platform=macOS" -configuration Debug CODE_SIGN_IDENTITY=- build

universal:
	xcodebuild -project FilesDesk.xcodeproj -scheme FilesDesk -destination "generic/platform=macOS" -configuration Release ARCHS="arm64 x86_64" ONLY_ACTIVE_ARCH=NO CODE_SIGN_IDENTITY=- -derivedDataPath build/DerivedData build
	lipo -archs build/DerivedData/Build/Products/Release/FilesDesk.app/Contents/MacOS/FilesDesk

test:
	xcodebuild test -project FilesDesk.xcodeproj -scheme FilesDesk -destination "platform=macOS" -configuration Debug CODE_SIGN_IDENTITY=-

release:
	@test -n "$(VERSION)" || (echo "make release VERSION=1.0.1" && false)
	bash scripts/release.sh $(VERSION)
