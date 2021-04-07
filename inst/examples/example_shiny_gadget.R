## ---- input-data --------------------------------------------------------

dat <-  data.frame(
  email      = c("friend@example.com", "foe@example.com"),
  first_name = c("friend", "foe"),
  thing      = c("something good", "something bad"),
  stringsAsFactors = FALSE
)

## ---- markdown-message --------------------------------------------------

msg <- '
---
subject: "**Hello, {first_name}**"
---

Hi, **{first_name}**

I am writing to tell you about **{thing}**.

{if (first_name == "friend") "Regards" else ""}


Me
'



## ---- display shiny gadget ----------------------------------------------

if (interactive()) {
  dat %>%
    mail_merge(msg) %>%
    preview_mailmerge()
}



