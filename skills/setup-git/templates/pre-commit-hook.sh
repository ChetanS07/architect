#!/bin/sh
# Secret scan of staged changes. Installed by setup-git.
# Never exits on success, so it is safe to insert anywhere in an existing hook.
if command -v gitleaks >/dev/null 2>&1; then
  gitleaks git --pre-commit --staged --redact --verbose || exit 1
else
  echo "pre-commit: gitleaks is not installed, secret scan skipped." >&2
  echo "Install it: https://github.com/gitleaks/gitleaks#installing" >&2
fi
