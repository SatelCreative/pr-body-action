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
CURRENT_BODY=$(gh pr view $PR_NUMBER --json body -q .body | tr -d '\000')
echo "DEBUG: CURRENT_BODY=$CURRENT_BODY"
echo "DEBUG: BODY=$BODY"

# Check if newBody already exists in the current description
if [[ "${CURRENT_BODY}" == *"${BODY}"* ]]; then
  echo "New body already exists in the current description. No update needed."
else
  # Concatenate the new text to the existing description
  COMBINED_BODY="${CURRENT_BODY}\n\n${BODY}"

  # Uncomment the following line when you are ready to actually update the pull request
  gh pr edit $PR_NUMBER --body "${COMBINED_BODY}"

  echo "Updated pull request description."
fi
