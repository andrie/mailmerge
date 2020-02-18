## ---- input-data --------------------------------------------------------

dat <-  read.csv(text = '
"email",              "first_name", "thing"
"friend@example.com", "friend",     "something good"
"foe@example.com",    "foe",        "something bad"
', 
stringsAsFactors = FALSE)

## ---- markdown-message --------------------------------------------------

msg <- '
---
subject: Your subject line
---
Hi, {first_name}

I am writing to tell you about {thing}.

HTH

Me
'


## ---- mail-merge --------------------------------------------------------

dat %>% 
  mail_merge(msg)

