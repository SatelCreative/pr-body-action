const core = require("@actions/core");
const github = require("@actions/github");

async function run() {
  try {
    const { context } = github;
    const githubToken = core.getInput("GITHUB_TOKEN");
    const newBody = core.getInput("body");

    if (context.payload.pull_request == null) {
      core.setFailed("No pull request found");
      return;
    }
    if (!githubToken) {
      core.setFailed("GITHUB_TOKEN input is required");
      return;
    }
    if (!newBody) {
      core.setFailed("body input is required");
      return;
    }

    const { number: prNumber } = context.payload.pull_request;
    const octokit = new github.GitHub(githubToken);

    // Fetch the current pull request details
    const { data: currentPR } = await octokit.pulls.get({
      ...context.repo,
      pull_number: prNumber,
    });

    // Check if newBody already exists in the current description
    if (currentPR.body.includes(newBody)) {
      console.log("New body already exists in the current description. No update needed.");
      return;
    }

    // Concatenate the new text to the existing description
    const combinedBody = `${currentPR.body}\n\n${newBody}`;

    // Update the pull request with the combined text
    await octokit.pulls.update({
      ...context.repo,
      pull_number: prNumber,
      body: combinedBody,
    });
  } catch (error) {
    core.setFailed(error.message);
  }
}

// Call the asynchronous function
run();
