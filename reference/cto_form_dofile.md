# Generate a Stata Do-File with Variable and Value Labels from a SurveyCTO Form

Creates a Stata `.do` file that applies variable labels, value labels,
and notes to a dataset based on the XLSForm definition of a SurveyCTO
form. The function supports multi-language forms, repeat groups, and
`select_multiple` questions, and generates Stata-compatible regular
expressions so labels are applied to all indexed variables.

## Usage

``` r
cto_form_dofile(form_id, path = NULL)
```

## Arguments

- form_id:

  A character string specifying the SurveyCTO form ID.

- path:

  Optional character string giving the output file path for the
  generated `.do` file. Must end in `.do`. If `NULL`, the file is not
  written to disk and the generated commands are returned invisibly.

## Value

A character vector containing the lines of the generated Stata `.do`
file. The value is returned invisibly.

## Details

The function performs several processing steps:

- **Language selection:** Automatically chooses the default language
  defined in the XLSForm, or falls back to English when multiple label
  columns are present.

- **Value labels:** Generates Stata `label define` commands for all
  `select_one` choice lists and a binary label set for `select_multiple`
  variables.

- **Repeat handling:** For variables inside repeat groups, Stata loops
  and regex matching are created so labels apply to all indexed copies
  (for example, `child_age_1`, `child_age_2`).

- **Select-multiple expansion:** Produces conditional labeling logic for
  binary indicator variables derived from `select_multiple` questions.

- **Label cleaning:** Removes HTML markup, escapes Stata-special
  characters, normalizes whitespace, and preserves SurveyCTO
  interpolation strings such as `${var}`.

## See also

Other Form Management Functions:
[`cto_form_attachment()`](https://guturago.github.io/ctoclient/reference/cto_form_attachment.md),
[`cto_form_data()`](https://guturago.github.io/ctoclient/reference/cto_form_data.md),
[`cto_form_data_attachment()`](https://guturago.github.io/ctoclient/reference/cto_form_data_attachment.md),
[`cto_form_languages()`](https://guturago.github.io/ctoclient/reference/cto_form_languages.md),
[`cto_form_metadata()`](https://guturago.github.io/ctoclient/reference/cto_form_metadata.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Generate a Stata do-file and write it to disk
cto_form_dofile("household_survey", path = "labels.do")

# Generate without writing to a file
cmds <- cto_form_dofile("household_survey")
} # }
```
