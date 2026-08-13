#!/usr/bin/env bash
# Scaffold a new product skill repo from _template into Skills/<name>-skill/.
set -euo pipefail

INCUBATOR_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
TEMPLATE="${INCUBATOR_ROOT}/_template"
DEFAULT_OWNER="kedoupi"

usage() {
  cat <<'EOF'
Usage:
  scripts/new-skill.sh <skill-name> [--author <github-handle>] [--owner <github-owner>]

Creates Skills/<skill-name>-skill/ from _template (git init), ready to become
a GitHub repo and a submodule of the parent incubator (kedoupi/skills).

Naming:
  skill package (SKILL.md name):  <skill-name>          e.g. lark-push
  GitHub / submodule directory:   <skill-name>-skill    e.g. lark-push-skill
  Install:  npx skills add <owner>/<skill-name>-skill

If you pass a name that already ends with -skill, it is treated as the repo
directory name and the package name is the prefix without -skill.

Name rules: kebab-case, 2-64 chars for the package name, [a-z0-9-], start/end alnum.
EOF
}

if [[ $# -lt 1 || "$1" == "-h" || "$1" == "--help" ]]; then
  usage
  exit 0
fi

RAW="$1"
shift
AUTHOR="kedoupi"
OWNER="$DEFAULT_OWNER"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --author)
      if [[ $# -lt 2 || -z "${2}" ]]; then
        echo "Empty --author" >&2
        exit 2
      fi
      AUTHOR="$2"
      shift 2
      ;;
    --owner)
      if [[ $# -lt 2 || -z "${2}" ]]; then
        echo "Empty --owner" >&2
        exit 2
      fi
      OWNER="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ ! "$AUTHOR" =~ ^[A-Za-z0-9]([A-Za-z0-9-]*[A-Za-z0-9])?$ ]]; then
  echo "Invalid --author (GitHub handle): $AUTHOR" >&2
  exit 2
fi
if [[ ! "$OWNER" =~ ^[A-Za-z0-9]([A-Za-z0-9-]*[A-Za-z0-9])?$ ]]; then
  echo "Invalid --owner (GitHub handle): $OWNER" >&2
  exit 2
fi

# Normalize package name + repo directory
if [[ "$RAW" == *-skill ]]; then
  REPO_DIR="$RAW"
  NAME="${RAW%-skill}"
else
  NAME="$RAW"
  REPO_DIR="${RAW}-skill"
fi

if [[ ! "$NAME" =~ ^[a-z0-9]([a-z0-9-]*[a-z0-9])?$ ]]; then
  echo "Invalid skill package name: $NAME (use kebab-case)" >&2
  exit 2
fi
if [[ ${#NAME} -lt 2 || ${#NAME} -gt 64 ]]; then
  echo "Skill package name length must be 2-64 characters" >&2
  exit 2
fi
if [[ ! "$REPO_DIR" =~ ^[a-z0-9]([a-z0-9-]*[a-z0-9])?$ ]]; then
  echo "Invalid repo directory: $REPO_DIR" >&2
  exit 2
fi

case "$NAME" in
  template|schema|scripts|agents|docs)
    echo "Reserved name: $NAME" >&2
    exit 2
    ;;
esac

TARGET="${INCUBATOR_ROOT}/${REPO_DIR}"
if [[ -e "$TARGET" ]]; then
  echo "Already exists: $TARGET" >&2
  exit 1
fi
if [[ ! -d "$TEMPLATE" ]]; then
  echo "Missing template: $TEMPLATE" >&2
  exit 1
fi

ENV_PREFIX="$(printf '%s' "$NAME" | tr '[:lower:]-' '[:upper:]_')"
GITHUB_REPO="${OWNER}/${REPO_DIR}"

cp -R "$TEMPLATE" "$TARGET"

mv "${TARGET}/skills/_your-skill_" "${TARGET}/skills/${NAME}"
mv "${TARGET}/skills/${NAME}/scripts/_your-skill_" "${TARGET}/skills/${NAME}/scripts/${NAME}"

replace_in_file() {
  local file="$1"
  local tmp="${file}.tmp.$$"
  sed \
    -e "s/_your-skill_/${NAME}/g" \
    -e "s/<skill-name>/${NAME}/g" \
    -e "s/<repo-name>/${REPO_DIR}/g" \
    -e "s/<Skill Display Name>/${NAME}/g" \
    -e "s/<your-github-handle>/${AUTHOR}/g" \
    -e "s|<owner>/<repo>|${GITHUB_REPO}|g" \
    -e "s/<owner>/${OWNER}/g" \
    -e "s/<SCREAMING_SKILL_NAME>/${ENV_PREFIX}/g" \
    -e "s/SKILL_CHAT_ID/${ENV_PREFIX}_CHAT_ID/g" \
    -e "s/SKILL_AS/${ENV_PREFIX}_AS/g" \
    -e "s/SKILL_FOOTER/${ENV_PREFIX}_FOOTER/g" \
    -e "s/SKILL_ENV_CONFIG/${ENV_PREFIX}_CONFIG/g" \
    "$file" >"$tmp"
  mv "$tmp" "$file"
}

while IFS= read -r -d '' file; do
  case "$file" in
    *.png|*.jpg|*.jpeg|*.gif|*.webp|*.pdf|*.zip) continue ;;
  esac
  replace_in_file "$file"
done < <(find "$TARGET" -type f -print0)

cat >"${TARGET}/LICENSE" <<EOF
MIT License

Copyright (c) $(date +%Y) ${AUTHOR}

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF

chmod +x "${TARGET}/skills/${NAME}/scripts/${NAME}"
chmod +x "${TARGET}/tests/run.sh"

(
  cd "$TARGET"
  git init -q
  git add .
  if git commit -q -m "chore: scaffold ${NAME} from incubator template"; then
    :
  else
    echo "Note: git commit skipped (configure user.name / user.email if needed)"
  fi
)

cat <<EOF
Created: ${TARGET}

Naming:
  package (SKILL.md):  ${NAME}
  repo / directory:    ${REPO_DIR}
  GitHub (intended):   ${GITHUB_REPO}
  install:             npx skills add ${GITHUB_REPO}

Next:
  1. Edit skills/${NAME}/SKILL.md (description triggers + body)
  2. Implement skills/${NAME}/scripts/${NAME}
  3. Fill README.md / README.zh-CN.md
  4. Run:  bash ${TARGET}/tests/run.sh
  5. Create empty GitHub repo ${GITHUB_REPO}, then:
       cd ${REPO_DIR}
       git remote add origin git@github.com:${GITHUB_REPO}.git
       git push -u origin main
  6. Register as submodule of parent incubator (from incubator root):
       bash scripts/register-submodule.sh ${REPO_DIR}
  7. Add a type=single entry to products.json, then:
       bash scripts/render-catalog
       bash scripts/check-catalog

Registry: ${INCUBATOR_ROOT}/products.json
Schema: ${INCUBATOR_ROOT}/schema/skill-repo.md
EOF
