#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CX="$PROJECT_DIR/bin/codex-profile"
TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/codex-profile-test.XXXXXX")"
trap 'rm -rf "$TEST_ROOT"' EXIT

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

make_fake_codex() {
  local bin_dir="$1"
  mkdir -p "$bin_dir"
  printf '#!/usr/bin/env bash\nexit 0\n' > "$bin_dir/codex"
  chmod +x "$bin_dir/codex"
}

test_delete_rejects_session_referrer() {
  local root="$TEST_ROOT/delete"
  mkdir -p "$root/noah/sessions" "$root/api-jojo"
  ln -s "$root/noah/sessions" "$root/api-jojo/sessions"

  if CODEX_PROFILE_ROOT="$root" "$CX" delete noah >"$root/output" 2>&1; then
    fail "delete succeeded while api-jojo referenced noah"
  fi
  [[ -d "$root/noah" ]] || fail "delete removed referenced profile"
  grep -q 'api-jojo' "$root/output" || fail "delete error omitted referrer"
}

test_resume_rejects_dangling_source() {
  local root="$TEST_ROOT/dangling"
  mkdir -p "$root/noah" "$root/api-jojo"
  ln -s "$root/noah/sessions" "$root/api-jojo/sessions"

  if CODEX_PROFILE_ROOT="$root" "$CX" run noah resume-from api-jojo >"$root/output" 2>&1; then
    fail "resume-from accepted a dangling source link"
  fi
  [[ ! -e "$root/shared-api-jojo-noah" ]] || fail "resume-from created an empty shared profile"
  [[ ! -e "$root/noah/sessions" ]] || fail "resume-from changed the target sessions path"
  [[ -L "$root/api-jojo/sessions" ]] || fail "resume-from changed the source sessions link"
  grep -q 'dangling or cyclic' "$root/output" || fail "resume-from error was not actionable"
}

test_resume_consolidates_real_sessions() {
  local root="$TEST_ROOT/consolidate"
  local bin_dir="$TEST_ROOT/bin"
  mkdir -p "$root/noah/sessions" "$root/api-jojo"
  printf '{}\n' > "$root/noah/sessions/session.jsonl"
  ln -s "$root/noah/sessions" "$root/api-jojo/sessions"
  make_fake_codex "$bin_dir"

  PATH="$bin_dir:$PATH" CODEX_PROFILE_ROOT="$root" \
    "$CX" run noah resume-from api-jojo >/dev/null

  [[ -f "$root/shared-api-jojo-noah/sessions/session.jsonl" ]] \
    || fail "real sessions were not moved into the shared profile"
  [[ "$(readlink "$root/noah/sessions")" == "$root/shared-api-jojo-noah/sessions" ]] \
    || fail "target does not point at shared sessions"
  [[ "$(readlink "$root/api-jojo/sessions")" == "$root/shared-api-jojo-noah/sessions" ]] \
    || fail "source does not point at shared sessions"
}

test_resume_rejects_existing_shared_conflict() {
  local root="$TEST_ROOT/shared-conflict"
  mkdir -p "$root/noah/sessions" "$root/api-jojo" \
    "$root/shared-api-jojo-noah/sessions"
  printf '{"old":true}\n' > "$root/noah/sessions/old.jsonl"
  printf '{"other":true}\n' > "$root/shared-api-jojo-noah/sessions/other.jsonl"
  ln -s "$root/noah/sessions" "$root/api-jojo/sessions"

  if CODEX_PROFILE_ROOT="$root" "$CX" run noah resume-from api-jojo >"$root/output" 2>&1; then
    fail "resume-from accepted conflicting real and shared sessions"
  fi
  [[ -f "$root/noah/sessions/old.jsonl" ]] || fail "resume-from displaced real sessions"
  [[ -f "$root/shared-api-jojo-noah/sessions/other.jsonl" ]] \
    || fail "resume-from changed existing shared sessions"
  grep -q 'reconcile them manually' "$root/output" \
    || fail "shared conflict error was not actionable"
}

test_delete_rejects_session_referrer
test_resume_rejects_dangling_source
test_resume_consolidates_real_sessions
test_resume_rejects_existing_shared_conflict
printf 'All sessions safety tests passed.\n'
