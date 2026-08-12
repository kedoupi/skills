#!/usr/bin/env bash
# Register an existing product skill directory as a git submodule of the parent incubator.
set -euo pipefail

INCUBATOR_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
DEFAULT_OWNER="kedoupi"

usage() {
  cat <<'EOF'
Usage:
  scripts/register-submodule.sh <repo-dir> [--owner <github-owner>] [--url <git-url>]

Registers Skills/<repo-dir> as a submodule of the parent incubator repo.

Typical flow (after new-skill.sh + GitHub remote exists and was pushed):
  bash scripts/register-submodule.sh my-feature-skill

Requirements:
  - Parent incubator is a git repo (kedoupi/skills)
  - Child dir exists, is its own git repo, has a remote (or pass --url)
  - Child has been pushed at least once if you pass only owner/path defaults

Does NOT force-push. Safe to re-run only if path is not already a submodule.
EOF
}

if [[ $# -lt 1 || "$1" == "-h" || "$1" == "--help" ]]; then
  usage
  exit 0
fi

REPO_DIR="$1"
shift
OWNER="$DEFAULT_OWNER"
URL=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --owner)
      OWNER="$2"
      shift 2
      ;;
    --url)
      URL="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

cd "$INCUBATOR_ROOT"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Parent is not a git repo. Init the incubator first (kedoupi/skills)." >&2
  exit 1
fi

TARGET="${INCUBATOR_ROOT}/${REPO_DIR}"
if [[ ! -d "$TARGET" ]]; then
  echo "Missing directory: $TARGET" >&2
  exit 1
fi
if [[ ! -d "${TARGET}/.git" && ! -f "${TARGET}/.git" ]]; then
  echo "Not a git repo: $TARGET (run new-skill.sh or git init first)" >&2
  exit 1
fi

if [[ -z "$URL" ]]; then
  # Prefer child's origin
  if URL_FROM_CHILD="$(git -C "$TARGET" remote get-url origin 2>/dev/null)"; then
    URL="$URL_FROM_CHILD"
  else
    URL="git@github.com:${OWNER}/${REPO_DIR}.git"
  fi
fi

if git config --file .gitmodules --get-regexp "path" 2>/dev/null | grep -qE " ${REPO_DIR}\$"; then
  echo "Already registered in .gitmodules: $REPO_DIR" >&2
  exit 1
fi

# If path is a normal nested repo inside parent, convert carefully:
# 1) remember remote URL
# 2) remove from index if tracked
# 3) move aside, submodule add, restore is not needed when add clones fresh
#
# When the directory already exists with content, `git submodule add` fails.
# Standard approach: deinit path → use submodule absorbgitdirs pattern, or:
#   mv dir dir.bak && git submodule add URL dir && ...
# Here we require the child remote to already exist and use:
#   git submodule add --force is dangerous; use explicit move.

TMP_BACKUP=""
cleanup() {
  if [[ -n "$TMP_BACKUP" && -d "$TMP_BACKUP" && ! -e "$TARGET" ]]; then
    mv "$TMP_BACKUP" "$TARGET"
  fi
}
trap cleanup EXIT

if [[ -e "$TARGET" ]]; then
  # Ensure parent is not tracking nested content incorrectly
  git rm -rf --cached "$REPO_DIR" 2>/dev/null || true
  TMP_BACKUP="${INCUBATOR_ROOT}/.submodule-register-bak-${REPO_DIR}.$$"
  mv "$TARGET" "$TMP_BACKUP"
fi

git submodule add "$URL" "$REPO_DIR"

# Prefer keeping local commits if backup was ahead of remote clone
# Compare: if backup has commits not in new submodule, warn user
if [[ -n "$TMP_BACKUP" ]]; then
  BACKUP_HEAD="$(git -C "$TMP_BACKUP" rev-parse HEAD 2>/dev/null || true)"
  NEW_HEAD="$(git -C "$TARGET" rev-parse HEAD 2>/dev/null || true)"
  if [[ -n "$BACKUP_HEAD" && -n "$NEW_HEAD" && "$BACKUP_HEAD" != "$NEW_HEAD" ]]; then
    echo "Note: local backup HEAD ($BACKUP_HEAD) != submodule HEAD ($NEW_HEAD)."
    echo "      Backup kept at: $TMP_BACKUP"
    echo "      Inspect and remove backup when satisfied."
    TMP_BACKUP="" # do not auto-restore over submodule
  else
    rm -rf "$TMP_BACKUP"
    TMP_BACKUP=""
  fi
fi

trap - EXIT

git add .gitmodules "$REPO_DIR"
if git commit -q -m "chore: add submodule ${REPO_DIR}"; then
  echo "Committed submodule pointer for ${REPO_DIR}"
else
  echo "Submodule added; commit manually if needed."
fi

cat <<EOF
Registered: ${REPO_DIR}
  url: ${URL}

Next:
  # add/update this product in products.json, then:
  bash scripts/render-catalog
  bash scripts/check-catalog
  git push origin main          # parent incubator
  # colleagues:
  git clone --recurse-submodules git@github.com:${OWNER}/skills.git
EOF
