#!/usr/bin/env bash
# Cut a `<module>-vX.Y.Z` tag for every module under modules/ that changed
# since its last tag. The bump comes from Conventional Commit messages that
# touched the module since that tag:
#   BREAKING CHANGE / type!:  -> major
#   feat:                     -> minor
#   anything else             -> patch
# A module without any tag starts at v0.1.0.
#
# Usage: release-tags.sh [--dry-run]    (needs full history and tags)

set -euo pipefail

dry_run=false
[[ "${1:-}" == "--dry-run" ]] && dry_run=true

created=()

for dir in modules/*/; do
  module=$(basename "$dir")
  last_tag=$(git tag --list "${module}-v*" --sort=-v:refname | head -n1)

  if [[ -z "$last_tag" ]]; then
    next="v0.1.0"
    reason="initial release"
  else
    messages=$(git log --format='%s%n%b' "${last_tag}..HEAD" -- "$dir")
    if [[ -z "$(git log --format=%H "${last_tag}..HEAD" -- "$dir")" ]]; then
      continue
    fi

    version=${last_tag#"${module}-v"}
    IFS=. read -r major minor patch <<<"$version"

    if grep -qE '^BREAKING CHANGE|^[a-z]+(\([^)]*\))?!:' <<<"$messages"; then
      major=$((major + 1)); minor=0; patch=0; reason="breaking change"
    elif grep -qE '^feat(\([^)]*\))?:' <<<"$messages"; then
      minor=$((minor + 1)); patch=0; reason="feature"
    else
      patch=$((patch + 1)); reason="fix/chore"
    fi
    next="v${major}.${minor}.${patch}"
  fi

  tag="${module}-${next}"
  echo "${module}: ${last_tag:-<none>} -> ${tag} (${reason})"
  created+=("$tag")

  if [[ "$dry_run" == false ]]; then
    git tag -a "$tag" -m "${module} ${next}"
  fi
done

if [[ ${#created[@]} -eq 0 ]]; then
  echo "No module changes to release."
  exit 0
fi

if [[ "$dry_run" == false ]]; then
  git push origin "${created[@]}"
fi

if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
  {
    echo "### Released module versions"
    for t in "${created[@]}"; do echo "- \`${t}\`"; done
  } >>"$GITHUB_STEP_SUMMARY"
fi
