#!/bin/sh
# davidmullett.com — build stamp.
#
# Cloudflare Pages exposes CF_PAGES_COMMIT_SHA and CF_PAGES_BRANCH to the build
# command. This script writes them into every page's <head> and into
# /version.json, so that "is the deploy live?" is answered by a fetch rather
# than by reading prose.
#
# Pages project settings this requires (dashboard, not repo):
#   Build command:            sh build.sh
#   Build output directory:   /
#
# Without a build command set, none of this runs and no stamp is emitted.
#
# version.json is generated here and gitignored on purpose. A hand-maintained
# version file is worse than none: it lies with confidence.

set -eu

COMMIT="${CF_PAGES_COMMIT_SHA:-unknown}"
BRANCH="${CF_PAGES_BRANCH:-unknown}"
BUILT="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

printf '{\n  "commit": "%s",\n  "branch": "%s",\n  "built": "%s"\n}\n' \
  "$COMMIT" "$BRANCH" "$BUILT" > version.json

# Inject the stamp into every HTML page. og-card.html is a render source for the
# social image, not a served page, so it is skipped.
for f in *.html; do
  [ -f "$f" ] || continue
  [ "$f" = "og-card.html" ] && continue
  # Idempotent: strip any stamp from a previous run before inserting.
  sed -i.bak -e '/<meta name="build-commit"/d' -e '/<meta name="build-time"/d' "$f"
  sed -i.bak "s|</head>|<meta name=\"build-commit\" content=\"$COMMIT\">\\
<meta name=\"build-time\" content=\"$BUILT\">\\
</head>|" "$f"
  rm -f "$f.bak"
  echo "stamped $f"
done

echo "build-commit $COMMIT  branch $BRANCH  built $BUILT"
