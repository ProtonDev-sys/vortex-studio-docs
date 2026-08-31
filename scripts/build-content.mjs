import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { marked } from 'marked';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const contentRoot = path.join(root, 'content');
const publicRoot = path.join(root, 'public');
const checkOnly = process.argv.includes('--check');
const verifyMigration = process.argv.includes('--migration');

function fail(file, message) {
  throw new Error(`${path.relative(root, file)}: ${message}`);
}

function plain(tokens, file) {
  return (tokens ?? []).map((token) => {
    if (token.type === 'br') return '\n';
    if (token.type === 'text' || token.type === 'escape' || token.type === 'codespan') return token.text;
    if (token.type === 'strong' || token.type === 'em' || token.type === 'del' || token.type === 'link') {
      return plain(token.tokens, file);
    }
    fail(file, `unsupported inline Markdown: ${token.type}`);
  }).join('');
}

function rejectHtml(value, file, seen = new WeakSet()) {
  if (!value || typeof value !== 'object' || seen.has(value)) return;
  seen.add(value);
  if (value.type === 'html') fail(file, 'raw HTML is not allowed');
  for (const child of Object.values(value)) {
    if (Array.isArray(child)) child.forEach((item) => rejectHtml(item, file, seen));
    else rejectHtml(child, file, seen);
  }
}

function sourceFromParagraph(token, file) {
  const inline = (token.tokens ?? []).filter((item) => item.type !== 'space');
  if (inline.length !== 1 || inline[0].type !== 'link') return undefined;
  const link = inline[0];
  if (!/^\/source\/[A-Za-z0-9._-]+\.luau$/.test(link.href)) return undefined;
  const target = path.resolve(publicRoot, `.${link.href}`);
  if (!target.startsWith(`${publicRoot}${path.sep}`) || !fs.existsSync(target)) {
    fail(file, `missing source file ${link.href}`);
  }
  return { title: plain(link.tokens, file), href: link.href };
}

function parseNote(token, file) {
  const lines = token.raw.split(/\r?\n/).map((line) => line.replace(/^>\s?/, ''));
  if (lines.shift()?.trim() !== '[!NOTE]') fail(file, 'only [!NOTE] blockquotes are supported');
  const note = lines.join('\n').trim();
  if (!note) fail(file, 'note text is empty');
  return note;
}

function parsePage(file, id, group) {
  const markdown = fs.readFileSync(file, 'utf8');
  const tokens = marked.lexer(markdown, { gfm: true });
  rejectHtml(tokens, file);

  let title;
  let description;
  let section;
  let caption;
  const sections = [];

  for (const token of tokens) {
    if (token.type === 'space') continue;
    if (token.type === 'heading') {
      const text = plain(token.tokens, file).trim();
      if (!text) fail(file, 'heading is empty');
      if (token.depth === 1) {
        if (title || description || sections.length) fail(file, 'the H1 must be first and unique');
        title = text;
      } else if (token.depth === 2) {
        if (!title || !description) fail(file, 'add the title and description before the first section');
        if (caption) fail(file, `example heading “${caption}” has no code block`);
        if (sections.some((item) => item.heading === text)) fail(file, `duplicate section heading “${text}”`);
        section = { heading: text };
        sections.push(section);
      } else if (token.depth === 3) {
        if (!section) fail(file, 'example headings must be inside a section');
        if (caption) fail(file, `example heading “${caption}” has no code block`);
        caption = text;
      } else {
        fail(file, 'only H1, H2, and H3 headings are supported');
      }
      continue;
    }

    if (token.type === 'paragraph') {
      if (!title) fail(file, 'add an H1 before the description');
      if (!description && !section) {
        description = plain(token.tokens, file).trim();
        if (!description) fail(file, 'description is empty');
        continue;
      }
      if (!section) fail(file, 'content must be inside an H2 section');
      const source = sourceFromParagraph(token, file);
      if (source) {
        if (section.source) fail(file, 'a section can include one recovered source file');
        section.source = source;
      } else {
        if (section.body) fail(file, 'a section can include one body paragraph');
        section.body = plain(token.tokens, file).trim();
      }
      continue;
    }

    if (!section) fail(file, `${token.type} must be inside an H2 section`);

    if (token.type === 'table') {
      const headers = token.header.map((cell) => plain(cell.tokens, file).trim());
      if (headers.length !== 2 || headers[0] !== 'Member' || headers[1] !== 'Description') {
        fail(file, 'tables must use the columns Member and Description');
      }
      section.signatures ??= [];
      for (const row of token.rows) {
        if (row.length !== 2) fail(file, 'member table rows need two cells');
        const name = plain(row[0].tokens, file).trim();
        const descriptionText = plain(row[1].tokens, file).trim();
        if (!name || !descriptionText) fail(file, 'member table cells cannot be empty');
        if (section.signatures.some((item) => item.name === name)) fail(file, `duplicate member “${name}”`);
        section.signatures.push({ name, description: descriptionText });
      }
    } else if (token.type === 'code') {
      const language = token.lang?.trim().toLowerCase();
      if (language !== 'luau') fail(file, 'code fences must use the luau language tag');
      const example = { title: caption, code: token.text };
      caption = undefined;
      if (!section.code) {
        section.code = example.code;
        if (example.title) section.exampleTitle = example.title;
      } else {
        if (!example.title) fail(file, 'additional code blocks need an H3 title');
        section.additionalExamples ??= [];
        section.additionalExamples.push(example);
      }
    } else if (token.type === 'blockquote') {
      if (section.note) fail(file, 'a section can include one note');
      section.note = parseNote(token, file);
    } else {
      fail(file, `unsupported block Markdown: ${token.type}`);
    }
  }

  if (!title) fail(file, 'missing H1 title');
  if (!description) fail(file, 'missing description paragraph');
  if (!sections.length) fail(file, 'add at least one H2 section');
  if (caption) fail(file, `example heading “${caption}” has no code block`);
  return { id, group, title, description, sections, markdown };
}

function contentFiles(directory) {
  return fs.readdirSync(directory, { withFileTypes: true }).flatMap((entry) => {
    const target = path.join(directory, entry.name);
    return entry.isDirectory() ? contentFiles(target) : target.endsWith('.md') ? [target] : [];
  });
}

const manifestFile = path.join(contentRoot, 'navigation.json');
const navigation = JSON.parse(fs.readFileSync(manifestFile, 'utf8'));
if (!Array.isArray(navigation) || !navigation.length) fail(manifestFile, 'expected a non-empty group array');

const ids = new Set();
const files = new Set();
const groups = new Set();
const pages = [];
for (const entry of navigation) {
  if (!entry || typeof entry.group !== 'string' || !entry.group.trim() || !Array.isArray(entry.pages) || !entry.pages.length) {
    fail(manifestFile, 'each group needs a name and at least one page');
  }
  if (groups.has(entry.group)) fail(manifestFile, `duplicate group “${entry.group}”`);
  groups.add(entry.group);
  for (const page of entry.pages) {
    if (!page || typeof page.id !== 'string' || !/^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(page.id)) {
      fail(manifestFile, 'page ids must use lowercase kebab-case');
    }
    if (ids.has(page.id)) fail(manifestFile, `duplicate page id “${page.id}”`);
    ids.add(page.id);
    if (typeof page.file !== 'string' || page.file !== page.file.replaceAll('\\', '/') || !page.file.endsWith(`/${page.id}.md`)) {
      fail(manifestFile, `invalid file path for “${page.id}”`);
    }
    const file = path.resolve(contentRoot, page.file);
    if (!file.startsWith(`${contentRoot}${path.sep}`) || !fs.existsSync(file)) fail(manifestFile, `missing ${page.file}`);
    if (files.has(file)) fail(manifestFile, `duplicate file ${page.file}`);
    files.add(file);
    pages.push(parsePage(file, page.id, entry.group));
  }
}

const unlisted = contentFiles(contentRoot).filter((file) => !files.has(file));
if (unlisted.length) fail(manifestFile, `unlisted Markdown: ${unlisted.map((file) => path.relative(contentRoot, file)).join(', ')}`);

const serializablePages = pages.map(({ markdown: _markdown, ...page }) => page);
const generated = `// Generated by scripts/build-content.mjs. Edit content/*.md instead.\n\n` +
`export type Signature = { name: string; description: string };\n` +
`export type CodeExample = { title: string; code: string; language?: string };\n` +
`export type DocLink = { label: string; href: string; download?: boolean };\n` +
`export type SourceFile = { title: string; href: string };\n` +
`export type DocSection = { heading: string; body?: string; signatures?: Signature[]; code?: string; exampleTitle?: string; language?: string; additionalExamples?: CodeExample[]; links?: DocLink[]; source?: SourceFile; note?: string };\n` +
`export type DocPage = { id: string; group: string; title: string; description: string; sections: DocSection[] };\n\n` +
`export const pages: DocPage[] = ${JSON.stringify(serializablePages, null, 2)};\n\n` +
`export const groupedPages = Array.from(new Set(pages.map((page) => page.group))).map((group) => ({\n` +
`  group,\n  pages: pages.filter((page) => page.group === group),\n}));\n`;

const llms = [
  '# Vortex Studio documentation',
  '',
  'Complete reference for the Vortex Studio Luau runtime and recovered Luau sources.',
  '',
];
for (const group of navigation) {
  llms.push(`## ${group.group}`, '');
  for (const item of group.pages) {
    const page = pages.find((candidate) => candidate.id === item.id);
    llms.push(`Page: https://vortex.protonn.co.uk/#${page.id}`, '');
    llms.push(page.markdown.replace(/^### /gm, '##### ').replace(/^## /gm, '#### ').replace(/^# /gm, '### ').trim(), '');
  }
}
llms.push('## Recovered Luau sources', '');
for (const page of pages) {
  for (const section of page.sections) {
    if (!section.source) continue;
    const sourceFile = path.join(publicRoot, `.${section.source.href}`);
    llms.push(`### ${section.source.title}`, '', '```luau', fs.readFileSync(sourceFile, 'utf8').trim(), '```', '');
  }
}

const outputs = new Map([
  [path.join(root, 'app/generated-docs.ts'), generated],
  [path.join(publicRoot, 'llms-full.txt'), `${llms.join('\n').trimEnd()}\n`],
]);
if (!checkOnly) {
  for (const [file, value] of outputs) fs.writeFileSync(file, value);
}

const totals = {
  pages: pages.length,
  groups: groups.size,
  sections: pages.reduce((count, page) => count + page.sections.length, 0),
  members: pages.flatMap((page) => page.sections).reduce((count, item) => count + (item.signatures?.length ?? 0), 0),
  examples: pages.flatMap((page) => page.sections).reduce((count, item) => count + (item.code ? 1 : 0) + (item.additionalExamples?.length ?? 0), 0),
  notes: pages.flatMap((page) => page.sections).filter((item) => item.note).length,
  sources: pages.flatMap((page) => page.sections).filter((item) => item.source).length,
  downloadLinks: pages.flatMap((page) => page.sections).reduce(
    (count, item) => count + (item.links?.filter((link) => link.download).length ?? 0),
    0,
  ),
};
if (verifyMigration) {
  const expected = { pages: 21, groups: 8, sections: 53, members: 196, examples: 29, notes: 7, sources: 2, downloadLinks: 0 };
  for (const [key, value] of Object.entries(expected)) {
    if (totals[key] !== value) fail(manifestFile, `migration parity failed for ${key}: expected ${value}, found ${totals[key]}`);
  }
}
console.log(Object.entries(totals).map(([key, value]) => `${key}: ${value}`).join(', '));
