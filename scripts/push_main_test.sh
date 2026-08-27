#!/usr/bin/env bash

set -euo pipefail

repository_root="$(git rev-parse --show-toplevel)"
script="$repository_root/scripts/push_main.sh"
test_root="$(mktemp -d)"
trap 'rm -rf "$test_root"' EXIT

configure_repository() {
  git -C "$1" config user.name "AltiveChat Test"
  git -C "$1" config user.email "test@altive.co.jp"
}

run_push_main() {
  local repository="$1"
  (
    cd "$repository"
    bash "$script"
  )
}

create_fixture() {
  local name="$1"
  local bare="$test_root/$name.git"
  local seed="$test_root/$name-seed"
  local client="$test_root/$name-client"

  git init --bare --initial-branch=main "$bare" >/dev/null
  git init --initial-branch=main "$seed" >/dev/null
  configure_repository "$seed"
  echo "initial" >"$seed/README.md"
  git -C "$seed" add README.md
  git -C "$seed" commit -m "test: 初期commit" >/dev/null
  git -C "$seed" remote add origin "$bare"
  git -C "$seed" push origin main >/dev/null
  git clone "$bare" "$client" >/dev/null 2>&1
  configure_repository "$client"

  printf '%s\n' "$client"
}

success_client="$(create_fixture success)"
echo "local" >>"$success_client/README.md"
git -C "$success_client" add README.md
git -C "$success_client" commit -m "test: local commit" >/dev/null
run_push_main "$success_client"
test "$(git -C "$success_client" rev-parse HEAD)" = \
  "$(git --git-dir="$test_root/success.git" rev-parse refs/heads/main)"

dirty_client="$(create_fixture dirty)"
echo "dirty" >>"$dirty_client/README.md"
if dirty_output="$(run_push_main "$dirty_client" 2>&1)"; then
  echo "未コミット差分があるpushを拒否しませんでした。" >&2
  exit 1
fi
echo "$dirty_output"
grep -q "未コミット差分があります" <<<"$dirty_output"

diverged_client="$(create_fixture diverged)"
diverged_other="$test_root/diverged-other"
git clone "$test_root/diverged.git" "$diverged_other" >/dev/null 2>&1
configure_repository "$diverged_other"
echo "remote" >>"$diverged_other/README.md"
git -C "$diverged_other" add README.md
git -C "$diverged_other" commit -m "test: remote commit" >/dev/null
git -C "$diverged_other" push origin main >/dev/null
echo "local" >"$diverged_client/local.txt"
git -C "$diverged_client" add local.txt
git -C "$diverged_client" commit -m "test: local commit" >/dev/null
if diverged_output="$(run_push_main "$diverged_client" 2>&1)"; then
  echo "divergeしたpushを拒否しませんでした。" >&2
  exit 1
fi
echo "$diverged_output"
grep -q "behind=1, ahead=1" <<<"$diverged_output"

echo "push_mainの安全確認テストに成功しました。"
