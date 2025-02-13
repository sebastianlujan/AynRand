#!/usr/bin/env bash
set -euo pipefail

# Verify if the commit is signed, why not?

# -1 is the first log message
# G means "good valid signature", N no signature, https://git-scm.com/docs/git-log#Documentation/git-log.txt-emGem

dont_trust() {
    echo "🔏 Verifying commit signature..."

    # Check GPG signature configuration
     if ! git config --get user.signingkey >/dev/null; then
        echo "❌ No GPG signing key configured"
        
        echo "Run: git config --global user.signingkey YOUR_KEY_ID"
        echo "1. Generate a key: gpg --full-generate-key"
        echo "2. List keys: gpg --list-secret-keys --keyid-format LONG"
        echo "3. Configure Git: git config --global user.signingkey YOUR_KEY_ID"
        exit 1
    fi

    # Check if commit signing is enabled
    if [ "$(git config --get commit.gpgsign)" != "true" ]; then
        echo "❌ Error: Commit signing not enabled"
        echo "Run: git config --global commit.gpgsign true"
        exit 1
    fi

    # https://git-scm.com/docs/git-log#Documentation/git-log.txt-emGem
    # Get detailed signing information
    VERIFY_SIGNING=$(git log -1 --pretty=%G?)

    if [[ "$VERIFY_SIGNING" != 'G']]; then
        echo "❌ Error: Commit is not signed"
        echo "Please sign your commit with a valid GPG key."
        echo "Run: git config --global commit.gpgsign true"
        exit 1
    fi

    echo "🔑 Commit signed!"
    echo "✅ Valid signature from: ${SIGNER_INFO}
}