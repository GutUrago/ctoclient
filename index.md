# ctoclient: A Modern and Flexible Data Pipeline for ‘SurveyCTO’

**`ctoclient`** is a modern, fast, and flexible high-level R client for
the [SurveyCTO REST API](https://developer.surveycto.com/). Built on top
of the robust [httr2](https://httr2.r-lib.org/) framework, it provides a
consistent and pipe-friendly interface for programmatic access to server
resources.

## Why use `ctoclient`?

- **Analysis Ready:** Automatically tidies messy API responses into
  clean data frames.
- **Encrypted Data Support:** Seamlessly handle encrypted forms with
  private keys.
- **Full Resource Coverage:** Manage forms, server datasets,
  attachments, and metadata.
- **Modern Auth:** Robust session handling and secure credential
  management.
- **Extendable:** Built on `httr2` request objects, allowing for easy
  customization and extension of API requests.
- **Stata Integration:** Built-in tools for generating `.do` files and
  templates for legacy pipelines.

## Installation

Install the stable version from CRAN:

``` r

install.packages("ctoclient")
```

Or get the development version with the latest features:

``` r

# install.packages("pak")
pak::pak("GutUrago/ctoclient")
```

## Quick start

Connect once, then work. Every function picks up the active session on
its own, so there is no connection object to pass around.

``` r

library(ctoclient)

# Leave the password out and you are prompted for it securely
cto_connect(server = "myorg", username = "admin@example.com")

# What is on the server?
cto_form_ids()

# Download and tidy submissions
data <- cto_form_data("baseline_survey")

# Download the photos respondents submitted
cto_form_data_attachment("baseline_survey", fields = ends_with("_img"))

# Label a Stata export, and generate a Word copy of the form for review
cto_form_dofile("baseline_survey", path = "baseline_labels.do")
cto_form_docx("baseline_survey", path = "baseline_review.docx")
```

[`cto_form_data()`](https://guturago.github.io/ctoclient/reference/cto_form_data.md)
does real work on your behalf: it types numeric, date and datetime
fields from the form definition, drops structural rows, splits geopoints
into `_lat`/`_long`/`_alt`/`_acc`, strips URLs from media columns, and
fills in the `select_multiple` binary columns that the export omits when
nobody picked an option. Pass `tidy = FALSE` to get the server’s raw
export instead.

## Documentation

- [Managing
  connections](https://guturago.github.io/ctoclient/articles/managing-connections.html)
  — credentials, sessions, multiple servers
- [Working with form
  data](https://guturago.github.io/ctoclient/articles/form-data.html) —
  what tidying does, field by field
- [Documenting and reviewing a
  form](https://guturago.github.io/ctoclient/articles/form-documentation.html)
  — Stata do-files, Word review documents, printable versions
- [Attachments and
  media](https://guturago.github.io/ctoclient/articles/attachments.html)
  — form media and submission files
- [Managing server
  datasets](https://guturago.github.io/ctoclient/articles/server-datasets.html)
  — the upload modes, and how not to lose data
- [Automating a
  pipeline](https://guturago.github.io/ctoclient/articles/automation.html)
  — CI, scheduling, incremental pulls

The [function
reference](https://guturago.github.io/ctoclient/reference/index.html)
lists everything the package exports, grouped by task.

## Security

Never hard-code passwords in a script. Store them in `.Renviron`
(`usethis::edit_r_environ()`) and read them with
[`Sys.getenv()`](https://rdrr.io/r/base/Sys.getenv.html), or keep them
in your system credential store with the
[keyring](https://keyring.r-lib.org/) package. See [Managing
connections](https://guturago.github.io/ctoclient/articles/managing-connections.html)
for the details.

## Contributing

We welcome contributions! If you encounter a bug or have a feature
request, please [open an
issue](https://github.com/GutUrago/ctoclient/issues). Pull requests
should include updated tests and documentation.

## Disclaimer

This package is an independent, open-source project. It is not
affiliated with, endorsed by, or maintained by SurveyCTO or Dobility,
Inc. Use it at your own risk, and always ensure you handle survey
credentials and participant data securely.
