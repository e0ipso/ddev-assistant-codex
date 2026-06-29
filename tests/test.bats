#!/usr/bin/env bats

# Bats is a testing framework for Bash
# Documentation https://bats-core.readthedocs.io/en/stable/
# Bats libraries documentation https://github.com/ztombol/bats-docs

# For local tests, install bats-core, bats-assert, bats-file, bats-support
# And run this in the add-on root directory:
#   bats ./tests/test.bats
# To exclude release tests:
#   bats ./tests/test.bats --filter-tags '!release'
# For debugging:
#   bats ./tests/test.bats --show-output-of-passing-tests --verbose-run --print-output-on-failure

setup() {
  set -eu -o pipefail

  # Override this variable for your add-on:
  export GITHUB_REPO=e0ipso/ddev-assistant-codex

  TEST_BREW_PREFIX="$(brew --prefix 2>/dev/null || true)"
  export BATS_LIB_PATH="${BATS_LIB_PATH:-}:${TEST_BREW_PREFIX}/lib:/usr/lib/bats"
  bats_load_library bats-assert
  bats_load_library bats-file
  bats_load_library bats-support

  export DIR="$(cd "$(dirname "${BATS_TEST_FILENAME}")/.." >/dev/null 2>&1 && pwd)"
  export PROJNAME="test-$(basename "${GITHUB_REPO}")"
  mkdir -p "${HOME}/tmp"
  export TESTDIR="$(mktemp -d "${HOME}/tmp/${PROJNAME}.XXXXXX")"
  export TEST_MARKER="$(basename "${TESTDIR}")"
  export TEST_HOST_CODEX_MARKER="${HOME}/.codex/${TEST_MARKER}.txt"
  export TEST_HOST_CODEX_AUTH="${HOME}/.codex/auth.json"
  export TEST_CREATED_CODEX_AUTH=false
  export DDEV_NONINTERACTIVE=true
  export DDEV_NO_INSTRUMENTATION=true
  ddev delete -Oy "${PROJNAME}" >/dev/null 2>&1 || true
  cd "${TESTDIR}"
  run ddev config --project-name="${PROJNAME}" --project-tld=ddev.site
  assert_success
  run ddev start -y
  assert_success
}

prepare_host_codex_auth() {
  mkdir -p "${HOME}/.codex"
  if [ ! -e "${TEST_HOST_CODEX_AUTH}" ] && [ ! -L "${TEST_HOST_CODEX_AUTH}" ]; then
    printf '{"ddev_assistant_codex_test":"%s"}\n' "${TEST_MARKER}" >"${TEST_HOST_CODEX_AUTH}"
    export TEST_CREATED_CODEX_AUTH=true
  fi
}

prepare_host_codex_config() {
  prepare_host_codex_auth
  printf 'seeded config from %s\n' "${TEST_MARKER}" >"${TEST_HOST_CODEX_MARKER}"
}

health_checks() {
  # Verify Codex is installed at /usr/local/bin and is executable
  run ddev exec "test -f /usr/local/bin/codex"
  assert_success

  # Verify codex is accessible and on PATH
  run ddev exec "codex --version"
  assert_success

  # Verify host Codex config is mounted as a read-only seed.
  run ddev exec "test -d ~/.cred-seed/codex"
  assert_success

  run ddev exec "test -f ~/.cred-seed/codex/auth.json"
  assert_success

  # Verify runtime Codex config is seeded from the host config.
  run ddev exec "test -f ~/.codex/auth.json"
  assert_success

  # Verify runtime config directory is owned by the web user (not root).
  run ddev exec "stat -c '%U' ~/.codex"
  assert_success
  refute_output "root"

  # Verify runtime config is writable by the web user.
  run ddev exec "test -w ~/.codex"
  assert_success

  run ddev exec "printf '{\"test\":\"writable\"}\n' > ~/.codex/auth.json"
  assert_success

}

seed_mirror_checks() {
  # Verify host config is mounted only in the seed area and copied into the
  # writable runtime path.
  run ddev exec "test -f ~/.cred-seed/codex/${TEST_MARKER}.txt"
  assert_success

  run ddev exec "test -f ~/.codex/${TEST_MARKER}.txt"
  assert_success

  run ddev exec "grep -F 'seeded config from ${TEST_MARKER}' ~/.cred-seed/codex/${TEST_MARKER}.txt"
  assert_success

  run ddev exec "grep -F 'seeded config from ${TEST_MARKER}' ~/.codex/${TEST_MARKER}.txt"
  assert_success

  # Verify restart-time mirroring deletes container-only files.
  run ddev exec "touch ~/.codex/container-only-${TEST_MARKER}.txt"
  assert_success

  run ddev restart -y
  assert_success

  run ddev exec "test ! -e ~/.codex/container-only-${TEST_MARKER}.txt"
  assert_success
}

teardown() {
  set -eu -o pipefail
  ddev delete -Oy "${PROJNAME}" >/dev/null 2>&1
  rm -f "${TEST_HOST_CODEX_MARKER}"
  if [ "${TEST_CREATED_CODEX_AUTH}" = true ]; then
    rm -f "${TEST_HOST_CODEX_AUTH}"
  fi
  # Persist TESTDIR if running inside GitHub Actions. Useful for uploading test result artifacts
  # See example at https://github.com/ddev/github-action-add-on-test#preserving-artifacts
  if [ -n "${GITHUB_ENV:-}" ]; then
    [ -e "${GITHUB_ENV:-}" ] && echo "TESTDIR=${HOME}/tmp/${PROJNAME}" >> "${GITHUB_ENV}"
  else
    [ "${TESTDIR}" != "" ] && rm -rf "${TESTDIR}"
  fi
}

@test "install from directory" {
  set -eu -o pipefail
  echo "# ddev add-on get ${DIR} with project ${PROJNAME} in $(pwd)" >&3
  prepare_host_codex_config
  run ddev add-on get "${DIR}"
  assert_success
  run ddev restart -y
  assert_success
  health_checks
  seed_mirror_checks
}

# bats test_tags=release
@test "install from release" {
  set -eu -o pipefail
  echo "# ddev add-on get ${GITHUB_REPO} with project ${PROJNAME} in $(pwd)" >&3
  prepare_host_codex_auth
  run ddev add-on get "${GITHUB_REPO}"
  assert_success
  run ddev restart -y
  assert_success
  health_checks
}
