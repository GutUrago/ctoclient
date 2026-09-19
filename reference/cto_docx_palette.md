# Row Colours Used by the Form Review Document

The default fill colour of each field family in the document that
[`cto_form_docx()`](https://guturago.github.io/ctoclient/reference/cto_form_docx.md)
produces. The values are Office theme tints, so the table looks native
in Word and stays legible when printed in greyscale.

## Usage

``` r
cto_docx_palette()
```

## Value

A named character vector of hex colours.

## See also

Other Form Management Functions:
[`cto_form_attachment()`](https://guturago.github.io/ctoclient/reference/cto_form_attachment.md),
[`cto_form_data()`](https://guturago.github.io/ctoclient/reference/cto_form_data.md),
[`cto_form_data_attachment()`](https://guturago.github.io/ctoclient/reference/cto_form_data_attachment.md),
[`cto_form_docx()`](https://guturago.github.io/ctoclient/reference/cto_form_docx.md),
[`cto_form_dofile()`](https://guturago.github.io/ctoclient/reference/cto_form_dofile.md),
[`cto_form_languages()`](https://guturago.github.io/ctoclient/reference/cto_form_languages.md),
[`cto_form_metadata()`](https://guturago.github.io/ctoclient/reference/cto_form_metadata.md)

## Examples

``` r
cto_docx_palette()
#>           group          repeat            note            text         numeric 
#>       "#2F5496"       "#BF8F00"       "#F2F2F2"       "#FFFFFF"       "#E2EFDA" 
#>      select_one select_multiple        datetime             geo           media 
#>       "#DDEBF7"       "#BDD7EE"       "#E4DFEC"       "#DAEEF3"       "#FCE4D6" 
#>           other 
#>       "#FFFFFF" 

# Override a single family
cto_form_docx_palette <- cto_docx_palette()
cto_form_docx_palette["numeric"] <- "#FFF2CC"
```
