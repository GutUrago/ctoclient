# Download SurveyCTO Form Files and Templates

These functions retrieve auxiliary files and templates associated with a
deployed SurveyCTO form. All these functions require a stateful session
to work.

- `cto_form_languages()` retrieves the list of languages defined in the
  form.

- `cto_form_stata_template()` downloads a Stata `.do` file template for
  importing submitted data.

- `cto_form_printable()` downloads a printable (HTML) version of the
  form definition.

- `cto_form_mail_template()` downloads a mail merge template for the
  form.

All downloads are saved locally and their file paths are returned
invisibly.

## Usage

``` r
cto_form_languages(form_id)

cto_form_stata_template(
  form_id,
  dir = getwd(),
  lang = NULL,
  csv_dir = NULL,
  dta_dir = NULL
)

cto_form_printable(
  form_id,
  dir = getwd(),
  lang = NULL,
  relevancies = FALSE,
  constraints = FALSE
)

cto_form_mail_template(form_id, dir = getwd(), type = 2, group_names = FALSE)
```

## Arguments

- form_id:

  A character string giving the unique SurveyCTO form ID.

- dir:

  A character string specifying the directory where downloaded files
  will be saved. Defaults to the current working directory.

- lang:

  Optional character string giving the language identifier (for example,
  `"English"`). If `NULL`, the form's default language is used.

- csv_dir:

  Optional character string giving the directory where the CSV dataset
  will eventually be stored. This value is embedded in the generated
  Stata `.do` file to automate data loading.

- dta_dir:

  Optional character string giving the directory where the Stata `.dta`
  file should be written by the template.

- relevancies:

  Logical; if `TRUE`, relevance logic (skip patterns) is included in the
  printable form. Defaults to `FALSE`.

- constraints:

  Logical; if `TRUE`, constraint logic is included in the printable
  form. Defaults to `FALSE`.

- type:

  Integer (0–2) specifying the format of the mail merge template:

  - `0`: Field names only.

  - `1`: Field labels only.

  - `2`: Both field names and labels.

- group_names:

  Logical; if `TRUE`, group names are included in variable headers.
  Defaults to `FALSE`.

## Value

- **`cto_form_languages()`** returns a list containing the available
  languages and the index of the default language (1-based).

- All other functions return the local file path of the downloaded file,
  invisibly.

## See also

Other Form Management Functions:
[`cto_form_attachment()`](https://guturago.github.io/ctoclient/reference/cto_form_attachment.md),
[`cto_form_data()`](https://guturago.github.io/ctoclient/reference/cto_form_data.md),
[`cto_form_data_attachment()`](https://guturago.github.io/ctoclient/reference/cto_form_data_attachment.md),
[`cto_form_dofile()`](https://guturago.github.io/ctoclient/reference/cto_form_dofile.md),
[`cto_form_metadata()`](https://guturago.github.io/ctoclient/reference/cto_form_metadata.md)

## Examples

``` r
if (FALSE) { # \dontrun{
form <- "household_survey"

# 1. List available form languages
langs <- cto_form_languages(form)
print(langs)

# 2. Download a Stata import template
# Provide future CSV/DTA locations so the .do file is ready to run
cto_form_stata_template(
  form_id = form,
  dir     = "downloads/",
  csv_dir = "C:/Data",
  dta_dir = "C:/Data"
)

# 3. Download a printable form with logic displayed
cto_form_printable(
  form_id      = form,
  dir          = "documentation/",
  relevancies  = TRUE,
  constraints  = TRUE
)

# 4. Download a mail-merge template
cto_form_mail_template(
  form_id = form,
  dir     = "templates/",
  type    = 2
)
} # }
```
