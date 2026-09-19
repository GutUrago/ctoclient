# Attachments and Media

Two different things get called attachments in SurveyCTO, and
`ctoclient` has a separate function for each. Picking the wrong one is
the usual reason a download comes back empty.

| You want | Use |
|----|----|
| Files **you attached to the form** — pre-load CSVs, images, audio prompts | [`cto_form_attachment()`](https://guturago.github.io/ctoclient/reference/cto_form_attachment.md) |
| Files **respondents submitted** — photos, recordings, signatures | [`cto_form_data_attachment()`](https://guturago.github.io/ctoclient/reference/cto_form_data_attachment.md) |

``` r

library(ctoclient)
cto_connect("myorg", "admin@example.com")
```

## 1. Form attachments

These are the media files deployed with the form. Called with no
`filename`, you get all of them:

``` r

cto_form_attachment("baseline_survey", dir = "form_media")
```

To see what is available before downloading, or to pick out one file:

``` r

meta <- cto_form_metadata("baseline_survey")
names(meta$deployedGroupFiles$mediaFiles)

cto_form_attachment(
  "baseline_survey",
  filename = "village_list.csv",
  dir      = "form_media"
)
```

Naming a file that does not exist gives a warning listing what was
missed; if *none* of the requested files exist you get an error instead,
which is the right way round for a script.

Existing files are skipped unless `overwrite = TRUE`. That makes
re-running cheap, but it also means a file that changed on the server
will not be refreshed until you ask.

## 2. Submission attachments

These are the photos, recordings and signatures respondents produced.

``` r

cto_form_data_attachment("baseline_survey")
```

By default the files land in `media/` under the working directory. The
function works by downloading the form’s submissions, finding the
columns that hold attachment URLs, and fetching each one.

### Choosing which fields

`fields` accepts tidyselect, evaluated against the submission columns,
so everything you know from
[`dplyr::select()`](https://dplyr.tidyverse.org/reference/select.html)
works:

``` r

# One question
cto_form_data_attachment("baseline_survey", fields = house_photo)

# Every field whose name ends in _img
cto_form_data_attachment("baseline_survey", fields = ends_with("_img"))

# Several groups at once
cto_form_data_attachment(
  "baseline_survey",
  fields = c(starts_with("photo_"), matches("signature")),
  dir    = "media/round1"
)
```

Narrowing `fields` does not reduce what is downloaded from the server in
the first place — the submissions are fetched either way — but it does
control which files are retrieved, which is where the time goes on a
form with thousands of photos.

### Encrypted forms

An encrypted form needs its key here just as it does for the data:

``` r

cto_form_data_attachment(
  "baseline_survey",
  fields      = ends_with("_img"),
  private_key = "keys/baseline.pem"
)
```

Forgetting it is the most common cause of “No submission attachments
found” — without the key the URLs are not readable, so nothing matches.
The warning says as much when no key was supplied.

## 3. Matching files back to submissions

Files are saved under the basename from the URL, which is the filename
SurveyCTO assigned. The tidied data keeps that same name, because the
tidying step strips the URL from media columns and leaves the filename
behind:

``` r

data <- cto_form_data("baseline_survey", private_key = "keys/baseline.pem")

data$house_photo[1]
#> [1] "house_photo-19_9_2026-14_05_11.jpg"

file.exists(file.path("media", data$house_photo[1]))
#> [1] TRUE
```

So the join between a row and its file is just the column value. If you
fetch with `tidy = FALSE`, that column holds the full URL instead and
you will need [`basename()`](https://rdrr.io/r/base/basename.html).

Two consequences worth planning for. Filenames are assigned per
submission, not per respondent, so organise by directory
(`dir = "media/round1"`) rather than trusting names to stay unique
across forms or rounds. And because existing files are skipped by
default, a rerun after new submissions arrive downloads only what is new
— which is exactly what you want in a scheduled job.

## 4. A monitoring pattern

Pulling new photos every night, without re-downloading the archive:

``` r

library(ctoclient)

cto_connect(
  server   = Sys.getenv("CTO_SERVER"),
  username = Sys.getenv("CTO_USER"),
  password = Sys.getenv("CTO_PASS")
)

dir.create("media", showWarnings = FALSE)

cto_form_data_attachment(
  "baseline_survey",
  fields      = ends_with("_img"),
  private_key = Sys.getenv("CTO_KEY_PATH"),
  dir         = "media"
)
```

Leave `overwrite` at its default and each run fetches only the files it
does not already have.

## See also

- [Working with form
  data](https://guturago.github.io/ctoclient/articles/form-data.md) for
  what happens to media columns during tidying.
- [Automating a
  pipeline](https://guturago.github.io/ctoclient/articles/automation.md)
  for scheduling.
