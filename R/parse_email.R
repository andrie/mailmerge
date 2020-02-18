#' Parse a markdown document into yaml and body components.
#' 
#' You can use this to construct the `message` argument of [mail_merge()].
#' 
#' @param txt A file in markdown format
#' 
#' @return A list with components `yaml` and `body`
#' @importFrom rmarkdown yaml_front_matter
#' @importFrom fs file_exists
#' @export
#' 
#' @family parsing functions
mm_read_message <- function(txt) {
  if (fs::file_exists(txt)) {
    txt <- readLines(txt)
  }
  if (is.list(txt)) return(txt)
  yaml <- txt %>% 
    textConnection() %>% 
    rmarkdown::yaml_front_matter()
  body <- sub("---\n.*?\n---\n", "", txt)
  list(
    yaml = yaml,
    body = body
  )
}
