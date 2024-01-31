#!/bin/bash

set -e
echo "BODY=$BODY"
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
echo "CURRENT_BODY=$CURRENT_BODY"

if grep -q "$BODY" <<< "$CURRENT_BODY"; then
  echo "New body already exists in the current description. No update needed."
else
  echo "New body does not exist in the current description. Updating..."
  # Concatenate the new text to the existing description
  COMBINED_BODY="${CURRENT_BODY} ${BODY}"
  echo "Updated body: $COMBINED_BODY"
  gh pr edit $PR_NUMBER --body "${COMBINED_BODY}"
fi
