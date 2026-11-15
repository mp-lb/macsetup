import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import * as fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { test } from 'node:test';

const script = fileURLToPath(new URL('../lib/claude-trust.mjs', import.meta.url));

function fixture(t, customConfig = false) {
  const home = fs.mkdtempSync(path.join(os.tmpdir(), 'macsetup-trust-'));
  t.after(() => fs.rmSync(home, { recursive: true, force: true }));
  const workspace = path.join(home, 'Work with spaces');
  fs.mkdirSync(workspace);
  const configDir = customConfig ? path.join(home, 'custom config') : home;
  const configPath = path.join(configDir, '.claude.json');
  const env = { ...process.env, HOME: home };
  delete env.CLAUDE_CONFIG_DIR;
  if (customConfig) env.CLAUDE_CONFIG_DIR = configDir;
  const run = (...args) => spawnSync(process.execPath, [script, workspace, ...args], { env, encoding: 'utf8' });
  return { home, workspace, configPath, run };
}

test('creates private trust config for a custom workspace and is idempotent', (t) => {
  const { workspace, configPath, run } = fixture(t);
  assert.equal(run('--check').status, 1);
  assert.equal(fs.existsSync(configPath), false);
  assert.equal(run().status, 0);
  const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
  assert.deepEqual(Object.keys(config.projects), [fs.realpathSync(workspace)]);
  assert.equal(config.projects[fs.realpathSync(workspace)].hasTrustDialogAccepted, true);
  assert.equal(fs.statSync(configPath).mode & 0o777, 0o600);
  const before = fs.statSync(configPath).mtimeMs;
  assert.equal(run().status, 0);
  assert.equal(run('--check').status, 0);
  assert.equal(fs.statSync(configPath).mtimeMs, before);
});

test('preserves other settings and projects in a custom Claude config directory', (t) => {
  const { home, workspace, configPath, run } = fixture(t, true);
  fs.mkdirSync(path.dirname(configPath));
  const root = fs.realpathSync(workspace);
  const config = { theme: 'dark', projects: { '/other': { hasTrustDialogAccepted: false }, [root]: { allowedTools: ['Read'], hasTrustDialogAccepted: false } } };
  fs.writeFileSync(configPath, JSON.stringify(config));
  assert.equal(run().status, 0);
  config.projects[root].hasTrustDialogAccepted = true;
  assert.deepEqual(JSON.parse(fs.readFileSync(configPath, 'utf8')), config);
  assert.equal(fs.existsSync(path.join(home, '.claude.json')), false);
});

test('rejects malformed JSON and invalid config shapes without overwriting them', (t) => {
  const { workspace, configPath, run } = fixture(t);
  const root = fs.realpathSync(workspace);
  for (const original of ['{broken', '', 'null', '[]', '{"projects":[]}', JSON.stringify({ projects: { [root]: null } })]) {
    fs.writeFileSync(configPath, original);
    assert.equal(run().status, 1);
    assert.equal(fs.readFileSync(configPath, 'utf8'), original);
  }
});

test('preserves config symlinks and resolves the workspace physical path', (t) => {
  const { home, workspace, configPath, run } = fixture(t);
  const target = path.join(home, 'shared.json');
  fs.writeFileSync(target, '{}');
  fs.symlinkSync(target, configPath);
  const actualWorkspace = path.join(home, 'actual workspace');
  fs.renameSync(workspace, actualWorkspace);
  fs.symlinkSync(actualWorkspace, workspace);
  assert.equal(run().status, 0);
  assert.equal(fs.lstatSync(configPath).isSymbolicLink(), true);
  const config = JSON.parse(fs.readFileSync(target, 'utf8'));
  assert.deepEqual(Object.keys(config.projects), [fs.realpathSync(actualWorkspace)]);
  assert.equal(run('--check').status, 0);
});
