import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { test } from 'node:test';

const source = readFileSync(new URL('../labeler.yml', import.meta.url), 'utf8');

function unquote(value) {
  return value.slice(1, -1);
}

function branchRules() {
  const rules = new Map();
  let label;
  for (const line of source.split('\n')) {
    const labelMatch = /^(?:'([^']+)'|([A-Za-z][A-Za-z ]*)):$/.exec(line);
    if (labelMatch) {
      label = labelMatch[1] ?? labelMatch[2];
      rules.set(label, []);
      continue;
    }
    const branchMatch = /head-branch: \[('[^']+'|"[^"]+")\]/.exec(line);
    if (branchMatch && label) {
      rules.get(label).push(new RegExp(unquote(branchMatch[1])));
    }
  }
  return rules;
}

function labelsForBranch(branch) {
  return [...branchRules()]
    .filter(([, patterns]) => patterns.some((pattern) => pattern.test(branch)))
    .map(([label]) => label)
    .sort();
}

function labelsForPaths(paths) {
  const predicates = {
    content: (path) => /^blog\//.test(path),
    docs: (path) => /^docs\/|\.(?:md|mdx)$/.test(path),
    test: (path) => /^(?:test|tests)\/|\.(?:test|spec)\./.test(path),
    build: (path) =>
      /^(?:package\.json|pnpm-lock\.yaml|pnpm-workspace\.yaml|tsconfig\.json|wrangler\.[^/]+)$/.test(
        path,
      ),
    ci: (path) => /^\.github\/(?:workflows\/|scripts\/|[^/]+\.yml$)/.test(path),
  };
  return Object.entries(predicates)
    .filter(([, matches]) => paths.every(matches))
    .map(([label]) => label);
}

test('branch fixtures produce the intended synchronized labels', () => {
  const fixtures = [
    ['breaking-change/feat/blog-article-api', ['BREAKING CHANGE', 'feat']],
    ['deprecated/fix/legacy-manifest', ['DEPRECATED', 'fix']],
    ['feat/blog-list-endpoint', ['feat']],
    ['perf/article-cache', ['perf']],
    ['fix/slug-normalization', ['fix']],
    ['revert/bad-change', ['revert']],
    // The article layer always serves main, so its branch classifies without a SemVer impact.
    ['content/new-article', ['content']],
    ['docs/operating-model', ['docs']],
    ['refactor/worker-router', ['refactor']],
    ['style/format', ['style']],
    ['test/openapi-contract', ['test']],
    ['build/dependencies', ['build']],
    ['ci/actions', ['ci']],
    ['chore/metadata', ['chore']],
    // Dependabot writes these prefixes because dependabot.yml sets pull-request-branch-name
    // to chore for both ecosystems, so a dependency bump lands in a non-versioning label.
    ['chore/github_actions/actions/setup-node-7.0.0', ['chore']],
    ['chore/npm_and_yarn/wrangler-4.120.0', ['chore']],
    ['dependabot/npm_and_yarn/wrangler-4.120.0', []],
  ];
  for (const [branch, labels] of fixtures) {
    assert.deepEqual(labelsForBranch(branch), labels.sort(), branch);
  }
});

// Deploy happens on every merged pull request and Product Release is decided in the flags
// repository, never by a branch. A branch that merely looks like a release must stay inert.
test('abolished release and rollback branches grant no label at all', () => {
  assert.doesNotMatch(source, /rollback/, 'no rule may mention a rollback branch');
  assert.doesNotMatch(source, /head-branch: \[[^\]]*release/, 'no rule may gate on release/');

  for (const branch of [
    'release/v0.2.0/content',
    'release/v1.0.0',
    'rollback/v0.2.1/content',
    'rollback/v1.0.0',
  ]) {
    assert.deepEqual(labelsForBranch(branch), [], branch);
  }
});

test('path-only rules use one combined all-files glob', () => {
  // Prettier wraps a long enough glob into a multi-line array with a trailing comma, so the
  // pattern must survive both renderings or a later glob edit would break extraction.
  const patterns = [...source.matchAll(/any-glob-to-all-files:\s*\[\s*'([^']+)',?\s*\]/g)].map(
    (match) => match[1],
  );
  assert.deepEqual(patterns, [
    'blog/**',
    '{docs/**,**/*.md,**/*.mdx}',
    '{test/**,tests/**,**/*.test.*,**/*.spec.*}',
    '{package.json,pnpm-lock.yaml,pnpm-workspace.yaml,tsconfig.json,wrangler.*}',
    '.github/{workflows/**,scripts/**,*.yml}',
  ]);

  const fixtures = [
    // Articles are MDX, so an article also matches the docs glob. Both labels are
    // non-versioning, so the overlap can never imply a SemVer impact on the delivery service.
    [['blog/first-post.mdx'], ['content', 'docs']],
    // Article media is not markup, so a post shipped with its media stays content only.
    [['blog/first-post.mdx', 'blog/first-post/hero.png'], ['content']],
    [['blog/first-post.mdx', 'src/worker.ts'], []],
    [['README.md', 'docs/adr/0001-repository-boundary.md'], ['docs']],
    [['docs/features/article-authoring.feature'], ['docs']],
    [['openapi/content.openapi.json'], []],
    [['package.json', 'pnpm-lock.yaml'], ['build']],
    [['wrangler.jsonc'], ['build']],
    [['package.json', 'README.md'], []],
    [['.github/workflows/deploy.yml', '.github/scripts/policy.mjs'], ['ci']],
    [['.github/dependabot.yml', '.github/labeler.yml'], ['ci']],
    [['.github/workflows/ci.yml', 'package.json'], []],
    // The .github README is documentation, not automation, so it stays out of ci.
    [['.github/README.md'], ['docs']],
  ];
  for (const [paths, labels] of fixtures) {
    assert.deepEqual(labelsForPaths(paths), labels, paths.join(', '));
  }
});
