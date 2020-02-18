# helper functions to construct and preview mail --------------------------

collapse <- function(...) paste(..., collapse = "\n")

is_rstudio <- function() Sys.getenv("RSTUDIO") == "1"

glue_mail <- function(data, message) {
  body    <- message$body
  subject <-  message$yaml$subject
  cc      <-  message$yaml$cc

  subject <- glue_data(data, subject)
  cc      <- glue_data(data, cc)
  body    <- glue_data(data, body)
  
  list(
    body = body,
    subject = subject,
    cc = cc
  )
  
}

#' Preview message in viewer pane.
#'
#' @param to The email `to` address
#' @param body The email message, in markdown format
#' @param subject The email subject
#' @param cc The email `cc` address
#'
#' @return HTML text
#' @importFrom commonmark markdown_html
#' @importFrom glue glue_data
mm_preview_mail <- function(to, subject = "", body, cc = ""){
  # stopifnot(nrow(delegate) == 1)
  
  if (length(cc) == 0) cc <- ""

   
  yaml_header <- collapse(
    "---\n",
    glue::glue(
      " To: {to}  \n Subject: {subject}  \n CC: {cc}\n\n"
    ),
    "\n---\n\n"
  )
  
  collapse(
    yaml_header, 
    body
  ) %>% 
    commonmark::markdown_html()
}

#' Send draft email.
#'
#' @inheritParams mm_preview_mail
#' @param draft if `TRUE` sends a draft, otherwise sends the real email
#'
#' @return A draft email message
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


