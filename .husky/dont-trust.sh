# Verify if the commit is signed, why not?

# -1 is the first log message
# G means "good valid signature", N no signature, https://git-scm.com/docs/git-log#Documentation/git-log.txt-emGem


VERIFY_SIGNING=$(git log -1 --pretty=%G?)

if [[ "$VERIFY_SIGNING" != 'G' && "$VERIFY_SIGNING" != 'E' ]]; then
    echo "Error: Commit is not signed 💔. Please sign your commit."
    exit 1
fi

echo "Commit signed! 🔑"
