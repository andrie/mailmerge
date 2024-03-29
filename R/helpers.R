# helper functions to construct and preview mail --------------------------

collapse <- function(...) paste(..., collapse = "\n")

is_rstudio <- function() Sys.getenv("RSTUDIO") == "1" # nocov

nulls_to_empty <- function(x) {if (is.null(x) || length(x) == 0) x <- ""; return(x) }

clean_na <- function(x) {
  if (x == "NA") "" else x
}

glue_mail <- function(data, message) {
  body    <- message$body %>% nulls_to_empty()
  subject <- message$yaml$subject %>% nulls_to_empty()
  cc      <- message$yaml$cc %>% nulls_to_empty() 
  
  subject <- glue_data(data, subject) %>% nulls_to_empty()
  cc      <- glue_data(data, cc) %>% nulls_to_empty() %>% clean_na()
  body    <- glue_data(data, body) %>% nulls_to_empty()
  
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
#' @importFrom commonmark markdown_html
#' @importFrom glue glue_data
#' @return HTML text
#' @keywords internal
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
#' @keywords internal
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
#' @keywords internal
mm_send_mail <- function(to, body, subject, cc = NULL, draft = FALSE, 
                         test = Sys.getenv("mailmerge_test", FALSE)) {
  if (missing(subject) || is.null(subject)) stop("Provide subject line")
  # stopifnot(nrow(delegate) == 1)
  msg <- gm_mime() %>% 
    gm_to(to) %>% 
    gm_subject(subject) %>% 
    gm_html_body(
      commonmark::markdown_html(body)
    )
  
  if (isFALSE(is.na(cc)) && cc != "NA") {
    msg <- msg %>% gm_cc(cc)
  }
  
  test <- (test == "TRUE") | isTRUE(test)
  if(test) {
    return(
      list(
        msg = msg,
        id = NA,
        type = "test",
        success = NA
      )
    )
  }
  z <- tryCatch({
    if (draft) {
      gmailr::gm_create_draft(msg)
    } else {
      gmailr::gm_send_message(msg)
    }
  }, error = function(e) e
  )
  
  if (inherits(z, "error")) {
    warning("From gmailr: ", z$message, call. = FALSE)
    list(
      msg = msg,
      id = NA,
      type = NA,
      success = FALSE
    )
    
  } else {
    list(
      msg = msg,
      id = z$id,
      type = z$labelIds[[1]],
      success = TRUE
    )
    
  }
}

as_html <- function(x, standalone = TRUE) { # nocov start
  if(standalone) {
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

  paste(pre, x, post, sep = "\n")
  } else {
    x
  }
    
} # nocov end


#' Display email message in RStudio viewer pane.
#' 
#' Only opens the viewer pane if interactive and RStudio is the IDE, otherwise returns the input invisibly.
#'
#' @param x message
#'
#' @export
#' @return An [rstudioapi::viewer] object. Called for the side effect of opening the viewer pane and displays message
#' 
#' @importFrom rstudioapi viewer
#' @keywords internal
#'
in_viewer <- function(x){ # nocov start
  
  if (interactive() && is_rstudio()) {
    z <- as_html(x, standalone = TRUE)
    html <- tempfile(fileext = ".html")
    writeLines(z, con = html)
    rstudioapi::viewer(html)
  } else {
    invisible(x)
  }
} #nocov end


