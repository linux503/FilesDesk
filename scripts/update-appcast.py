#!/usr/bin/env python3
"""Insert a Sparkle appcast item for a GitHub Release zip."""
from __future__ import annotations

import argparse
import datetime as dt
import pathlib
import re

ROOT = pathlib.Path(__file__).resolve().parents[1]
FEED = ROOT / "docs" / "appcast.xml"


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--tag", required=True)
    parser.add_argument("--marketing", required=True)
    parser.add_argument("--build", required=True)
    parser.add_argument("--url", required=True)
    parser.add_argument("--signature", required=True)
    parser.add_argument("--length", required=True)
    args = parser.parse_args()

    pub = dt.datetime.now(dt.timezone.utc).strftime("%a, %d %b %Y %H:%M:%S +0000")
    notes = f"https://linux503.github.io/FilesDesk/changelog.html#{args.marketing}"
    item = f"""    <item>
      <title>FilesDesk {args.marketing}</title>
      <pubDate>{pub}</pubDate>
      <sparkle:version>{args.build}</sparkle:version>
      <sparkle:shortVersionString>{args.marketing}</sparkle:shortVersionString>
      <sparkle:releaseNotesLink>{notes}</sparkle:releaseNotesLink>
      <enclosure
        url="{args.url}"
        sparkle:edSignature="{args.signature}"
        length="{args.length}"
        type="application/octet-stream" />
    </item>
"""
    xml = FEED.read_text()
    xml = re.sub(r"(<language>en</language>\n)", r"\1" + item, xml, count=1)
    FEED.write_text(xml)
    print(f"appcast updated for {args.tag}")


if __name__ == "__main__":
    main()
