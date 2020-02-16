test_that("send mail", {
  to <- "test@example.com"
  body <- "hello world"
  subject <- "subject"
  Sys.setenv(mailmerge_test = TRUE)
  
  z <- mm_send_mail(to = to, body = body, subject = subject)
  expect_is(z, "mime")
})
