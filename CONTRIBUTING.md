# Contributing to ctoclient

Thanks for taking the time to contribute.

## Reporting a bug

Please [open an issue](https://github.com/GutUrago/ctoclient/issues) with a
minimal [reprex](https://reprex.tidyverse.org/). Because almost everything in
this package talks to a server, a reprex usually cannot be run by anyone else
— so instead include:

* the function call you made, with credentials redacted;
* the full error or warning text;
* the output of `sessionInfo()`;
* where possible, the relevant rows of the form's XLSForm definition.

Never paste a password, a private key, or respondent data into an issue.

## Suggesting a feature

Open an issue describing the problem you are trying to solve rather than the
solution you have in mind. SurveyCTO's API has a lot of corners, and the best
fit is often a different one from the one first imagined.

## Pull requests

* Open an issue first for anything beyond a typo, so the approach can be
  agreed before you spend time on it.
* This package is on CRAN and is used in automated pipelines, so backward
  compatibility matters. A change to an exported function's arguments or
  return value needs a clear justification.
* Follow the existing code style: base pipes, `dplyr`/`stringr` verbs,
  `.data` pronouns inside tidy evaluation, and a short comment above anything
  non-obvious explaining *why* rather than *what*.
* Add a test. Tests live in `tests/testthat/` and must not require a server —
  mock the network with `local_mocked_bindings()` or the fixtures in
  `tests/testthat/fixtures/`.
* Run `devtools::document()`, `devtools::test()` and `devtools::check()`
  before opening the PR.
* Add a bullet to `NEWS.md` under a "development version" heading.

## Code of conduct

By contributing you agree to abide by the
[Code of Conduct](CODE_OF_CONDUCT.md).
