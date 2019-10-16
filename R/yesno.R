#' Wait for interactive response to yes/no challenge question.
#'
#' Copied from `devtools:::yesno`
#'
#' @param ... Arguments to paste together to form challenge question.
#'
#' @return logical value
#' @importFrom utils menu
#' 
#' @keywords internal
#'
yesno <- function (...) {
  yeses <- c("Yes", "Definitely", "For sure", 
             "Yup", "Yeah", "Of course", "Absolutely")
  nos <- c("No way", "Not yet", "I forget", 
           "No", "Nope", "Uhhhh... Maybe?")
  cat(paste0(..., collapse = ""))
  qs <- c(sample(yeses, 1), sample(nos, 2))
  rand <- sample(length(qs))
  menu(qs[rand]) != which(rand == 1)
}
