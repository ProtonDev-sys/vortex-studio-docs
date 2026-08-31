import { useEffect, useRef, useState } from 'react';
import { groupedPages, pages, type DocPage } from './generated-docs';

const LUAU_KEYWORDS = new Set([
  'and', 'break', 'continue', 'do', 'else', 'elseif', 'end', 'export', 'for', 'function', 'if', 'in',
  'local', 'not', 'or', 'repeat', 'return', 'then', 'until', 'while',
]);

const LUAU_LITERALS = new Set(['false', 'nil', 'true']);
const LUAU_BUILTINS = new Set([
  'assert', 'coroutine', 'delay', 'Enum', 'error', 'game', 'Instance', 'ipairs', 'math', 'next', 'pairs',
  'pcall', 'print', 'select', 'setmetatable', 'Signal', 'spawn', 'string', 'table', 'task', 'tonumber',
  'tostring', 'type', 'typeof', 'unpack', 'wait', 'warn', 'workspace', 'xpcall',
]);
const LUAU_TYPES = new Set(['any', 'boolean', 'CFrame', 'Color3', 'Connection', 'EnumItem', 'EnumType', 'number', 'string', 'thread', 'Tween', 'TweenInfo', 'Vector3']);
const TOKEN_PATTERN = /(--\[\[[\s\S]*?\]\]|--[^\n]*|"(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*'|\b0x[\da-fA-F]+\b|\b\d+(?:\.\d+)?(?:[eE][+-]?\d+)?\b|[A-Za-z_]\w*|\s+|.)/g;

function highlightedLuau(source: string) {
  const tokens = source.match(TOKEN_PATTERN) ?? [source];
  return tokens.map((token, index) => {
    let kind = '';
    if (token.startsWith('--')) kind = 'comment';
    else if (/^["']/.test(token)) kind = 'string';
    else if (/^(?:0x[\da-f]+|\d)/i.test(token)) kind = 'number';
    else if (LUAU_LITERALS.has(token)) kind = 'literal';
    else if (LUAU_KEYWORDS.has(token)) kind = 'keyword';
    else if (LUAU_TYPES.has(token)) kind = 'type';
    else if (LUAU_BUILTINS.has(token)) kind = 'builtin';
    else if (/^[A-Za-z_]\w*$/.test(token)) {
      const previous = tokens.slice(0, index).findLast((part) => !/^\s+$/.test(part));
      const next = tokens.slice(index + 1).find((part) => !/^\s+$/.test(part));
      if (next === '(' || previous === ':') kind = 'function';
      else if (previous === '.') kind = 'property';
    }
    return kind ? <span className={`token-${kind}`} key={index}>{token}</span> : token;
  });
}

function SyntaxCode({ code }: { code: string }) {
  return <>{highlightedLuau(code)}</>;
}

function CodeBlock({ code, title }: { code: string; title?: string }) {
  const [copyStatus, setCopyStatus] = useState('');
  const [expanded, setExpanded] = useState(false);
  const lines = code.split('\n');
  const canExpand = lines.length > 18;
  const copied = copyStatus === 'Code copied to clipboard';

  async function copy() {
    try {
      await navigator.clipboard.writeText(code);
      setCopyStatus('Code copied to clipboard');
    } catch {
      setCopyStatus('Could not copy code');
    }
    window.setTimeout(() => setCopyStatus(''), 1400);
  }

  return (
    <figure className="code-sample">
      {title && <figcaption>{title}</figcaption>}
      <div className={`code-block${expanded ? ' expanded' : ''}`}>
        <div className="code-actions">
          {canExpand && (
            <button
              type="button"
              className="code-action"
              onClick={() => setExpanded(!expanded)}
              aria-label={expanded ? 'Collapse code block' : 'Expand code block'}
              aria-expanded={expanded}
              title={expanded ? 'Collapse code' : 'Expand code'}
            >
              {expanded ? (
                <svg viewBox="0 0 16 16" aria-hidden="true"><path d="M6.5 2v4.5H2M9.5 14V9.5H14M2.5 6 6 2.5M13.5 10 10 13.5" /></svg>
              ) : (
                <svg viewBox="0 0 16 16" aria-hidden="true"><path d="M6 2H2v4M10 14h4v-4M2.5 5.5 6 2M13.5 10.5 10 14" /></svg>
              )}
            </button>
          )}
          <button
            type="button"
            className="code-action"
            onClick={() => void copy()}
            aria-label={`Copy${title ? ` ${title}` : ''} code to clipboard`}
            title={copied ? 'Copied' : 'Copy code'}
          >
            {copied ? (
              <svg viewBox="0 0 16 16" aria-hidden="true"><path d="m3 8.5 3 3 7-7" /></svg>
            ) : (
              <svg viewBox="0 0 16 16" aria-hidden="true"><rect x="5" y="5" width="8" height="8" rx="1" /><path d="M11 5V3a1 1 0 0 0-1-1H3a1 1 0 0 0-1 1v7a1 1 0 0 0 1 1h2" /></svg>
            )}
          </button>
        </div>
        <pre><code>{lines.map((line, index) => (
          <span className="code-line" key={`${index}-${line}`}>
            <span className="line-number" aria-hidden="true">{index + 1}</span>
            <span className="line-source">{line.length === 0 ? '\u00a0' : <SyntaxCode code={line} />}</span>
          </span>
        ))}</code></pre>
      </div>
      <output className="sr-only" aria-live="polite">{copyStatus}</output>
    </figure>
  );
}

function SourceBlock({ href, title }: { href: string; title: string }) {
  const [source, setSource] = useState<string>();
  const [failed, setFailed] = useState(false);

  useEffect(() => {
    const controller = new AbortController();
    fetch(href, { signal: controller.signal })
      .then((response) => {
        if (!response.ok) throw new Error(`Source request failed with ${response.status}`);
        return response.text();
      })
      .then(setSource)
      .catch((error: unknown) => {
        if (!(error instanceof DOMException && error.name === 'AbortError')) setFailed(true);
      });
    return () => controller.abort();
  }, [href]);

  if (failed) return <p className="source-status">Could not load the source. <a href={href}>Open the raw file</a>.</p>;
  if (source === undefined) return <p className="source-status">Loading source…</p>;
  return <CodeBlock code={source.replace(/^\r?\n/, '').replace(/\r?\n$/, '')} title={title} />;
}

function sectionId(pageId: string, heading: string) {
  return `${pageId}-${heading.toLowerCase().replaceAll(' ', '-')}`;
}

function pageSearchText(page: DocPage) {
  return [
    page.group,
    page.title,
    page.description,
    ...page.sections.flatMap((section) => [
      section.heading,
      section.body ?? '',
      section.code ?? '',
      ...(section.links ?? []).map((link) => link.label),
      ...(section.additionalExamples ?? []).flatMap((example) => [example.title, example.code]),
      ...(section.signatures ?? []).flatMap((signature) => [signature.name, signature.description]),
    ]),
  ].join(' ').toLowerCase();
}

function Nav({ activeId, onSelect, query }: { activeId: string; onSelect: (id: string) => void; query: string }) {
  const terms = query.trim().toLowerCase().split(/\s+/).filter(Boolean);
  const activeGroup = pages.find((page) => page.id === activeId)?.group;
  const visibleGroups = groupedPages
    .map(({ group, pages: groupPages }) => ({
      group,
      pages: terms.length ? groupPages.filter((page) => terms.every((term) => pageSearchText(page).includes(term))) : groupPages,
    }))
    .filter(({ pages: groupPages }) => groupPages.length > 0);

  return (
    <nav className="docs-nav" aria-label="Documentation">
      {visibleGroups.length ? visibleGroups.map(({ group, pages: groupPages }) => {
        const expanded = terms.length > 0 || group === activeGroup;
        return (
          <details className="nav-group" open={expanded ? true : undefined} key={`${group}-${expanded}`}>
            <summary>
              <span>{group}</span>
              <svg viewBox="0 0 16 16" aria-hidden="true"><path d="m4 6 4 4 4-4" /></svg>
            </summary>
            <div className="nav-pages">
              {groupPages.map((page) => (
                <button className={page.id === activeId ? 'active' : ''} key={page.id} onClick={() => onSelect(page.id)}>
                  {page.title}
                </button>
              ))}
            </div>
          </details>
        );
      }) : <p className="nav-empty">No matching pages</p>}
    </nav>
  );
}

function PageContent({ page }: { page: DocPage }) {
  return (
    <article className="article" key={page.id}>
      <p className="breadcrumb">{page.group}</p>
      <h1>{page.title}</h1>
      <p className="summary">{page.description}</p>
      {page.sections.map((section) => (
        <section key={section.heading} id={sectionId(page.id, section.heading)}>
          <h2>{section.heading}</h2>
          {section.body && <p>{section.body}</p>}
          {section.signatures && (
            <div className="signature-list">
              {section.signatures.map((signature) => (
                <div className="signature" key={signature.name}>
                  <code><SyntaxCode code={signature.name} /></code>
                  <p>{signature.description}</p>
                </div>
              ))}
            </div>
          )}
          {section.code && <CodeBlock code={section.code} title={section.exampleTitle} />}
          {section.additionalExamples?.map((example) => (
            <CodeBlock code={example.code} title={example.title} key={example.title} />
          ))}
          {section.source && <SourceBlock href={section.source.href} title={section.source.title} key={section.source.href} />}
          {section.links?.some((link) => !link.download) && (
            <div className="resource-links">
              {section.links.filter((link) => !link.download).map((link) => (
                <a href={link.href} download={link.download} key={link.href}>{link.label}<span aria-hidden="true">↓</span></a>
              ))}
            </div>
          )}
          {section.note && <aside className="note"><strong>Note</strong><p>{section.note}</p></aside>}
        </section>
      ))}
    </article>
  );
}

function PageToc({ page }: { page: DocPage }) {
  return (
    <aside className="page-toc" aria-label="On this page">
      <strong>On this page</strong>
      {page.sections.map((section) => (
        <a href={`#${sectionId(page.id, section.heading)}`} key={section.heading}>{section.heading}</a>
      ))}
    </aside>
  );
}

export default function Home() {
  const [activeId, setActiveId] = useState('introduction');
  const [query, setQuery] = useState('');
  const [mobileNav, setMobileNav] = useState(false);
  const searchRef = useRef<HTMLInputElement>(null);
  const activeIndex = Math.max(0, pages.findIndex((page) => page.id === activeId));
  const activePage = pages[activeIndex];

  function selectPage(id: string) {
    setActiveId(id);
    setQuery('');
    setMobileNav(false);
    window.history.replaceState(null, '', `#${id}`);
    window.scrollTo({ top: 0, behavior: 'instant' });
  }

  useEffect(() => {
    const fromHash = window.location.hash.slice(1);
    const hashTimer = window.setTimeout(() => {
      const hashPage = pages.find((page) => page.id === fromHash || page.sections.some((section) => sectionId(page.id, section.heading) === fromHash));
      if (hashPage) {
        setActiveId(hashPage.id);
        if (fromHash !== hashPage.id) window.setTimeout(() => document.getElementById(fromHash)?.scrollIntoView(), 0);
      }
    }, 0);

    function shortcut(event: KeyboardEvent) {
      if ((event.key === '/' || ((event.ctrlKey || event.metaKey) && event.key.toLowerCase() === 'k')) && document.activeElement?.tagName !== 'INPUT') {
        event.preventDefault();
        setMobileNav(true);
        window.setTimeout(() => searchRef.current?.focus(), 0);
      }
      if (event.key === 'Escape') {
        setQuery('');
        setMobileNav(false);
        searchRef.current?.blur();
      }
    }
    window.addEventListener('keydown', shortcut);
    return () => {
      window.clearTimeout(hashTimer);
      window.removeEventListener('keydown', shortcut);
    };
  }, []);

  return (
    <div className="docs-shell">
      <header className="header">
        <button className="mobile-menu" onClick={() => setMobileNav(!mobileNav)} aria-label="Toggle navigation">
          {mobileNav ? '×' : '≡'}
        </button>
        <button className="logo" onClick={() => selectPage('introduction')}>
          <img src="/vortex-studio-icon.png" width="27" height="27" alt="" aria-hidden="true" />
          Documentation
        </button>
        <span className="header-label">Vortex Studio v0.3.4</span>
      </header>

      <aside className={`sidebar ${mobileNav ? 'open' : ''}`}>
        <div className="nav-search">
          <svg viewBox="0 0 16 16" aria-hidden="true"><circle cx="7" cy="7" r="4.5" /><path d="m10.5 10.5 3 3" /></svg>
          <input ref={searchRef} value={query} onChange={(event) => setQuery(event.target.value)} placeholder="Search reference" aria-label="Search reference" />
          {query ? <button type="button" onClick={() => { setQuery(''); searchRef.current?.focus(); }} aria-label="Clear search">×</button> : <kbd>/</kbd>}
        </div>
        <Nav activeId={activeId} onSelect={selectPage} query={query} />
      </aside>
      {mobileNav && <button className="scrim" aria-label="Close navigation" onClick={() => setMobileNav(false)} />}

      <main>
        <div className="page-layout">
          <div className="page-column">
            <PageContent page={activePage} />
            <nav className="pagination" aria-label="Page navigation">
              {activeIndex > 0 ? <button onClick={() => selectPage(pages[activeIndex - 1].id)}><b aria-hidden="true">‹</b><span><small>Previous</small>{pages[activeIndex - 1].title}</span></button> : <span />}
              {activeIndex < pages.length - 1 ? <button className="next" onClick={() => selectPage(pages[activeIndex + 1].id)}><span><small>Next</small>{pages[activeIndex + 1].title}</span><b aria-hidden="true">›</b></button> : <span />}
            </nav>
          </div>
          <PageToc page={activePage} />
        </div>
      </main>
    </div>
  );
}
