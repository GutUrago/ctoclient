# Managing Connections

Efficiently managing connections is the foundation of a robust data
pipeline. `ctoclient` is designed to handle both simple single-server
scripts and complex multi-server environments common in large-scale
research projects.

## 1. Authentication Strategies

**Security First**

Never store passwords directly in your R scripts. If you share your code
or push it to GitHub, your credentials will be exposed.

**The .Renviron Approach**

``` r

library(ctoclient)
```

The most common way to manage credentials is via the .Renviron file.

- Call usethis::edit_r_environ().
- Add your credentials:

``` r

CTO_SERVER="myorg"
CTO_USER="admin@example.com"
CTO_PASS="mypassword123"
```

- Restart R for changes to take effect.

- Connect using:

``` r

cto_connect(
  server   = Sys.getenv("CTO_SERVER"),
  user     = Sys.getenv("CTO_USER"),
  password = Sys.getenv("CTO_PASS")
)
```

**Interactive Mode**

If you are working locally and haven’t set up environment variables,
omit the password:

``` r

cto_connect(server = "myorg", user = "admin@example.com")
# R will prompt you for the password securely.
```

## 2. Working with Multiple Servers

In some projects, you may need to move data between different servers,
or aggregate data from multiple organizations.

**The Session System**

[`cto_connect()`](https://guturago.github.io/ctoclient/reference/cto_connect.md)
creates a global session by default. To work with multiple servers, you
can capture the connection objects and set them explicitly as
connections.

``` r

# Connect to Server A 
conn_a <- cto_connect(
  server = "org-staging", 
  user = "admin@email.com", 
  password = "password1"
)

# Connect to Server B
conn_b <- cto_connect(
  server = "org-prod", 
  user = "admin@email.com", 
  password = "password2"
)

# Fetch data from server B
data_staging <- cto_form_data("baseline_survey")

# Switch the connection to A 
cto_set_connection(conn_a)

# Upload that same data to a dataset on Server A
cto_dataset_upload("aggregated_data", data = data_staging,)
```

## 3. Advanced Customization (httr2)

Because ctoclient is built on `httr2`, every connection object contains
an `httr2_request`. If you need to add custom headers or change the
timeout for a specific high-latency request, you can modify the
connection object before passing it to a function.

``` r

# Example: Adding a custom user-agent or changing retry logic
custom_conn <- conn_a |> 
  httr2::req_user_agent("MyCustomResearchBot/1.0") |>
  httr2::req_retry(max_tries = 5)
  
# Use the customized connection
cto_set_connection(custom_conn)
cto_form_data("my_form")
```
