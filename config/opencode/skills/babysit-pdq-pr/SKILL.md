---
name: babysit-pdq-pr
description: Babysit PR review cycles for PDQ organization repositories only. Use only when the user explicitly asks to run this skill (for example, "use babysit-pdq-pr"). Monitor a PR for new feedback from `coderabbitai`, evaluate each concern for validity, fix only valid issues with conventional commits, push, and repeat until CodeRabbit approves.
---

# Babysit PDQ PR

## Guardrails

- Confirm the request is explicit. If the user did not specifically ask to use this skill, do not use it.
- Confirm repository scope before doing any work:
  1. Get owner/name via `gh repo view --json owner,name`.
  2. Continue only if the owner is a PDQ org (owner login contains `pdq`, case-insensitive).
  3. If not PDQ, stop and tell the user this skill is not applicable.
- Operate only on the target PR branch and do not change unrelated files.

## Setup

1. Resolve the PR number (from user input or current branch):
   - `gh pr view --json number,url,headRefName,baseRefName,state`
2. Ensure clean local state before starting each cycle:
   - `git status --short`
   - If dirty due to unrelated work, isolate or stash only if the user asks.
3. Capture a processing checkpoint timestamp (`last_checked_at`) so each loop handles only new CodeRabbit feedback.

## Review Cycle Loop

Repeat this loop until CodeRabbit approval is reached.

1. Fetch latest PR feedback from CodeRabbit:
   - Reviews: `gh api repos/{owner}/{repo}/pulls/{pr}/reviews --paginate`
   - Inline comments: `gh api repos/{owner}/{repo}/pulls/{pr}/comments --paginate`
   - Issue comments: `gh api repos/{owner}/{repo}/issues/{pr}/comments --paginate`
2. Build the current batch:
   - Include only items authored by `coderabbitai`.
   - Include only items newer than `last_checked_at`.
   - If no new items, wait and poll again (see Wait Strategy).
3. Evaluate each comment one by one.

## Per-Comment Decision

For every `coderabbitai` comment, decide `fix` or `ignore`.

- Treat the comment as a hypothesis, not a fact.
- Validate against the actual code, PR goals, project conventions, tests, and runtime behavior.
- Ignore if the concern is hallucinated, out of scope, already addressed, or would degrade correctness/design.
- Fix if the concern is valid and improves correctness, safety, maintainability, or clarity in this PR.

## If Decision Is `fix`

1. Implement the minimal correct change.
2. Run focused verification (tests/lint/typecheck) for the impacted area.
3. Commit immediately with a conventional commit title only (no body), for example:
   - `git commit -m "fix: handle nil input in session parser"`
4. Prefer one commit per accepted concern for clean auditability.

## If Decision Is `ignore`

- Record a short rationale in your working notes so future cycles do not re-litigate the same point.
- If helpful, leave a concise PR reply explaining why no change is needed.

## End of Batch

After all comments in the current batch are processed:

1. Push branch updates: `git push`
   - Run this even when no new commit was created (it is a safe no-op if already up to date).
2. Update `last_checked_at` to the most recent processed CodeRabbit item.
3. Return to waiting for the next cycle.

## Wait Strategy

- Poll for new CodeRabbit feedback on an interval (for example 60-120 seconds).
- Use the `timeout` CLI to bound each wait window when needed, then continue polling:
  - Example pattern: `timeout 10m <poll-command>`
- Continue iterating until exit conditions are met.

## Exit Conditions

Stop the loop only when both are true:

1. The latest CodeRabbit review state is `APPROVED`.
2. There are no newer unresolved `coderabbitai` comments after the approval.

Then report:

- Which comments were fixed and corresponding commit titles.
- Which comments were ignored and the rationale for each.
