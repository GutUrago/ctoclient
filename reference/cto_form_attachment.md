# Download Attachments from a SurveyCTO Form

Downloads files attached to a deployed SurveyCTO form, such as preloaded
CSV files, media assets, or other server-side attachments.

## Usage

``` r
cto_form_attachment(form_id, filename = NULL, dir = getwd(), overwrite = FALSE)
```

## Arguments

- form_id:

  A string specifying the SurveyCTO form ID.

- filename:

  Optional character vector of specific filenames to download (e.g.,
  `"prices.csv"`). If `NULL` (default), all available attachments
  associated with the form are downloaded.

- dir:

  A string giving the directory where files will be saved. Defaults to
  [`getwd()`](https://rdrr.io/r/base/getwd.html).

- overwrite:

  Logical; if `TRUE`, existing files in `dir` will be overwritten. If
  `FALSE` (the default), existing files are skipped.

## Value

A character vector of file paths to all available attachments that exist
locally after the function completes (invisibly).

Returns `invisible(NULL)` if the form has no attachments.

## Details

This function first calls
[`cto_form_metadata()`](https://guturago.github.io/ctoclient/reference/cto_form_metadata.md)
to retrieve metadata for the deployed form, including the list of
available attachments.

- **File types**: Any attached file type can be downloaded (for example,
  images, audio, or CSV files).

- **Progress reporting**: When `options(scto.verbose = TRUE)` (default),
  progress messages are printed using the CLI framework.

- **Caching**: Files are not re-downloaded if they already exist in
  `dir` unless `overwrite = TRUE`.

If all requested files are not available, the function aborts with an
informative message suggesting how to inspect the form metadata.

## See also

Other Form Management Functions:
[`cto_form_data()`](https://guturago.github.io/ctoclient/reference/cto_form_data.md),
[`cto_form_data_attachment()`](https://guturago.github.io/ctoclient/reference/cto_form_data_attachment.md),
[`cto_form_dofile()`](https://guturago.github.io/ctoclient/reference/cto_form_dofile.md),
[`cto_form_languages()`](https://guturago.github.io/ctoclient/reference/cto_form_languages.md),
[`cto_form_metadata()`](https://guturago.github.io/ctoclient/reference/cto_form_metadata.md)

## Examples

``` r
if (FALSE) { # \dontrun{
files <- cto_form_attachment("household_survey")

# 2. Download specific files to a local directory
cto_form_attachment(
  form_id  = "household_survey",
  filename = c("item_list.csv", "logo.png"),
  dir      = "data/raw"
)

# 3. Force re-download of a file
p <- cto_form_attachment(
  form_id  = "household_survey",
  filename = "prices.csv",
  overwrite = TRUE
)

prices <- read.csv(p)
} # }
```
