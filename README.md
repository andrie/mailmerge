
<!-- README.md is generated from README.Rmd. Please edit that file -->

# mailmerge <img src='man/figures/logo.png' align="right" height="139" />

<!-- badges: start -->

[![R build
status](https://github.com/andrie/mailmerge/workflows/R-CMD-check/badge.svg)](https://github.com/andrie/mailmerge/actions)
[![Travis build
status](https://travis-ci.org/andrie/mailmerge.svg?branch=master)](https://travis-ci.org/andrie/mailmerge)
[![Codecov test
coverage](https://codecov.io/gh/andrie/mailmerge/branch/master/graph/badge.svg)](https://codecov.io/gh/andrie/mailmerge?branch=master)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
<!-- badges: end -->

Mail merge from R using markdown documents and gmail.

  - Parse markdown documents as the body of email
  - Using the `yaml` header to specify the subject line of the email
  - Using `glue` to replace `{}` tags
  - Preview the email in the RStudio viewer pane
  - Sending email (or saving as draft) using `gmailr`

Note: Right now, the only supported email backend is `gmailr` (see
<https://gmailr.r-lib.org/>).

## Installation

This package is only available from <http://github.com/andrie/mailmerge>

``` r
remotes::install_github("andrie/mailmerge")
```

## Example

Construct a data frame with the content you want to merge into your
email:

``` r
dat <-  data.frame(
  email      = c("friend@example.com", "foe@example.com"),
  first_name = c("friend", "foe"),
  thing      = c("something good", "something bad"),
  stringsAsFactors = FALSE
)
```

Write the text of your email as a R markdown document. You can add the
subject line in the yaml header. Use `{}` braces inside the email to
refer to the data inside your data frame. Expressions inside these
braces will be encoded by the `glue::glue_data()` function (See
<https://glue.tidyverse.org/>).

``` r
msg <- '
---
subject: "**Hello, {first_name}**"
---

Hi, **{first_name}**

I am writing to tell you about **{thing}**.

{if (first_name == "friend") "Regards" else ""}


Me
'
```

Then you can use `mail_merge()` to embed the content of your data frame
into the email message. By default the email will be shown in a preview
window (in the RStudio viewer pane, if you use RStudio).

To send the message, you must set `preview = FALSE` in addition to
`draft = TRUE` (to save email to your draft folder) or `draft = FALSE`
(to send immediately).

``` r

library(mailmerge)
library(gmailr)
#> 
#> Attaching package: 'gmailr'
#> The following object is masked from 'package:utils':
#> 
#>     history
#> The following objects are masked from 'package:base':
#> 
#>     body, date, labels, message
```

``` r
dat %>% 
  mail_merge(msg)
#> Sent preview to viewer
```

<center>

<img src="man/figures/mail-merge.gif" ></img>

</center>
