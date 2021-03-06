% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/googledocs.R
\name{mm_read_message_googledoc}
\alias{mm_read_message_googledoc}
\title{Parse the email template inside a markdown document on google drive.}
\usage{
mm_read_message_googledoc(id)
}
\arguments{
\item{id}{Unique Google Drive identifier, passed to \link[googledrive:drive_download]{googledrive::drive_download}}
}
\value{
A list of character strings
}
\description{
You can use this to construct the \code{message} argument of \code{\link[=mail_merge]{mail_merge()}}.
}
\seealso{
Other parsing functions: 
\code{\link{mm_read_message}()}
}
\concept{parsing functions}
