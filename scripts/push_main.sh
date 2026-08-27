#!/usr/bin/env bash

set -euo pipefail

remote="${1:-origin}"
branch="${2:-main}"
repository_root="$(git rev-parse --show-toplevel)"
cd "$repository_root"

current_branch="$(git symbolic-ref --quiet --short HEAD || true)"
if [[ "$current_branch" != "$branch" ]]; then
  echo "push中止: 現在のbranchは '$current_branch' です。'$branch' から実行してください。" >&2
  exit 1
fi

if [[ -n "$(git status --porcelain=v1 --untracked-files=all)" ]]; then
  echo "push中止: 未コミット差分があります。commitまたはstashで保護してください。" >&2
  git status --short >&2
  exit 1
fi

git fetch --prune "$remote" "$branch"

remote_ref="refs/remotes/$remote/$branch"
if ! git show-ref --verify --quiet "$remote_ref"; then
  echo "push中止: '$remote/$branch' が見つかりません。" >&2
  exit 1
fi

read -r behind ahead < <(git rev-list --left-right --count "$remote/$branch...HEAD")
if [[ "$behind" != "0" ]]; then
  echo "push中止: '$branch' は '$remote/$branch' よりbehind=${behind}, ahead=${ahead}です。" >&2
  echo "既存差分を保護し、'$remote/$branch' へrebaseしてから再実行してください。" >&2
  exit 1
fi

if [[ "$ahead" == "0" ]]; then
  echo "push不要: '$branch' は '$remote/$branch' と一致しています。"
  exit 0
fi

local_head="$(git rev-parse HEAD)"
git push --porcelain "$remote" "HEAD:refs/heads/$branch"

remote_head="$(git ls-remote "$remote" "refs/heads/$branch" | awk '{print $1}')"
if [[ "$remote_head" != "$local_head" ]]; then
  echo "push失敗: remote HEAD ($remote_head) がlocal HEAD ($local_head) と一致しません。" >&2
  exit 1
fi

echo "push完了: $remote/$branch = $local_head"
