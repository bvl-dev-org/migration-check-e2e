#!/bin/sh
# Checks the one BVL comment on this pull request (spec 7.2.9 acceptance, README section 7).
# Usage: scripts/expect-comment.sh reset|measured|revoked|http500|timeout   (needs GH_TOKEN, GITHUB_REPOSITORY, PR)
set -eu
body=$(gh api "repos/$GITHUB_REPOSITORY/issues/$PR/comments" --paginate --jq '.[] | select(.body | startswith("<!-- bvl-migration-check -->")) | .body')
count() { printf '%s\n' "$body" | grep -c -F -- "$1" || true; }
need() { [ "$(count "$1")" = "$2" ] || { echo "expect-comment $case: wanted $2 x '$1', got $(count "$1")"; printf '%s\n' "$body"; exit 1; }; }
case="$1"
if [ "$case" = reset ]; then
  for id in $(gh api "repos/$GITHUB_REPOSITORY/issues/$PR/comments" --paginate --jq '.[] | select(.body | startswith("<!-- bvl-migration-check -->")) | .id'); do
    gh api -X DELETE "repos/$GITHUB_REPOSITORY/issues/comments/$id"
  done
  echo "expect-comment: reset ok"
  exit 0
fi
need '<!-- bvl-migration-check -->' 1
case "$case" in
  measured)
    need '### BVL Migration check: 1 to fix before merge' 1
    need '| **Fix before merge** | `CREATE INDEX idx_orders_customer ON orders (customer_id)` |' 1
    need '| Applies at any size | `ALTER TABLE orders ADD COLUMN gift_note text` |' 1
    need '| Low impact at current size |' 2
    need '**Not analysed.**' 0
    need '**Not replayed.**' 0 ;;
  revoked) need '### BVL Migration check: not checked' 1; need 'BVL answered HTTP 401: This licence key is not valid. Create one at https://bvl.dev/app/repos.' 1 ;;
  http500) need '### BVL Migration check: not checked' 1; need 'BVL answered HTTP 500.' 1 ;;
  timeout) need '### BVL Migration check: not checked' 1; need 'The BVL engine did not answer within 30 seconds.' 1 ;;
  *) echo "unknown case $case"; exit 2 ;;
esac
[ "$case" = measured ] || need 'This check never blocks a merge when BVL cannot run.' 1
echo "expect-comment: $case ok"
