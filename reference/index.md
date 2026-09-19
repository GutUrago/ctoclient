# Package index

## Connecting to a server

Authenticate against a SurveyCTO server and manage the session that
every other function in the package uses.

- [`cto_connect()`](https://guturago.github.io/ctoclient/reference/cto_connect.md)
  [`cto_set_connection()`](https://guturago.github.io/ctoclient/reference/cto_connect.md)
  [`cto_is_connected()`](https://guturago.github.io/ctoclient/reference/cto_connect.md)
  : Connect to and manage a SurveyCTO Server connection

## Forms and submission data

Download submissions and the form definitions that describe them.

- [`cto_form_data()`](https://guturago.github.io/ctoclient/reference/cto_form_data.md)
  : Download and Tidy SurveyCTO Form Data
- [`cto_form_metadata()`](https://guturago.github.io/ctoclient/reference/cto_form_metadata.md)
  [`cto_form_definition()`](https://guturago.github.io/ctoclient/reference/cto_form_metadata.md)
  : Download SurveyCTO Form Metadata and Definitions
- [`cto_form_attachment()`](https://guturago.github.io/ctoclient/reference/cto_form_attachment.md)
  : Download Attachments from a SurveyCTO Form
- [`cto_form_data_attachment()`](https://guturago.github.io/ctoclient/reference/cto_form_data_attachment.md)
  : Download Attachments from SurveyCTO Form Data

## Documenting a form

Turn a form definition into something a human or another package can
read: a Stata do-file, a Word review document, or one of the server’s
own generated files.

- [`cto_form_dofile()`](https://guturago.github.io/ctoclient/reference/cto_form_dofile.md)
  : Generate a Stata Do-File with Variable and Value Labels from a
  SurveyCTO Form
- [`cto_form_docx()`](https://guturago.github.io/ctoclient/reference/cto_form_docx.md)
  : Generate a Printable Word Document of a Deployed SurveyCTO Form
- [`cto_docx_palette()`](https://guturago.github.io/ctoclient/reference/cto_docx_palette.md)
  : Row Colours Used by the Form Review Document
- [`cto_form_languages()`](https://guturago.github.io/ctoclient/reference/cto_form_languages.md)
  [`cto_form_stata_template()`](https://guturago.github.io/ctoclient/reference/cto_form_languages.md)
  [`cto_form_printable()`](https://guturago.github.io/ctoclient/reference/cto_form_languages.md)
  [`cto_form_mail_template()`](https://guturago.github.io/ctoclient/reference/cto_form_languages.md)
  : Download SurveyCTO Form Files and Templates

## Server datasets

Create, populate, download and remove the server-side datasets that
forms pre-load and pull choices from.

- [`cto_dataset_list()`](https://guturago.github.io/ctoclient/reference/cto_dataset_list.md)
  : List Available Server Datasets
- [`cto_dataset_info()`](https://guturago.github.io/ctoclient/reference/cto_dataset_info.md)
  : Get Dataset Properties
- [`cto_dataset_create()`](https://guturago.github.io/ctoclient/reference/cto_dataset_create.md)
  [`cto_dataset_upload()`](https://guturago.github.io/ctoclient/reference/cto_dataset_create.md)
  : Create or Upload to Server Datasets
- [`cto_dataset_download()`](https://guturago.github.io/ctoclient/reference/cto_dataset_download.md)
  : Download SurveyCTO Server Datasets
- [`cto_dataset_delete()`](https://guturago.github.io/ctoclient/reference/cto_dataset_delete.md)
  [`cto_dataset_purge()`](https://guturago.github.io/ctoclient/reference/cto_dataset_delete.md)
  : Delete or Purge a Dataset

## Server metadata and administration

Inspect what a server holds and who can reach it.
[`cto_form_ids()`](https://guturago.github.io/ctoclient/reference/cto_metadata.md)
lives here because it shares a help page with the other listing
functions.

- [`cto_form_ids()`](https://guturago.github.io/ctoclient/reference/cto_metadata.md)
  [`cto_metadata()`](https://guturago.github.io/ctoclient/reference/cto_metadata.md)
  [`cto_group_list()`](https://guturago.github.io/ctoclient/reference/cto_metadata.md)
  [`cto_team_list()`](https://guturago.github.io/ctoclient/reference/cto_metadata.md)
  [`cto_role_list()`](https://guturago.github.io/ctoclient/reference/cto_metadata.md)
  [`cto_user_list()`](https://guturago.github.io/ctoclient/reference/cto_metadata.md)
  : Retrieve Server Metadata and Resource Lists
