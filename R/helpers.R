# helper functions to construct and preview mail --------------------------

glue_mail <- function(delegate, message) {
  body    <- message$body
  subject <-  message$yaml$subject
  cc      <-  message$yaml$cc

  subject <- glue_data(delegate, subject)
  cc      <- glue_data(delegate, cc)
  body    <- glue_data(delegate, body)
  
  preamble <-
    glue::glue_data(
      list(
        subject = subject,
        cc = cc
      ),
      
      "---\n* subject: {subject} \n* cc: {cc}\n---\n\n"
    )
  
  list(
    body = body,
    subject = subject,
    cc = cc
  )
  
}

#' Preview message in viewer pane.
#'
#' @param to A data frame with one row, containing information about the student.
#' @param body The email message, in markdown format.
#' @param subject The email subject.
#' @param cc The email cc.
#'
#' @return HTML text
#' @export
#' @importFrom commonmark markdown_html
#' @importFrom glue glue_data
mm_preview_mail <- function(to, subject = NULL, body, cc = NULL){
  # stopifnot(nrow(delegate) == 1)
  
  preamble <-
    glue::glue_data(
      list(to = to, subject = subject, cc = cc),
      "---\n* To: {to}\n* Subject: {subject} \n* CC: {cc}\n---\n\n"
    )
  
  paste(preamble, body) %>% 
    commonmark::markdown_html()
}

#' Send draft email.
#'
#' @inheritParams mm_preview_mail
#' @param draft if `TRUE` sends a draft, otherwise sends the real email
#'
#' @return A draft email message
#' @export
mm_send_draft <- function(to, body, subject, cc = NULL, draft = TRUE){
  mm_send_mail(to = to, body = body, subject = subject, cc = cc, draft = draft)
}

#' Send email.
#' 
#' 
#' @inheritParams mm_send_draft
#' @param test If TRUE, doesn't send email but simply returns `mime` value, used for testing.
#' 
#' @return An email message
#' @export
#'
#' @importFrom gmailr gm_mime gm_to gm_subject gm_html_body gm_create_draft gm_send_message gm_cc
mm_send_mail <- function(to, body, subject, cc = NULL, draft = FALSE, 
                         test = Sys.getenv("mailmerge_test", FALSE)) {
  if (missing(subject) || is.null(subject)) stop("Provide subject line")
  # stopifnot(nrow(delegate) == 1)
  msg <- gm_mime() %>% 
    gm_to(to) %>% 
    gm_subject(subject) %>% 
    gm_cc(cc) %>% 
    gm_html_body(
      commonmark::markdown_html(body)
    )
  
  test <- (test == "TRUE") | isTRUE(test)
  if (!test) {
    if (draft) {
      msg %>% 
        gm_create_draft()
    } else {
      msg %>%
        gm_send_message()
    }
  }
  invisible(msg)
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


