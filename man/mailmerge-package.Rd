% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/mailmerge-package.R
\docType{package}
\name{mailmerge-package}
\alias{mailmerge-package}
\alias{_PACKAGE}
\alias{mailmerge}
\title{mailmerge: Mail Merge Using R Markdown Documents and 'gmailr'}
\description{
\if{html}{\figure{logo.png}{options: align='right' alt='logo' width='120'}}

Mail merge using markdown documents and gmail. With
    this package you can parse markdown documents as the body of email,
    and the 'yaml' header to specify the subject line of the email.  Any
    '{}' braces in the email will be encoded with 'glue::glue()'. You can
    preview the email in the RStudio viewer pane, and send (draft) email
    using 'gmailr'.
}
\details{
The main function in this package is \code{\link[=mail_merge]{mail_merge()}}
}
\seealso{
Useful links:
\itemize{
  \item \url{https://andrie.github.io/mailmerge/}
  \item \url{https://github.com/andrie/mailmerge}
  \item Report bugs at \url{https://github.com/andrie/mailmerge/issues}
}

}
\author{
\strong{Maintainer}: Andrie de Vries \email{apdevries@gmail.com}

}
\keyword{internal}
