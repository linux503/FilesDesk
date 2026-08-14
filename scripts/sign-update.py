#!/usr/bin/env python3
"""Create a Sparkle EdDSA signature for an update archive."""
from __future__ import annotations

import base64
import sys
from pathlib import Path

from nacl.signing import SigningKey


def main() -> None:
    if len(sys.argv) != 3:
        sys.exit("usage: sign-update.py <private-key-file> <archive>")
    secret = base64.b64decode(Path(sys.argv[1]).read_text().strip())
    seed = secret[:32]
    data = Path(sys.argv[2]).read_bytes()
    signature = SigningKey(seed).sign(data).signature
    print(base64.b64encode(signature).decode("ascii"))


if __name__ == "__main__":
    main()
