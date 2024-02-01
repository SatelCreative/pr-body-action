#!/bin/bash

set -e

if [ -z "$GITHUB_TOKEN" ]; then
  echo "Error: GITHUB_TOKEN input is required"
  exit 1
fi

if [ -z "$BODY" ]; then
  echo "Error: body input is required"
  exit 1
fi

# Get pull request number
PR_NUMBER=$(jq --raw-output .pull_request.number "$GITHUB_EVENT_PATH")

if [ "$PR_NUMBER" == "null" ]; then
  echo "Error: No pull request found"
  exit 1
fi

# Fetch current pull request details
CURRENT_BODY=$(gh pr view $PR_NUMBER --json body -q .body)

echo "DEBUG: BODY=$BODY"
echo "DEBUG: CURRENT_BODY=$CURRENT_BODY"

# Escape special characters in BODY
ESCAPED_BODY=$(awk '{gsub(/[.*+?^${}()|[\]\\]/, "\\\\&"); print $0}' <<< "$BODY")

# Remove only the exact occurrence of BODY from CURRENT_BODY, and concatenate the new text
COMBINED_BODY=$(awk -v body="$ESCAPED_BODY" '{gsub("\\|" body "\\|", ""); print $0}' <<< "$CURRENT_BODY")
COMBINED_BODY="${COMBINED_BODY} ${BODY}"

echo "DEBUG: Updated body: $COMBINED_BODY"

# Uncomment the following line when you are ready to actually update the pull request
gh pr edit $PR_NUMBER --body "${COMBINED_BODY}"
