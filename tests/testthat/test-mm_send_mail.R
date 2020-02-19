# sample data -------------

dat <-  read.csv(text = '
"email",              "first_name", "thing"
"friend@example.com", "friend",     "something good"
"foe@example.com",    "foe",        "something bad"
', 
stringsAsFactors = FALSE)


msg <- '
---
subject: Your subject line
---
Hi, {first_name}

I am writing to tell you about {thing}.

HTH

Me
'


# test sending mail ----------

test_that("send mail", {
  to <- "test@example.com"
  body <- "hello world"
  subject <- "subject"
  Sys.setenv(mailmerge_test = TRUE)
  
  z <- mm_send_mail(to = to, body = body, subject = subject)
  expect_is(z, "mime")
  
  z <- mm_read_message(msg)
  expect_is(z, "list")
  
  z <- dat %>% 
    mail_merge(msg, preview = TRUE)
  expect_is(z, "list")
  expect_true(grepl(dat$email[1], z[[1]], fixed = TRUE))
  expect_true(grepl(dat$email[2], z[[2]], fixed = TRUE))
  expect_equal(nrow(dat), length(z))
  
  
  
})
