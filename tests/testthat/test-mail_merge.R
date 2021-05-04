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

test_that("send mail from pre-imported dat", {
  Sys.setenv(mailmerge_test = TRUE)
  
  mockery::stub(mail_merge, "gmailr::gm_has_token", TRUE)
  
  to      <- "test@example.com"
  body    <- "hello world"
  subject <- "subject"
  
  z <- mm_send_mail(to = to, body = body, subject = subject)
  expect_is(z, "list")
  
  z <- mm_read_message(msg)
  expect_is(z, "list")
  
  z <- dat %>% 
    mail_merge(msg, send = "preview")
  
  expect_is(z, "mailmerge_preview")
  expect_true(grepl(dat$email[1], z[[1]], fixed = TRUE))
  expect_true(grepl(dat$email[2], z[[2]], fixed = TRUE))
  expect_equal(nrow(dat), length(z))
  
  
  tf <- tempfile(fileext = ".txt")
  writeLines(msg[-(1:3)], con = tf)
  
  z <- mm_read_message(tf)
  expect_is(z, "list")
  
  z <- mail_merge(dat, tf, send = "preview")
  
  expect_is(z, "mailmerge_preview")
  expect_true(grepl(dat$email[1], z[[1]], fixed = TRUE))
  expect_true(grepl(dat$email[2], z[[2]], fixed = TRUE))
  expect_equal(nrow(dat), length(z))
  
  
})

test_that("error message if not authed", {
  mockery::stub(mail_merge, "gmailr::gm_has_token", FALSE)

  to      <- "test@example.com"
  body    <- "hello world"
  subject <- "subject"
  tf <- tempfile(fileext = ".txt")
  writeLines(msg[-(1:3)], con = tf)

  mail_merge(dat, tf, send = "draft") %>% 
    expect_error(
      "You must authenticate with gmailr first.  Use `gmailr::gm_auth()"
    )
  

})



test_that("yesno() messages are meaningful", {
  mockery::stub(mail_merge, "gmailr::gm_has_token", TRUE)
  mockery::stub(mail_merge, "yesno", TRUE)
  
  to      <- "test@example.com"
  body    <- "hello world"
  subject <- "subject"
  tf <- tempfile(fileext = ".txt")
  writeLines(msg[-(1:3)], con = tf)
  
  mail_merge(dat, tf, send = "draft") %>% 
    expect_output(
      "Send 2 emails (draft)?"
    ) %>% 
    expect_null()
  
   mail_merge(dat, tf, send = "immediately") %>% 
    expect_output(
      "Send 2 emails (immediately)?"
    ) %>% 
    expect_null()
  
})
