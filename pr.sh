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

# Trim leading and trailing whitespace from BODY
BODY=$(echo "$BODY" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

# Check if BODY is not empty
if [ -n "$BODY" ]; then
  # Store the new body content in a temporary file
  echo -e "$BODY" > new_body.txt

  # Fetch current pull request details using GitHub API
  CURRENT_BODY=$(gh pr view $PR_NUMBER --json body -q .body)

  # Check if newBody already exists in the current description
  if ! echo "$CURRENT_BODY" | grep -q "$(cat new_body.txt)"; then
    echo "New body does not exist in the current description. Updating..."

    # Update the pull request with the new body
    gh pr edit $PR_NUMBER --body "$(cat new_body.txt)"
    echo "Pull request body updated."
  else
    echo "New body already exists in the current description. No update needed."
  fi

  # Remove the temporary file
  rm new_body.txt
else
  echo "Error: BODY is empty. No update performed."
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
