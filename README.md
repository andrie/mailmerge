
<!-- README.md is generated from README.Rmd. Please edit that file -->

# mailmerge <img src='man/figures/logo.png' align="right" height="139" />

<!-- badges: start -->

<!-- badges: end -->

Mail merge from R using markdown documents and gmail.

  - Parsing markdown documents as the body of email
  - Using the `yaml` header to specify the subject line of the email
  - Using `glue` to replace `{}` tags
  - Preview the email in the RStudio viewer pane
  - Sending (draft) email using `gmailr`

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
dat = read.csv(text = '
first_name,  thing
friend, something good
foe, something bad
')
```

Write the text of your email as a R markdown document. You can add the
subject line in the yaml header. Use `{}` braces inside the email to
refer to the data inside your data frame. Expressions inside these
braces will be encoded by the `glue::glue()` function (See
<https://glue.tidyverse.org/>).

``` md
---
subject: Your subject line
---
Hi, {first_name}

I am writing to tell you about {thing}.

HTH

Me
```

Then you can use `mail_merge()` to embed the content of your data frame
into the email message.

``` r
library(mailmerge)
library(gmailr)


# configure auth ----------------------------------------------------------

gm_auth(email = "me@example.com")


txt = readLines("path/to/message.Rmd")
msg = mm_parse_email(txt)

dat %>% 
  mail_merge(msg)
```
