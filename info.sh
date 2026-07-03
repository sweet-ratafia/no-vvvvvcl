#!/usr/bin/env bash
set -u

echo "----DRY----"
turbo run build --dry-run=json > /tmp/dry.json 2>/dev/null
cat /tmp/dry.json

echo "----PUT----"
API="https://vercel.com/api"
TEAM="$VERCEL_ARTIFACTS_OWNER"
TOKEN="$VERCEL_ARTIFACTS_TOKEN"
HASH="f1eaf1ff7346677f"

mkdir -p public/
echo "hihihi" > public/index.html
tar -cf artifact.tar -C /vercel/path0 app/web/dist app/web/.turbo/turbo-build.log public/
zstd -f artifact.tar

curl -sS -X PUT \
  "$API/v8/artifacts/$HASH?teamId=$TEAM" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/octet-stream" \
  -H "x-artifact-duration: 0" \
  --data-binary @artifact.tar.zst \
  -w 'PUT HTTP %{http_code}\n'

echo "----EXISTS (HEAD)----"
curl -sS -I \
  "$API/v8/artifacts/$HASH?teamId=$TEAM" \
  -H "Authorization: Bearer $TOKEN" \
  -w 'HEAD HTTP %{http_code}\n'

echo "----GET----"
curl -sS \
  "$API/v8/artifacts/$HASH?teamId=$TEAM" \
  -H "Authorization: Bearer $TOKEN" \
  -w '\nGET HTTP %{http_code}\n'

mkdir -p public && echo done > public/index.html