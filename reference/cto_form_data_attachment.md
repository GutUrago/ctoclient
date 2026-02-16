# Download Attachments from SurveyCTO Form Data

Extracts attachment URLs (images, audio, video, signatures) from
SurveyCTO form data and downloads the files to a local directory. This
function handles encrypted forms if a private key is provided.

## Usage

``` r
cto_form_data_attachment(
  form_id,
  fields = everything(),
  private_key = NULL,
  dir = file.path(getwd(), "media"),
  overwrite = FALSE
)
```

## Arguments

- form_id:

  A string specifying the SurveyCTO form ID to inspect.

- fields:

  A `tidy-select` expression (e.g., `everything()`,
  `starts_with("img_")`) specifying which columns should be scanned for
  attachment URLs. Defaults to `everything()`.

- private_key:

  Optional. A character string specifying the path to a local RSA
  private key file. Required if the form is encrypted.

- dir:

  A character string specifying the local directory where files should
  be saved. Defaults to `"media"`. The directory must exist.

- overwrite:

  Logical. If `TRUE`, existing files with the same name in `dir` will be
  overwritten. If `FALSE` (the default), existing files are skipped.

## Value

Returns a vector of file paths (invisibly). The function is called for
its side effect of downloading files to the local disk.

## Details

This function performs the following steps:

1.  Fetches the form data using `cto_form_data`.

2.  Scans the selected `fields` for values matching the standard
    SurveyCTO API attachment URL pattern.

3.  Downloads the identified files sequentially to the specified `dir`.

## See also

Other Form Management Functions:
[`cto_form_attachment()`](https://guturago.github.io/ctoclient/reference/cto_form_attachment.md),
[`cto_form_data()`](https://guturago.github.io/ctoclient/reference/cto_form_data.md),
[`cto_form_dofile()`](https://guturago.github.io/ctoclient/reference/cto_form_dofile.md),
[`cto_form_languages()`](https://guturago.github.io/ctoclient/reference/cto_form_languages.md),
[`cto_form_metadata()`](https://guturago.github.io/ctoclient/reference/cto_form_metadata.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# 1. Download all attachments from the form submissions
cto_form_data_attachment(
  form_id = "household_survey_v1",
  dir = "downloads/medias"
)

# 2. Download only specific image fields from an encrypted form
cto_form_data_attachment(
  form_id = "encrypted_health_survey",
  fields = starts_with("image_"),
  private_key = "keys/my_priv_key.pem",
  overwrite = TRUE
)
} # }
```
