# mailmerge (development version)

* Bug fix: in `mail_merge()`, the `msg` object provided by the user was overwritten which prevented mails from being drafted or sent. (@bcheggeseth, #9)

# mailmerge 0.2.1

* Throw error if not authenticated against gmail, and provide better setup instructions to use `gmailr::gm_auth()`, suggested by @maelle in #3

# mailmerge 0.2.0

* First release to CRAN
