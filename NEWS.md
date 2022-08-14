# mailmerge 0.2.5

* Update documentation to conform to HTML5

# mailmerge 0.2.4

* Handle email where the CC is `N/A`

# mailmerge 0.2.3
 
* Use `googledrive::with_drive_quiet()` to comply with `googledrive` 2.0.0
 
# mailmerge 0.2.2

Bug fixes

* Fix a bug that prevented interactive confirmation when sending mail 
(@bcheggeseth, #10)

# mailmerge 0.2.1

* Throw error if not authenticated against gmail, and provide better setup
instructions to use `gmailr::gm_auth()`, suggested by @maelle in #3

# mailmerge 0.2.0

* First release to CRAN
