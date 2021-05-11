# sample data -------------
{
  dat <-  readr::read_csv('
"email",              "first_name", "thing"
"friend@example.com", "friend",     "something good"
"foe@example.com",    "foe",        "something bad"
')
  
  
  msg <- '
---
subject: Your subject line
---
Hi, {first_name}

I am writing to tell you about {thing}.

HTH

Me
'
}


# test sending mail ----------

test_that("send mail from pre-imported dat", {
  
  withr::local_envvar(list(mailmerge_test = TRUE))
  
  mockery::stub(mail_merge, "gmailr::gm_has_token", TRUE)
  
  to      <- "test@example.com"
  body    <- "hello world"
  subject <- "subject"
  
  mm_send_mail(to = to, body = body, subject = subject) %>% 
    expect_type("list")
  
  mm_read_message(msg) %>% 
    expect_type("list")
  
  z <- dat %>% 
    mail_merge(msg, send = "preview")
  
  expect_s3_class(z, "mailmerge_preview")
  expect_true(grepl(dat$email[1], z[[1]], fixed = TRUE))
  expect_true(grepl(dat$email[2], z[[2]], fixed = TRUE))
  expect_equal(nrow(dat), length(z))
  
  
  tf <- tempfile(fileext = ".txt")
  writeLines(msg[-(1:3)], con = tf)
  
  mm_read_message(tf) %>% 
    expect_type("list")
  
  z <- mail_merge(dat, tf, send = "preview")
  
  expect_s3_class(z, "mailmerge_preview")
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


test_that("mail_merge returns correct list output", {
  # mockery::stub(mail_merge, "gmailr::gm_has_token", TRUE)
  mockery::stub(mm_send_mail, "gmailr::gm_create_draft", function(...)stop("mock error"))
  mockery::stub(mm_send_mail, "gmailr::gm_send_message", function(...)list(id = "mock", labelIDs = list("mock")))
  
  to      <- "test@example.com"
  body    <- "{first_name}"
  subject <- "subject"
  tf <- tempfile(fileext = ".txt")
  writeLines("{first_name}", con = tf)
  
  expect_warning(
    mm_send_mail(to = to, body = body, subject = subject, draft = TRUE), 
    "mock error"
  )
  
  suppressWarnings(
    z <- mm_send_mail(to = to, body = body, subject = subject, draft = TRUE)
  )
  expect_false(z$success)
  
  z <- mm_send_mail(to = to, body = body, subject = subject, draft = FALSE)  
  expect_true(z$success)
})


test_that("mail_merge() correctly counts number of messages", {
  mockery::stub(mail_merge, "gmailr::gm_has_token", TRUE)
  
  tf <- tempfile(fileext = ".txt")
  writeLines("{first_name}", con = tf)

  mockery::stub(mm_send_mail, "gmailr::gm_send_message", function(...)stop("mock error"))
  
  suppressWarnings(
    mail_merge(dat, tf, send = "draft", confirm = TRUE)
  ) %>%
    expect_message("Sent 0 messages to your draft folder")
})  
  
  
test_that("mail_merge() correctly counts number of messages", {

  to      <- "test@example.com"
  body    <- "hello world"
  subject <- "subject"
  tf <- tempfile(fileext = ".txt")
  writeLines(msg[-(1:3)], con = tf)

  mockery::stub(mail_merge, "gmailr::gm_has_token", TRUE, depth = 1)
  mockery::stub(mail_merge, "gmailr::gm_send_message", function(...)list(id = "mock", labelIDs = list("mock")), depth = 2)

  expect_message(
    suppressWarnings(
    z <- mail_merge(dat, tf, send = "immediately", confirm = TRUE)
    ),
    "Sent 0 messages to email"
  )

})

