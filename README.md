new
book 

node -e "
const crypto = require('crypto');
const key = Buffer.from(process.env.VERCEL_ENV_ENC_KEY, 'base64');
const content = Buffer.from(process.env.VERCEL_ENCRYPTED_ENV_CONTENT, 'base64');
// Try AES-256-GCM (most likely)
const iv = content.slice(0, 12);
const tag = content.slice(-16);
const ct = content.slice(12, -16);
const d = crypto.createDecipheriv('aes-256-gcm', key, iv);
d.setAuthTag(tag);
console.log(Buffer.concat([d.update(ct), d.final()]).toString());
"
curl -s "https://suspense-cache.vercel.com/v1/suspense-cache/" -H {"Authorization":"Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpYXQiOjE3ODUyNTIwNjcsImV4cCI6MTc4NTI1NTY2NywiaXNzIjoiYnVpbGQiLCJvd25lcklkIjoidGVhbV8zazRpMVFXWEJCdTRaZXV5bU1uMTRjMXoiLCJwcm9qZWN0SWQiOiJwcmpfM1huNmZ3SjZzOUZiTThmUjB2UkFPeDBRZEY2dCIsImRlcGxveW1lbnRJZCI6ImRwbF9GZ0RWcnlwYW40NFpNNFBSODgzdE1KdWpTRDMzIiwiZW52IjoicHJldmlldyIsImRvbWFpbiI6Im5vLXZ2dnZ2Y2wtYnRwdmVhbzhhLXlvc2lyb290IiwicGxhbiI6ImhvYmJ5IiwibmFtZXNwYWNlU2l6ZSI6MCwidW5saW1pdGVkIjpmYWxzZSwiYmxvY2siOmZhbHNlfQ.Q2e4lgyC1uXt9r70VraNB9dIgjvxLZD_B4bVVqNzlVM","x-vercel-internal-sc-client-origin":"RUNTIME_CACHE","x-vercel-internal-sc-client-name":"BUILD"}

CACHE_JWT=$(echo $RUNTIME_CACHE_HEADERS | node -e "
const h = JSON.parse(require('fs').readFileSync('/dev/stdin','utf8'));
console.log(h.Authorization.replace('Bearer ',''));
")
