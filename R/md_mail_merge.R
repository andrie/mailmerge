#' Send course email.
#'
#' @inheritParams mm_send_draft
#' @inheritParams mm_preview_mail
#' @inheritParams mm_send_mail
#'
#'
#' @param delegates A `tibble` with all the columns that should be glued into
#'   the message
#'
#' @param preview If `TRUE` displays message in viewer without sending mail
#'
#' @param sleep If `draft == TRUE` the number of seconds to sleep between each
#'   preview
#'
#' @param message A list with components `yaml` and `body`.  See
#'   [parse_email_from_googledoc()]
#'
#' @export
#' @importFrom purrr map pmap
mm_mail_merge <- function(delegates, message, preview = TRUE, draft = TRUE, sleep = 1) {
  if(nrow(delegates) == 0) stop("nothing to email")
  if(!preview) {
    yesno("Send ", nrow(delegates), " emails?")
  }
  
  z <- delegates %>%
    purrr::pmap(list) %>%
    purrr::map(function(x){
      msg <- x %>%
        mm_preview_mail(message$body)
      if (preview) {
        msg %>%
          in_viewer()
        Sys.sleep(sleep)
      } else {
        if (draft) {
          msg %>%
            mm_send_draft(delegate = x, subject = message$yaml$subject)
        } else {
        msg %>%
          mm_send_mail(delegate = x, subject = message$yaml$subject)
        }
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
  invisible(NULL)
}


