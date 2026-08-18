---
name: address-pr-comments
description: Replies to and resolves all unresolved review comments on a pull request. Use when the user wants to address PR comments, reply to reviewer feedback, or work through a PR review until zero unresolved threads remain.
---

# Address PR Comments

Process every unresolved review comment on a pull request until zero unresolved threads remain. For each comment: reply (rebut or fix), push if needed, reply on the thread, then resolve the thread.

## Identify the PR

Determine the target PR number. If the user gives a number, use it. If not, resolve it from the current branch's upstream PR (no user input needed):

```bash
# Returns the PR number the current branch is mapped to, or empty if none
gh pr view --json number --jq '.number' 2>/dev/null
```

If that returns nothing, there's no PR for the current branch — ask the user for the PR number (or repo `OWNER/REPO` + number) and stop. Also resolve `OWNER`/`REPO`/`REPO_FULL` from the git remote so the GraphQL calls have the values they need:

```bash
gh repo view --json owner,name,nameWithOwner --jq '.owner,.name,.nameWithOwner'
```

## Process

### 1. List unresolved threads

Find every unresolved review thread on the PR. Use the GraphQL API so you get both the thread node ID (needed to resolve) and the inline comment database IDs (needed to reply):

```bash
gh api graphql -f query='
query($owner:String!,$name:String!,$number:Int!){
  repository(owner:$owner,name:$name){
    pullRequest(number:$number){
      reviewThreads(first:100){
        nodes{
          id
          isResolved
          path
          comments(first:1){ nodes{ databaseId body } }
        }
      }
    }
  }
}
' -F owner=OWNER -F name=REPO -F number=PR_NUMBER \
  --jq '.data.repository.pullRequest.reviewThreads.nodes[] | select(.isResolved==false)'
```

If zero unresolved threads, stop — report "all resolved" and nothing to do.

### 2. For each unresolved comment

Read the comment body in full (the first 500 chars are usually the headline; the recommendation is often inside a `<details>` block — extract it). Decide per comment: **fix** or **rebut**.

Verify each finding against the current code before acting. Fix only still-valid issues; skip the rest with a brief reason. Keep changes minimal.

#### Branch a — Fix

When the comment is valid and the fix is appropriate:

1. Make the change (edit the file(s)).
2. Commit with a clear message naming what was fixed.
3. Push so the PR is up-to-date.
4. Reply on the thread: what was fixed, the commit SHA, and a one-line summary of the change.

#### Branch b — Rebut

When the comment is wrong, out of scope, or the suggested approach isn't right:

1. Do NOT change code.
2. Reply on the thread with the reasoning — why the current approach is correct, why the suggestion doesn't apply, or what context the reviewer missed. Be specific and technical, not dismissive.

### 3. Reply on the thread

Replies MUST be a reply to the original comment, not a top-level PR comment. Use the REST endpoint with `in_reply_to`:

```bash
gh api repos/OWNER/REPO/pulls/PR_NUMBER/comments \
  -f body="REPLY_BODY" \
  -F in_reply_to=ORIGINAL_COMMENT_DATABASE_ID
```

The `ORIGINAL_COMMENT_DATABASE_ID` is the `databaseId` from the GraphQL thread listing (the first comment's databaseId in that thread).

### 4. Resolve the thread

After replying (and, if you fixed, after the push completes), resolve the thread using its node ID:

```bash
gh api graphql -f query='
mutation($id:ID!){
  resolveReviewThread(input:{threadId:$id}){
    thread{ isResolved }
  }
}
' -F id=THREAD_NODE_ID
```

Resolve every thread you replied to, even rebuttals. The goal is zero unresolved threads.

### 5. Verify and report

Re-run the GraphQL listing; confirm `unresolved == 0`. Report a summary: how many fixed, how many rebutted, and the PR URL.

## Rules

- **Every comment gets a reply.** Never resolve without replying. Never reply without resolving (unless the thread can't be resolved — e.g. an outside-diff comment that wasn't posted as a thread; in that case post a PR-level comment documenting the disposition).
- **Replies are always in-thread** (`in_reply_to` the original comment databaseId), never top-level PR comments.
- **Fix → commit → push → reply → resolve.** Order matters: the reply should reference the commit SHA that fixed it, so the push must happen first.
- **Rebut → reply → resolve.** No commit/push for rebuttals.
- **Verify before acting.** A comment may reference code that has already changed; re-read the current file before fixing or rebutting.
- **One comment at a time** if changes could interact; batch independent ones.
- **Don't resolve threads you didn't reply to.**
- **Extraction gotcha.** Comment bodies often hide the actual recommendation inside `<details>...</details>` or behind an analysis chain. Parse out the actionable sentence (usually after the last `</details>`) before deciding fix vs rebut.

## Determining fix vs rebut

Fix when:

- The finding is valid against the current code.
- The fix is small, correct, and doesn't contradict the repo's standards.
- The reviewer caught a real bug, security issue, or inconsistency.

Rebut when:

- The comment references old code that has since changed (the fix was already applied).
- The suggestion contradicts a documented standard or binding rule in this repo.
- The comment is a style preference the repo deliberately doesn't enforce.
- The suggested approach is technically incorrect or would introduce a worse problem.
- The comment is out of scope for this PR (note it and suggest a follow-up issue).

When unsure whether to fix or rebut, prefer fixing if the change is low-risk and improves the code; prefer rebutting if the change would require a larger architectural call that isn't yours to make unilaterally.
