#!/usr/bin/env bash  
set -euo pipefail

COMMIT_MSG_FILE="${1:-}" 
COMMIT_MSG=$(cat $COMMIT_MSG_FILE)

_validate_commit_message() {
  if [ ! -f "$COMMIT_MSG_FILE" ]; then
      echo "❌ Error: Commit message file does not exist."
      exit 1
  fi
}

# types and structure for conventional commits
# https://www.conventionalcommits.org/en/v1.0.0/
# https://github.com/conventional-changelog/commitlint/#what-is-com/mitlint

check_commit_convention() {

  local commit_msg_file="$1"
  _validate_commit_message "$commit_msg_file"

  TYPES="feat|fix|chore|docs|test|style|refactor|perf|build|ci|revert"
  SCOPE="\(.+\)"

  echo "Commit message: $COMMIT_MSG"

  if ! echo "$COMMIT_MSG" | grep -qE "^($TYPES)($SCOPE)?:"; then
    echo "Error: Commit message must start with a valid type"
    echo -e "feat, fix, chore, docs, test, style, refactor, perf, build, ci, revert"
    echo -e "Format should be: <type>(optional scope): <description> \n"
    exit 1
  fi
}