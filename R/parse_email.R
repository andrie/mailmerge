#' Parse a markdown document into yaml and body components.
#' 
#' @param txt R Markdown document
#' 
#' @return A list with components `yaml` and `body`
#' @importFrom rmarkdown yaml_front_matter
#' @keywords internal
mm_parse_email <- function(txt){
  yaml <- txt %>% 
    textConnection() %>% 
    rmarkdown::yaml_front_matter()
  body <- sub("---\n.*?\n---\n", "", txt)
  list(
    yaml = yaml,
    body = body
  )
}
