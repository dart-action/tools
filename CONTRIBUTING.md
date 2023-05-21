# CONTRIBUTING

Please submit changes to the main branch,
and make sure your code is willing to comply with Apache 2.0 style.

## About development

The repo is manage by [melos][], so you need to install it first.

```bash
dart pub global activate melos
```

Then you can run `melos bootstrap` to init the repo.

```bash
melos bootstrap
```

And run:

```bash
melos run get
```

to get all dependencies.

[melos]: https://melos.invertase.dev

## About CHANGELOG

The CHANGELOG for each package is make with `melos`.

So, if you want to open a pull request,
please make sure you commit message is follow [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/).

Just like: `feat: add new feature` or `fix: fix a bug`.

If you want to include a BREAKING CHANGE, please add `!` after `:`.

Just like: `feat!: add new feature`.

<!-- fix:, feat:, build:, chore:, ci:, docs:, style:, refactor:, perf:, test: -->

The type have next table:

| Type     | Description                                                                                                 |
| -------- | ----------------------------------------------------------------------------------------------------------- |
| fix      | A bug fix                                                                                                   |
| feat     | A new feature                                                                                               |
| build    | Changes that affect the build system or external dependencies                                               |
| chore    | Other changes that don't modify src or test files                                                           |
| ci       | Changes to our CI configuration files and scripts (example scopes: Travis, Circle, BrowserStack, SauceLabs) |
| docs     | Documentation only changes                                                                                  |
| style    | Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)      |
| refactor | A code change that neither fixes a bug nor adds a feature                                                   |
| perf     | A code change that improves performance                                                                     |
| test     | Adding missing tests or correcting existing tests                                                           |
