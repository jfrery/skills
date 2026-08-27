#!/usr/bin/env bash
#
# Symlink every skill in this repo into the agent harnesses installed on this
# machine, so Claude Code and Codex read the same files.
#
#   ./install.sh            install (or repair) the symlinks
#   ./install.sh --dry-run  print what would happen, touch nothing
#
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
SKILLS_DIR="$REPO_DIR/skills"

HARNESSES=(
  "$HOME/.claude/skills"
  "$HOME/.codex/skills"
)

DRY_RUN=0

usage() {
  sed -n '2,9p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
  exit "${1:-0}"
}

while [ $# -gt 0 ]; do
  case "$1" in
    -n|--dry-run) DRY_RUN=1 ;;
    -h|--help)    usage 0 ;;
    *) echo "unknown option: $1" >&2; usage 1 ;;
  esac
  shift
done

run() {
  if [ "$DRY_RUN" -eq 1 ]; then
    echo "    would run: $*"
  else
    "$@"
  fi
}

# Absolute, fully-resolved path of an existing directory.
resolve_dir() {
  (cd "$1" 2>/dev/null && pwd -P)
}

# Anything displaced goes to a sibling of the harness dir, never inside it: the
# harness scans its skills directory, so a backup left there would load as a
# second skill with a duplicate name.
backup_root_for() {
  printf '%s/skills-backup\n' "$(dirname "$1")"
}

# First unused "<root>/<name>.bak.N".
backup_path() {
  local root="$1" name="$2" n=1
  while [ -e "$root/$name.bak.$n" ] || [ -L "$root/$name.bak.$n" ]; do
    n=$((n + 1))
  done
  printf '%s/%s.bak.%s\n' "$root" "$name" "$n"
}

if [ ! -d "$SKILLS_DIR" ]; then
  echo "no skills/ directory in $REPO_DIR" >&2
  exit 1
fi

linked=0 already=0 backed_up=0

[ "$DRY_RUN" -eq 1 ] && echo "DRY RUN — nothing will be written."
echo "source: $SKILLS_DIR"
echo

for harness in "${HARNESSES[@]}"; do
  echo "$harness"
  if [ ! -d "$harness" ]; then
    echo "  creating (harness dir does not exist yet)"
    run mkdir -p "$harness"
  fi
  backup_root="$(backup_root_for "$harness")"

  for src in "$SKILLS_DIR"/*/; do
    [ -d "$src" ] || continue
    src="${src%/}"
    name="$(basename "$src")"
    dest="$harness/$name"
    displace=""

    if [ -L "$dest" ]; then
      if [ ! -e "$dest" ]; then
        echo "  $name: replacing broken symlink"
        run rm "$dest"
      elif [ "$(resolve_dir "$dest")" = "$(resolve_dir "$src")" ]; then
        echo "  $name: already linked"
        already=$((already + 1))
        continue
      else
        displace="symlink points elsewhere"
      fi
    elif [ -e "$dest" ]; then
      displace="existing copy"
    fi

    if [ -n "$displace" ]; then
      bak="$(backup_path "$backup_root" "$name")"
      echo "  $name: $displace, moving to $bak"
      run mkdir -p "$backup_root"
      run mv "$dest" "$bak"
      backed_up=$((backed_up + 1))
    fi

    echo "  $name: linking"
    run ln -s "$src" "$dest"
    linked=$((linked + 1))
  done
  echo
done

echo "linked $linked, already correct $already, moved aside $backed_up"
[ "$DRY_RUN" -eq 1 ] && echo "Re-run without --dry-run to apply."
exit 0
