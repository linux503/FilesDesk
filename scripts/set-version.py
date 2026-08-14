#!/usr/bin/env python3
import argparse
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
PBX = ROOT / "FilesDesk.xcodeproj" / "project.pbxproj"


def read_versions():
    text = PBX.read_text()
    marketing = re.search(r"MARKETING_VERSION = ([0-9.]+);", text)
    build = re.search(r"CURRENT_PROJECT_VERSION = ([0-9]+);", text)
    if not marketing or not build:
        sys.exit("Could not read versions from project.pbxproj")
    return marketing.group(1), int(build.group(1))


def set_versions(marketing: str, build: int):
    text = PBX.read_text()
    text = re.sub(r"MARKETING_VERSION = [0-9.]+;", f"MARKETING_VERSION = {marketing};", text)
    text = re.sub(r"CURRENT_PROJECT_VERSION = [0-9]+;", f"CURRENT_PROJECT_VERSION = {build};", text)
    PBX.write_text(text)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("marketing", nargs="?")
    parser.add_argument("--bump-build", action="store_true")
    args = parser.parse_args()
    current_marketing, current_build = read_versions()
    marketing = args.marketing or current_marketing
    build = current_build + 1 if args.bump_build else current_build
    set_versions(marketing, build)
    print(f"{marketing} ({build})")


if __name__ == "__main__":
    main()
