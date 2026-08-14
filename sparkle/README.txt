FilesDesk Sparkle keys
======================

eddsa-public.key   committed, also stored as SUPublicEDKey in Info.plist
eddsa-private.key  local only — gitignored

Keep a backup of the private key. If it is lost, existing app builds cannot
verify new updates until users install a build with a new public key.

GitHub Actions expects the secret SPARKLE_EDDSA_PRIVATE_KEY to contain the
same base64 private key as eddsa-private.key.
