#!/usr/bin/env node
/**
 * Asana → GitHub Issues Sync Script
 *
 * Fetches tasks from an Asana project and creates/updates corresponding GitHub Issues.
 *
 * Required environment variables:
 *   - ASANA_ACCESS_TOKEN: Personal Access Token from Asana
 *   - ASANA_PROJECT_GID: The GID of the Asana project to sync
 *   - GITHUB_TOKEN: GitHub token with issues:write permission
 *   - GITHUB_REPOSITORY: "owner/repo" format
 *   - DRY_RUN: "true" to log only without creating issues
 *
 * How to get Asana credentials:
 *   1. Go to https://app.asana.com/0/my-apps
 *   2. Create a new Personal Access Token
 *   3. Find your Project GID in the URL when viewing the project:
 *      https://app.asana.com/0/<PROJECT_GID>/...
 */

const https = require("https");

const ASANA_TOKEN = process.env.ASANA_ACCESS_TOKEN;
const ASANA_PROJECT_GID = process.env.ASANA_PROJECT_GID;
const GITHUB_TOKEN = process.env.GITHUB_TOKEN;
const GITHUB_REPOSITORY = process.env.GITHUB_REPOSITORY;
const DRY_RUN = process.env.DRY_RUN === "true";

const [GITHUB_OWNER, GITHUB_REPO] = (GITHUB_REPOSITORY || "").split("/");

// ─── Validation ───────────────────────────────────────────────────────────────

if (!ASANA_TOKEN) {
  console.error(
    "❌ ASANA_ACCESS_TOKEN is not set. Add it as a GitHub repository secret."
  );
  process.exit(1);
}

if (!ASANA_PROJECT_GID) {
  console.error(
    "❌ ASANA_PROJECT_GID is not set. Add it as a GitHub repository secret or provide it as workflow input."
  );
  process.exit(1);
}

if (!GITHUB_TOKEN || !GITHUB_OWNER || !GITHUB_REPO) {
  console.error("❌ GitHub credentials are not properly configured.");
  process.exit(1);
}

if (DRY_RUN) {
  console.log("🔍 DRY RUN mode — no issues will be created or updated");
}

// ─── HTTP Helpers ─────────────────────────────────────────────────────────────

function request(options, body) {
  return new Promise((resolve, reject) => {
    const req = https.request(options, (res) => {
      let data = "";
      res.on("data", (chunk) => (data += chunk));
      res.on("end", () => {
        try {
          resolve({ status: res.statusCode, data: JSON.parse(data) });
        } catch {
          resolve({ status: res.statusCode, data });
        }
      });
    });
    req.on("error", reject);
    if (body) req.write(JSON.stringify(body));
    req.end();
  });
}

async function asanaRequest(path) {
  const options = {
    hostname: "app.asana.com",
    path: `/api/1.0${path}`,
    method: "GET",
    headers: {
      Authorization: `Bearer ${ASANA_TOKEN}`,
      Accept: "application/json",
    },
  };
  const res = await request(options);
  if (res.status !== 200) {
    throw new Error(`Asana API error ${res.status}: ${JSON.stringify(res.data)}`);
  }
  return res.data;
}

async function githubRequest(method, path, body) {
  const options = {
    hostname: "api.github.com",
    path,
    method,
    headers: {
      Authorization: `Bearer ${GITHUB_TOKEN}`,
      Accept: "application/vnd.github+json",
      "Content-Type": "application/json",
      "User-Agent": "asana-github-sync/1.0",
      "X-GitHub-Api-Version": "2022-11-28",
    },
  };
  const res = await request(options, body);
  return res;
}

// ─── Asana Helpers ────────────────────────────────────────────────────────────

async function fetchAsanaTasks() {
  console.log(`📥 Fetching tasks from Asana project ${ASANA_PROJECT_GID}...`);

  const fields = [
    "name",
    "notes",
    "completed",
    "assignee",
    "due_on",
    "tags",
    "custom_fields",
    "permalink_url",
    "resource_type",
    "parent",
  ].join(",");

  const response = await asanaRequest(
    `/tasks?project=${ASANA_PROJECT_GID}&opt_fields=${fields}&limit=100`
  );

  const tasks = response.data || [];
  console.log(`✅ Fetched ${tasks.length} tasks from Asana`);
  return tasks;
}

// ─── GitHub Helpers ───────────────────────────────────────────────────────────

async function getExistingIssues() {
  console.log(`📋 Fetching existing GitHub issues...`);
  const res = await githubRequest(
    "GET",
    `/repos/${GITHUB_OWNER}/${GITHUB_REPO}/issues?state=all&labels=asana-sync&per_page=100`
  );

  if (res.status !== 200) {
    console.warn(`⚠️ Could not fetch issues: ${res.status}`);
    return [];
  }

  return res.data;
}

async function createIssue(task) {
  const title = `[Asana] ${task.name}`;
  const body = buildIssueBody(task);

  const labels = ["asana-sync"];
  if (task.completed) labels.push("done");

  if (DRY_RUN) {
    console.log(`  [DRY RUN] Would create issue: "${title}"`);
    return null;
  }

  const res = await githubRequest(
    "POST",
    `/repos/${GITHUB_OWNER}/${GITHUB_REPO}/issues`,
    { title, body, labels }
  );

  if (res.status === 201) {
    console.log(`  ✅ Created issue #${res.data.number}: ${title}`);
    return res.data;
  } else {
    console.error(`  ❌ Failed to create issue: ${JSON.stringify(res.data)}`);
    return null;
  }
}

async function updateIssue(issueNumber, task) {
  const title = `[Asana] ${task.name}`;
  const body = buildIssueBody(task);
  const state = task.completed ? "closed" : "open";

  if (DRY_RUN) {
    console.log(`  [DRY RUN] Would update issue #${issueNumber}: "${title}" (${state})`);
    return;
  }

  const res = await githubRequest(
    "PATCH",
    `/repos/${GITHUB_OWNER}/${GITHUB_REPO}/issues/${issueNumber}`,
    { title, body, state }
  );

  if (res.status === 200) {
    console.log(`  🔄 Updated issue #${issueNumber}: ${title} (${state})`);
  } else {
    console.error(`  ❌ Failed to update issue: ${JSON.stringify(res.data)}`);
  }
}

function buildIssueBody(task) {
  const lines = [
    `> 🔄 Cette issue a été synchronisée automatiquement depuis [Asana](${task.permalink_url}).`,
    `> **Ne pas modifier manuellement** — les changements seront écrasés lors de la prochaine synchronisation.`,
    ``,
    `## Description`,
    ``,
    task.notes
      ? task.notes
      : "_Aucune description fournie dans Asana._",
    ``,
    `## Métadonnées Asana`,
    ``,
    `| Champ | Valeur |`,
    `|-------|--------|`,
    `| 🆔 GID | \`${task.gid}\` |`,
    `| 📅 Échéance | ${task.due_on || "Non définie"} |`,
    `| 👤 Assigné | ${task.assignee ? task.assignee.name : "Non assigné"} |`,
    `| ✅ Complété | ${task.completed ? "Oui" : "Non"} |`,
    `| 🔗 Lien Asana | [Ouvrir dans Asana](${task.permalink_url}) |`,
  ];

  // Add custom fields if any
  if (task.custom_fields && task.custom_fields.length > 0) {
    const relevantFields = task.custom_fields.filter(
      (f) => f.display_value || f.number_value
    );
    if (relevantFields.length > 0) {
      lines.push(``, `## Champs personnalisés`, ``);
      for (const field of relevantFields) {
        lines.push(`- **${field.name}**: ${field.display_value || field.number_value}`);
      }
    }
  }

  return lines.join("\n");
}

// ─── Main Sync Logic ──────────────────────────────────────────────────────────

async function main() {
  console.log(`\n🚀 Starting Asana → GitHub Issues sync`);
  console.log(`   Repository: ${GITHUB_OWNER}/${GITHUB_REPO}`);
  console.log(`   Project: ${ASANA_PROJECT_GID}\n`);

  const [tasks, existingIssues] = await Promise.all([
    fetchAsanaTasks(),
    getExistingIssues(),
  ]);

  // Build a map of existing issues by Asana GID
  const issuesByAsanaGid = new Map();
  for (const issue of existingIssues) {
    const gidMatch = issue.body && issue.body.match(/`(\d+)`.*GID/);
    if (gidMatch) {
      issuesByAsanaGid.set(gidMatch[1], issue);
    }
  }

  let created = 0;
  let updated = 0;
  let skipped = 0;

  for (const task of tasks) {
    // Skip subtasks (tasks with a parent)
    if (task.parent) {
      skipped++;
      continue;
    }

    const existingIssue = issuesByAsanaGid.get(task.gid);

    if (existingIssue) {
      // Update existing issue if content has changed
      await updateIssue(existingIssue.number, task);
      updated++;
    } else {
      // Create new issue
      await createIssue(task);
      created++;
    }

    // Rate limiting: avoid GitHub API rate limits (max 10 req/sec)
    await new Promise((resolve) => setTimeout(resolve, 200));
  }

  console.log(`\n📊 Sync Summary:`);
  console.log(`   ✅ Created: ${created}`);
  console.log(`   🔄 Updated: ${updated}`);
  console.log(`   ⏭️  Skipped (subtasks): ${skipped}`);
  console.log(`\n✨ Sync completed successfully!`);
}

main().catch((err) => {
  console.error("❌ Sync failed:", err);
  process.exit(1);
});
