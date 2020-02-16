#' Send course email.
#'
#' @inheritParams mm_send_draft
#' @inheritParams mm_preview_mail
#' @inheritParams mm_send_mail
#'
#'
#' @param data A `tibble` with all the columns that should be glued into
#'   the message
#'
#' @param preview If `TRUE` displays message in viewer without sending mail
#'
#' @param sleep_preview If `draft == TRUE` the number of seconds to sleep between each
#'   preview
#'   
#' @param sleep_send If `draft == FALSE` the number of seconds to sleep between
#'   each email send (to prevent gmail API 500 errors)
#'
#' @param message A list with components `yaml` and `body`.  See
#'   [mm_parse_email_from_googledoc()]
#'
#' @export
#' @importFrom purrr map pmap
mail_merge <- function(data, message, preview = TRUE, draft = TRUE, 
                       sleep_preview = 1, sleep_send = 0.1) {
  if(nrow(data) == 0) {
    warning("nothing to email")
    return(invisible(data))
  }
  if(is.null(data[["email"]])) stop("data must contain an email column")
  if(!preview) {
    yesno("Send ", nrow(data), " emails?")
  }
  
  z <-data%>%
    purrr::pmap(list) %>%
    purrr::map(function(delegate) {
      
      to         <- delegate[["email"]]
      glued_data <- glue_mail(delegate, message)
      body       <- glued_data$body
      subject    <- glued_data$subject
      cc         <- glued_data$cc
      
      
      if (preview) {
        msg <- 
          mm_preview_mail(to = to, body = body, subject = subject, cc = cc)
        in_viewer(msg)
        Sys.sleep(sleep_preview)
      } else {
        if (draft) {
          mm_send_draft(to = to, body = body, subject = subject, cc = cc, draft = TRUE)
        } else {
          mm_send_mail(to = to, body = body, subject = subject, cc = cc, draft = FALSE)
        }
        Sys.sleep(sleep_send)
      }
    })
  
  n_messages <- length(z)
  
  if (preview) {
    base::message("Sent preview to viewer")
  } else {
    if (draft) {
      base::message("Sent ", n_messages, " messages to your draft folder")
    } else {
    base::message("Sent ", n_messages, " messages to email")
    }
  }
  invisible(data)
}


