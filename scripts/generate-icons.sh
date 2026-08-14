#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
swift "$ROOT/scripts/generate-icons.swift" "$ROOT"
