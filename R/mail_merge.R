#' Merges data into an email and send.
#'
#' Merges columns from a data frame into a markdown document using the
#' [glue::glue_data()] function. The markdown can contain a yaml header for
#' subject and cc line.
#' 
#' Note that only 'gmail' is supported at the moment, via [gmailr::gm_send_message]
#'
#' @param data A data frame or `tibble` with all the columns that should be
#'   glued into the message. Substitution is performed using
#'   [glue::glue_data()]`
#'
#' @param message A list with components `yaml` and `body`.  You can use
#'   [mm_read_message()] or [mm_read_message_googledoc()] to construct a
#'   message in this format.
#'
#' @param to_col The name of the column in `data` that contains the email
#'   address to send the message to.
#'
#' @param send A character string, one of:
#' * "preview" : displays message in viewer without sending mail
#' * "draft : writes message into "drafts" folder on gmail
#' * "immediately" : sends email
#' 
#' @param confirm If `TRUE` sends email without additional confirmation.
#'   If `FALSE` asks for confirmation before sending.
#'
#' @param sleep_preview If `send == "preview"` the number of seconds to sleep
#'   between each preview.
#'
#' @param sleep_send If `send == "immediately"` the number of seconds to sleep between
#'   each email send (to prevent gmail API 500 errors).
#'
#' @export
#' @importFrom purrr map pmap
#'
#' @return Returns a list for every message, consisting of:
#' * `msg`: The message in `mime` format
#' * `id`: The `gmailr` response id
#' * `type`: preview, draft or sent
#' * `success`: TRUE if the message was sent successfully
#'   
#' @example inst/examples/example_mail_merge.R
#'   
mail_merge <- function(data, message, to_col = "email", send = c("preview", "draft", "immediately"),
                       confirm = FALSE, 
                       sleep_preview = 1, sleep_send = 0.1
){
  
  send <- match.arg(send)
  
  preview <- identical(send, "preview")
  draft   <- identical(send, "draft")
  
  if(nrow(data) == 0) {
    warning("nothing to email")
    return(invisible(data))
  }
  if(is.null(data[[to_col]])) stop("'data' must contain an 'email' column, or specify a 'to_col'")
  
  msg <- mm_read_message(message)
  
  if(!preview && !confirm) {
    yesno("Send ", nrow(data), " emails?")
  }
  
  z <- data %>%
    purrr::pmap(list) %>%
    purrr::map(function(x) {
      
      glued_data <-  glue_mail(x, msg)
      
      args <- list(
        to         = x[[to_col]],
        body       = glued_data[["body"]],
        subject    = glued_data[["subject"]],
        cc         = glued_data[["cc"]]
      )
      
      if (preview) {
        do.call(mm_preview_mail, args)
      } else {
        Sys.sleep(sleep_send)
        if (draft) {
          do.call(mm_send_draft, append(args, list(draft = TRUE)))
        } else {
          do.call(mm_send_mail, append(args, list(draft = FALSE)))
        }
      }
    })
  
  n_messages <- length(z)
  
  if (preview) {
    base::message("Sent preview to viewer")
    class(z) <- "mailmerge_preview"
    attr(z, "sleep") <- sleep_preview
  } else {
    if (draft) {
      base::message("Sent ", n_messages, " messages to your draft folder")
    } else {
    base::message("Sent ", n_messages, " messages to email")
    }
  }
  z
}

#' @export
print.mailmerge_preview <- function(x, ...) { # nocov start
  purrr::walk(x, function(xx){
    in_viewer(xx)
    Sys.sleep(attr(x, "sleep"))
  }
  )
} # nocov end

