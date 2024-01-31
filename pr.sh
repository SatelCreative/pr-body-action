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

# Use grep to check if the pattern in $BODY is found in $CURRENT_BODY
if [[ ! "$(echo "$CURRENT_BODY" | awk -v body="$BODY" '$0 == body')" ]]; then
  echo "New body already exists in the current description. No update needed."
else
  echo "New body does not exist in the current description. Updating..."
  # Concatenate the new text to the existing description
  COMBINED_BODY="${CURRENT_BODY} ${BODY}"
  echo "DEBUG: Updated body: $COMBINED_BODY"
  # Uncomment the following line when you are ready to actually update the pull request
  gh pr edit $PR_NUMBER --body "${COMBINED_BODY}"
fi
