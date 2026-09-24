#!/usr/bin/env bash
# Upload every released module tag to S3 as a zip, so live roots can use
#   source = "s3::https://<bucket>.s3.ap-south-1.amazonaws.com/<module>/<tag>.zip"
# with the AWS credentials they already have (GitHub OIDC). Idempotent and
# append-only: tags already in the bucket are skipped, never overwritten.
#
# Usage: publish-modules.sh <bucket>        (needs full history, tags, AWS creds)

set -euo pipefail

bucket=${1:?usage: publish-modules.sh <bucket>}
published=()

for tag in $(git tag --list '*-v[0-9]*.[0-9]*.[0-9]*' --sort=refname); do
  module=${tag%-v*}
  key="${module}/${tag}.zip"

  # The tag must contain the module directory.
  git cat-file -e "${tag}:modules/${module}" 2>/dev/null || continue

  if aws s3api head-object --bucket "$bucket" --key "$key" >/dev/null 2>&1; then
    continue
  fi

  zip="$(mktemp -d)/${tag}.zip"
  git archive --format=zip -o "$zip" "${tag}:modules/${module}"
  aws s3api put-object --bucket "$bucket" --key "$key" --body "$zip" \
    --content-type application/zip >/dev/null
  echo "published s3://${bucket}/${key}"
  published+=("$key")
done

if [[ ${#published[@]} -eq 0 ]]; then
  echo "All module tags already published."
fi

if [[ -n "${GITHUB_STEP_SUMMARY:-}" && ${#published[@]} -gt 0 ]]; then
  {
    echo "### Published to s3://${bucket}"
    for k in "${published[@]}"; do echo "- \`${k}\`"; done
  } >>"$GITHUB_STEP_SUMMARY"
fi
