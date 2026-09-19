# Generate a Printable Word Document of a Deployed SurveyCTO Form

Downloads the XLSForm definition of a form and renders the fields an
enumerator actually sees as a formatted Word table, for review and
sign-off. Calculates, metadata fields and disabled rows are left out,
groups and repeat groups become banded section headers, and every row is
shaded according to its field type.

## Usage

``` r
cto_form_docx(
  form_id,
  path = NULL,
  version = NULL,
  language = NULL,
  show_metadata = FALSE,
  palette = NULL
)
```

## Arguments

- form_id:

  A character string specifying the SurveyCTO form ID.

- path:

  Optional character string giving the output file path. Must end in
  `.docx`. If `NULL` (default), the file is written to
  [`tempdir()`](https://rdrr.io/r/base/tempfile.html) under the form ID.

- version:

  Optional string specifying a particular form version, passed to
  [`cto_form_definition()`](https://guturago.github.io/ctoclient/reference/cto_form_metadata.md).
  If `NULL` (default), the currently deployed version is used.

- language:

  Optional string naming the label language to render, for example
  `"English (en)"`. If `NULL` (default), the form's `default_language`
  is used, falling back to the first label column.

- show_metadata:

  Logical. If `TRUE`, `calculate` and metadata fields such as `start`,
  `end`, `deviceid` and the audit fields are included. Defaults to
  `FALSE`, which is what makes the output a collector's-eye view of the
  form.

- palette:

  Optional named character vector of hex colours overriding the defaults
  returned by
  [`cto_docx_palette()`](https://guturago.github.io/ctoclient/reference/cto_docx_palette.md).
  Names that are not supplied keep their default colour.

## Value

A data frame of the rendered fields, returned invisibly. The document is
written to `path` for its side effect.

## Details

[`cto_form_printable()`](https://guturago.github.io/ctoclient/reference/cto_form_languages.md)
asks the SurveyCTO server for its own printable rendering of a form.
`cto_form_docx()` is different: it builds the document locally from the
XLSForm definition, so it can show the variable names, relevance and
constraint expressions that a reviewer needs and the server-side
printable does not carry.

Fields are shaded by family rather than by raw type, so that
`select_one yes_no` and `select_one gender` share a colour. The families
are `note`, `text`, `numeric`, `select_one`, `select_multiple`,
`datetime`, `geo`, `media` and `other`, with separate band colours for
groups and repeat groups.

Nesting depth is counted before any row is dropped, so a question still
shows the indentation of the groups it sits inside even when one of
those wrappers is filtered out. A group's own relevance travels with its
band, since a condition that governs the whole section would otherwise
be lost.

## See also

[`cto_form_printable()`](https://guturago.github.io/ctoclient/reference/cto_form_languages.md)
for the server's own printable version.

Other Form Management Functions:
[`cto_docx_palette()`](https://guturago.github.io/ctoclient/reference/cto_docx_palette.md),
[`cto_form_attachment()`](https://guturago.github.io/ctoclient/reference/cto_form_attachment.md),
[`cto_form_data()`](https://guturago.github.io/ctoclient/reference/cto_form_data.md),
[`cto_form_data_attachment()`](https://guturago.github.io/ctoclient/reference/cto_form_data_attachment.md),
[`cto_form_dofile()`](https://guturago.github.io/ctoclient/reference/cto_form_dofile.md),
[`cto_form_languages()`](https://guturago.github.io/ctoclient/reference/cto_form_languages.md),
[`cto_form_metadata()`](https://guturago.github.io/ctoclient/reference/cto_form_metadata.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Review document for the deployed version
cto_form_docx("household_survey", path = "household_survey_review.docx")

# A specific version, in a named language
cto_form_docx(
  "household_survey",
  path = "review_v2.docx",
  version = "20231001",
  language = "Amharic (am)"
)

# Include the calculates and metadata fields as well
cto_form_docx("household_survey", path = "full.docx", show_metadata = TRUE)
} # }
```
