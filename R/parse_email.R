#' Parse a markdown document into yaml and body components.
#' 
#' You can use this to construct the `message` argument of [mail_merge()].
#' 
#' @param txt A file in markdown format
#' 
#' @importFrom rmarkdown yaml_front_matter
#' @importFrom fs file_exists
#' @export
#' @return A list with components `yaml` and `body`
#' 
#' @family parsing functions
mm_read_message <- function(txt) {
  if (is.list(txt)) return(txt)
  is_file <- function(x) {
    z <- tryCatch(fs::file_exists(x), error = function(e)e)
    if (inherits(z, "error")) return(FALSE)
    isTRUE(z)
  }
  if (is_file(txt)) {
    txt <- readLines(txt)
  }
  yaml <- txt %>% 
    textConnection() %>% 
    rmarkdown::yaml_front_matter()
  body <- sub("---\n.*?\n---\n", "", txt)
  list(
    yaml = yaml,
    body = body
  )
}
