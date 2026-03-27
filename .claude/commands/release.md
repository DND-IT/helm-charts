Prepare a release for changed charts. Do the following steps:

1. **Detect changed charts**: Run `git diff main --name-only` to find which charts under `charts/` have changes. Group by chart name.

2. **Determine version bumps**: For each changed chart:
   - If the common library chart changed, ALL charts that depend on it (generic, web, worker, task, mysql) need a bump too.
   - Use semver: breaking changes = major, new features = minor, fixes = patch.
   - Ask the user to confirm the version bump type if unclear.

3. **Bump versions**: Update `version:` in each changed chart's `Chart.yaml`.

4. **Update CHANGELOG.md**: For each chart that has a CHANGELOG.md, add a new entry at the top following the Keep a Changelog format:
   ```
   ## [x.y.z] - YYYY-MM-DD

   ### Added / Changed / Fixed
   - Description of changes
   ```
   Derive the changelog entries from the git diff against main.

5. **Generate docs**: Run `make docs CHART=<name>` for each changed chart.

6. **Generate schemas**: Run `make schema CHART=<name>` for each changed chart that has a values.yaml change.

7. **Run tests**: Run `make test-all` and ensure all tests pass.

8. **Commit**: Stage all changes and create a single commit with message format:
   `chore(release): bump <chart1> x.y.z, <chart2> x.y.z, ...`

9. **Summary**: Print a table of all version bumps.

Important:
- Do NOT push or create a PR — just prepare the commit locally.
- The pre-commit hook will run helm-docs automatically, so stage any files it modifies.
- Charts that depend on common via `"1.x.x"` range auto-resolve, but still bump their version to signal the update.
