# Contributing

Documentation is under `content/`. To change a page, edit its Markdown file. To add or move a page, update `content/navigation.json` as well.

Keep each pull request focused on one correction or related set of additions. Say which Vortex Studio version you checked when the change depends on runtime behavior.

## Page format

Each page needs one title, one short description, and at least one section:

````markdown
# Page title

One-sentence description.

## Section title

One paragraph of explanation.

| Member | Description |
| --- | --- |
| `object:Method(value: number): boolean` | What the member does. |

### LocalScript

```luau
print("A useful example")
```

> [!NOTE]
> A limit or detail that changes how the API is used.
````

An H3 directly above a code fence names that example. Every fence must use `luau`. Additional examples in the same section each need an H3.

Recovered source files stay in `public/source/`. A standalone link displays one as a source viewer:

```markdown
[VortexStudio_runtime_prelude.luau](/source/VortexStudio_runtime_prelude.luau)
```

Raw HTML is rejected. A section may have one paragraph, one member table, one note, one recovered source, and any number of named code examples.

## Check the change

```sh
npm ci
npm run validate
npm run lint
npm run build
```

Run `npm run content` if you want to refresh the generated TypeScript and `llms-full.txt` without a full build.
