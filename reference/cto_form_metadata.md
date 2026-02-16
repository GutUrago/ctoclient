# Download SurveyCTO Form Metadata and Definitions

Functions for interacting with SurveyCTO form definitions.

- `cto_form_metadata()` retrieves raw metadata for a form, including
  available definition files, version identifiers, and download URLs.

- `cto_form_definition()` downloads a specific XLSForm definition (Excel
  file) to a local directory.

## Usage

``` r
cto_form_metadata(form_id)

cto_form_definition(form_id, version = NULL, dir = getwd(), overwrite = FALSE)
```

## Arguments

- form_id:

  A string giving the unique SurveyCTO form ID.

- version:

  Optional string specifying a particular form version to download. If
  `NULL` (default), the currently deployed version is used.

- dir:

  Directory where the XLSForm should be saved. Defaults to
  [`getwd()`](https://rdrr.io/r/base/getwd.html).

- overwrite:

  Logical; if `TRUE`, an existing file in `dir` will be overwritten. If
  `FALSE` (default), the existing file is used.

## Value

- `cto_form_metadata()` returns a list containing the metadata,
  including keys for `deployedGroupFiles` and `previousDefinitionFiles`.

- `cto_form_definition()` returns a character string with the path to
  the downloaded Excel file.

## Details

- **Version Handling:** When `version` is supplied, it is validated
  against the available versions from `cto_form_metadata()`. An
  informative error is raised if the requested version does not exist.

- **Caching:** If the file already exists in `dir`, it will not be
  re-downloaded unless `overwrite = TRUE`.

## See also

Other Form Management Functions:
[`cto_form_attachment()`](https://guturago.github.io/ctoclient/reference/cto_form_attachment.md),
[`cto_form_data()`](https://guturago.github.io/ctoclient/reference/cto_form_data.md),
[`cto_form_data_attachment()`](https://guturago.github.io/ctoclient/reference/cto_form_data_attachment.md),
[`cto_form_dofile()`](https://guturago.github.io/ctoclient/reference/cto_form_dofile.md),
[`cto_form_languages()`](https://guturago.github.io/ctoclient/reference/cto_form_languages.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# --- 1. Get raw metadata ---
meta <- cto_form_metadata("household_survey")

# --- 2. Download the current form definition ---
file_path <- cto_form_definition("household_survey")

# --- 3. Download a specific historical version ---
file_path_v <- cto_form_definition(
  "household_survey",
  version = "20231001"
)

# --- 4. Read XLSForm manually with readxl ---
library(readxl)
survey <- read_excel(file_path, sheet = "survey")
choices <- read_excel(file_path, sheet = "choices")
settings <- read_excel(file_path, sheet = "settings")
} # }
```
