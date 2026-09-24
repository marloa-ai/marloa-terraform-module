## What

<!-- Short summary of the change. -->

## Why

<!-- Problem or requirement this solves. -->

## Affected modules

- [ ] `modules/...`

## Type of change

PR title must follow Conventional Commits — it becomes the squash commit and
decides the version bump of each touched module:

- [ ] `fix(<module>): ...` — patch
- [ ] `feat(<module>): ...` — minor
- [ ] `feat(<module>)!: ...` or `BREAKING CHANGE:` in the body — major
- [ ] `docs/chore/ci/refactor(...)` — patch

## Breaking changes

- [ ] None
- [ ] Yes — described below, including what consumers must change (inputs,
      outputs, `moved` blocks, state operations) before bumping `?ref=`

## Testing evidence (required)

<!-- Plan output or a link to the marloa-terraform PR that consumes this
     change via a branch/sha ref and shows the plan for staging. -->

## Checklist

- [ ] `terraform fmt -recursive` and `terraform validate` pass
- [ ] Module README regenerated (`terraform-docs --config .terraform-docs.yml modules/<name>`)
- [ ] New variables have descriptions, types and validation where useful
- [ ] Plan tested against staging with no unexpected changes
