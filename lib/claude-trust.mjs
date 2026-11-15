import * as fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';

// Claude Code stores trust in .claude.json, not settings.json.
// https://code.claude.com/docs/en/permissions#project-allow-rules-and-workspace-trust
const [workspace, mode] = process.argv.slice(2);
if (!workspace || (mode !== undefined && mode !== '--check')) {
  console.error('Usage: node lib/claude-trust.mjs <workspace> [--check]');
  process.exit(1);
}

function requireObject(value, label) {
  if (value === null || typeof value !== 'object' || Array.isArray(value)) {
    throw new Error(`${label} must be a JSON object; existing config was not changed`);
  }
  return value;
}

try {
  const root = fs.realpathSync(workspace);
  if (!fs.statSync(root).isDirectory()) throw new Error('Workspace must be a directory');
  let configPath = path.join(process.env.CLAUDE_CONFIG_DIR || os.homedir(), '.claude.json');
  // Preserve an existing symlink to a shared config.
  if (fs.existsSync(configPath)) configPath = fs.realpathSync(configPath);
  let original;
  try {
    original = fs.readFileSync(configPath, 'utf8');
  } catch (error) {
    if (error.code !== 'ENOENT') throw error;
  }
  const config = requireObject(original === undefined ? {} : JSON.parse(original), 'Claude config');
  const projects = requireObject(config.projects === undefined ? {} : config.projects, 'projects');
  const project = requireObject(projects[root] === undefined ? {} : projects[root], 'Workspace config');

  if (mode === '--check') {
    process.exit(project.hasTrustDialogAccepted === true ? 0 : 1);
  }
  if (project.hasTrustDialogAccepted !== true) {
    project.hasTrustDialogAccepted = true;
    projects[root] = project;
    config.projects = projects;
    fs.mkdirSync(path.dirname(configPath), { recursive: true });
    const temporaryPath = `${configPath}.macsetup-${process.pid}`;
    try {
      fs.writeFileSync(temporaryPath, `${JSON.stringify(config, null, 2)}\n`, { mode: 0o600, flag: 'wx' });
      fs.renameSync(temporaryPath, configPath);
    } finally {
      fs.rmSync(temporaryPath, { force: true });
    }
  }
  console.log(`Claude Code trusts ${root}`);
} catch (error) {
  console.error(`Claude Code workspace trust: ${error.message}`);
  process.exit(1);
}
