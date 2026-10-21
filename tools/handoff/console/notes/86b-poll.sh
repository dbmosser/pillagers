#!/bin/bash
# 86b-pix-ground: wait until the game file is committed again (my STOP left it patched), then print the log
cd "/c/claudecode/dark raiders" || exit 1
for i in $(seq 1 180); do
  if [ -z "$(git status --porcelain dark_raiders.html)" ]; then echo "clean at $(date +%T)"; git log --oneline -3; exit 0; fi
  sleep 20
done
echo "still dirty at $(date +%T)"
