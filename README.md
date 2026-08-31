# Vortex Studio documentation

The source for [vortex.protonn.co.uk](https://vortex.protonn.co.uk/).

Documentation pages live in `content/`. `content/navigation.json` sets their sidebar order. The build reads those Markdown files and generates the data used by the site, so the browser never fetches documentation from GitHub.

```sh
npm ci
npm run dev
```

Use `npm run validate` before opening a pull request. See [CONTRIBUTING.md](CONTRIBUTING.md) for the supported Markdown format.

Railway deploys `main`. A merged documentation change is compiled into the next site build.
