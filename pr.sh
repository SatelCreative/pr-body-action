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
echo "PR_NUMBER=$PR_NUMBER"

if [ "$PR_NUMBER" == "null" ]; then
  echo "Error: No pull request found"
  exit 1
fi

# Fetch current pull request details using GitHub API
CURRENT_BODY=$(curl -s -H "Authorization: Bearer $GITHUB_TOKEN" "https://api.github.com/repos/$GITHUB_REPOSITORY/pulls/$PR_NUMBER" | jq -r '.body')

# Check if newBody already exists in the current description
if ! echo "$CURRENT_BODY" | grep -q "$BODY"; then
  echo "New body does not exist in the current description. Updating..."
  
  # Concatenate the new text to the existing description
  COMBINED_BODY="${CURRENT_BODY}\n\n${BODY}"

  # Update the pull request with the combined text
  gh pr edit $PR_NUMBER --body "$COMBINED_BODY"
else
  echo "New body already exists in the current description. No update needed."
fi


# # Fetch current pull request details
# CURRENT_BODY=$(gh pr view $PR_NUMBER --json body -q .body)

# # Check if newBody already exists in the current description
# if ! echo "$CURRENT_BODY" | jq --arg BODY "$BODY" 'index($BODY)' > /dev/null; then
#   echo "New body does not exist in the current description. Updating..."
  
#   # Concatenate the new text to the existing description
#   COMBINED_BODY="${CURRENT_BODY}\n\n${BODY}"

#   # Update the pull request with the combined text
#   gh pr edit $PR_NUMBER --body "$COMBINED_BODY"
# else
#   echo "New body already exists in the current description. No update needed."
# fi
