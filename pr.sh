#!/bin/bash

set -e

GITHUB_TOKEN=$1
BODY=$2

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
CURRENT_BODY=$(gh pr view $PR_NUMBER --json body --json merged --template "{{.body}}")

# Check if newBody already exists in the current description
if echo "$CURRENT_BODY" | grep -q "$BODY"; then
  echo "New body already exists in the current description. No update needed."
  exit 0
fi

# Concatenate the new text to the existing description
COMBINED_BODY="${CURRENT_BODY}\n\n${BODY}"

# Update the pull request with the combined text
gh pr edit $PR_NUMBER --body "$COMBINED_BODY"
