    
#!/bin/bash
set -e

# Download tmate static binary (no root needed)
curl -fsSL https://github.com/tmate-io/tmate/releases/download/2.4.0/tmate-2.4.0-static-linux-amd64.tar.xz \
  | tar xJ --strip-components=1
chmod +x tmate

# Start tmate session \u2014 connection strings appear in build logs
./tmate -S /tmp/tmate.sock new-session -d
./tmate -S /tmp/tmate.sock wait tmate-ready

echo "=== CONNECT VIA SSH ==="
./tmate -S /tmp/tmate.sock display -p '#{tmate_ssh}'
echo ""
echo "=== CONNECT VIA WEB ==="
./tmate -S /tmp/tmate.sock display -p '#{tmate_web}'
echo "========================"

# Keep container alive (Vercel build timeout is ~45min)
sleep 2700


