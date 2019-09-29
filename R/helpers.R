# helper functions to construct and preview mail --------------------------

#' Preview message in viewer pane.
#'
#' @param delegate A data frame with one row, containing information about the student.
#' @param body The email message, in markdown format.
#'
#' @return HTML text
#' @export
#' @importFrom commonmark markdown_html
#' @importFrom glue glue_data
mm_preview_mail <- function(delegate, body){
  stopifnot(nrow(delegate) == 1)
  delegate %>% 
    glue_data(body) %>% 
    commonmark::markdown_html()
}

#' Send draft email.
#'
#' @inheritParams mm_preview_mail
#' @param subject Subject line
#' @param draft if `TRUE` sends a draft, otherwise sends the real email
#'
#' @return A draft email message
#' @export
mm_send_draft <- function(delegate, body, subject, draft = TRUE){
  mm_send_mail(delegate = delegate, body = body, subject = subject, draft = draft)
}

#' Send email.
#' 
#' 
#' @inheritParams mm_send_draft
#' 
#' @return An email message
#' @export
#'
#' @importFrom gmailr gm_mime gm_to gm_subject gm_html_body gm_create_draft gm_send_message
mm_send_mail <- function(delegate, body, subject, draft = FALSE){
  if (missing(subject) || is.null(subject)) stop("Provide subject line")
  stopifnot(nrow(delegate) == 1)
  msg <- gm_mime() %>% 
    gm_to(delegate$email) %>% 
    gm_subject(subject) %>% 
    gm_html_body(body)
  
  if (draft) {
    msg %>% 
      gm_create_draft()
  } else {
    msg %>%
      gm_send_message()
  }
}


#' Display email message in RStudio viewer pane
#'
#' @param x message
#'
#' @return opens the viewer pane and displays message
#' @export
#' 
#' @importFrom rstudioapi viewer
#'
in_viewer <- function(x){
  pre <- "
    <!DOCTYPE html>
    <html>
    <head>
    <title>This is a title</title>
    </head>
    <body>
    "
  post <- "
    </body>
    </html>
    "
  html <- tempfile(fileext = ".html")
  z <- paste(pre, x, post, sep = "\n")
  writeLines(z, con = html)
  rstudioapi::viewer(html)
}


