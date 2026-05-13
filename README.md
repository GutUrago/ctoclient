
# ctoclient: A Modern and Flexible Data Pipeline for 'SurveyCTO'

<!-- badges: start -->
[![R-CMD-check](https://github.com/GutUrago/ctoclient/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/GutUrago/ctoclient/actions/workflows/R-CMD-check.yaml)
[![CRAN status](https://www.r-pkg.org/badges/version/ctoclient)](https://cran.r-project.org/package=ctoclient) 
[![cran checks](https://badges.cranchecks.info/worst/ctoclient.svg)](https://cran.r-project.org/web/checks/check_results_ctoclient.html)
[![Codecov test coverage](https://codecov.io/gh/GutUrago/ctoclient/graph/badge.svg)](https://app.codecov.io/gh/GutUrago/ctoclient)
[![minimal R version](https://img.shields.io/badge/R%3E%3D-4.1.0-6666ff.svg)](https://cran.r-project.org/)
[![DOI](https://zenodo.org/badge/1121002963.svg)](https://doi.org/10.5281/zenodo.18107568)
<!-- badges: end -->

**`ctoclient`** is a modern, fast, and flexible high-level R client for the 
[SurveyCTO REST API](https://developer.surveycto.com/). 
Built on top of the robust [httr2](https://httr2.r-lib.org/) framework, it provides a consistent and pipe-friendly 
interface for programmatic access to server resources.

## Why use `ctoclient`?

* **Analysis Ready:** Automatically tidies messy API responses into clean data frames.
* **Encrypted Data Support:** Seamlessly handle encrypted forms with private keys.
* **Full Resource Coverage:** Manage forms, server datasets, attachments, and metadata.
* **Modern Auth:** Robust session handling and secure credential management.
* **Extendable:** Built on `httr2` request objects, allowing for easy customization and extension of API requests.
* **Stata Integration:** Built-in tools for generating `.do` files and templates for legacy pipelines.


## Documentation (Upcoming)

- Managing connections and sessions
- Working with form data
- Managing server data




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

## 1. Setup & Authentication

To keep your credentials secure, **never hard-code passwords** in scripts. 
`ctoclient` supports two primary ways to authenticate:

**1. Interactive Prompts (Recommended for Dev)**

If you leave the password blank, `ctoclient` will securely prompt you for it in the console.

``` r
library(ctoclient)
cto_connect(server = "myorg", username = "admin@example.com")
```

**2. Environment Variables (Recommended for CI/CD)**

To use `.Renviron` file:

1. Run `usethis::edit_r_environ()` to open your environment file.
2. Add your credentials:

``` r
SERVER="myorg"
USER="myemail@example.com"
PASS="mypassword"
```
3. Restart R.

[!TIP] For even higher security, consider using the [keyring](https://keyring.r-lib.org/) 
package to store passwords in your system's secure credential store.




### 2. Working with Forms and Data

Download form definitions, data, and attachments.

``` r
# List all available forms
forms <- cto_form_ids()

# Get metadata form for specific form
cto_form_metadata('myform')

# Download data for a specific form
data <- cto_form_data("myform")

# Download encrypted data
data <- cto_form_data("myform", "mykey")

# Download encrypted data in a raw format
data <- cto_form_data("myform", "mykey", tidy = FALSE)

# Download form submission medias
cto_form_data_attachment('myform', ends_with('_img'), "mykey")

# Download the default form import do-file
cto_form_stata_template('myform')

# Build custom Stata import do-file
cto_form_dofile('myform', "form.do")

# Download attachments (e.g., photos, audio)
cto_form_attachment("myform", dir = "data/attachments", overwrite = TRUE)

```


### 3. Server Datasets

Manage server-side datasets.

```r
# List existing datasets
datasets <- cto_dataset_list()

# Create server dataset
cto_dataset_create("mydata")

# Upload a local CSV to a server dataset
cto_dataset_upload("mydata", "data/mydata.csv")

# Download a server dataset to a local file
cto_dataset_download(dir = "data/downloads", overwrite = TRUE)

# Purge server dataset
cto_dataset_purge("mydata")

# Delete server dataset
cto_dataset_delete("mydata")
```



### 4. Utilities and Metadata

Retrieve server configuration and helper files.

```r
# Get server metadata
meta <- cto_metadata()

# Generate a Stata template for a form
cto_form_languages("myform")

# Get a printable version of the form
cto_form_printable("myform")

# Get a mail-merge template of the form
cto_form_mail_template("myform")
```


## Contributing

We welcome contributions! If you encounter a bug or have a feature request, 
please [open an issue](https://github.com/GutUrago/ctoclient/issues). 
Pull requests should include updated tests and documentation.


## Disclaimer
This package is an independent, open-source project. It is not affiliated with, 
endorsed by, or maintained by SurveyCTO or Dobility, Inc. Use it at your own risk, 
and always ensure you handle survey credentials and participant data securely.
