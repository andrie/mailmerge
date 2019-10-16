#' Read a markdown file from google drive
#'
#' @param id Unique Google Drive identifier
#'
#' @return the imported document
#' @export
#' @importFrom googledrive drive_download
#' @importFrom withr with_tempfile
#'
read_googledoc <- function(id){
  file <- download_googledoc(id)
  readLines(file) %>% 
      paste(collapse = "\n")
}

download_googledoc <- function(id, file){
  url <- glue::glue("https://drive.google.com/open?id={id}")
  template <- NA
  if (missing(file) || is.null(file)) {
    file <- tempfile(fileext = ".txt")
  }
  # browser()
  googledrive::drive_download(path = file, file = url, verbose = FALSE)
  invisible(file)
}



#' Parse the email template inside a markdown document on google drive.
#'
#'
#' @inheritParams read_googledoc
#' @inherit mm_parse_email
#'
#' @export
#' 
#'
mm_parse_email_from_googledoc <- function(id) {
  txt <- read_googledoc(id = id)
  mm_parse_email(txt = txt)
}



