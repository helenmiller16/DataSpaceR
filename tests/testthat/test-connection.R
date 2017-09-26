context("DataSpaceConnection")

con <- try(connectDS(), silent = TRUE)

test_that("can connect to DataSpace", {
  expect_is(con, "DataSpaceConnection")
  expect_is(con, "R6")
})

if ("DataSpaceConnection" %in% class(con)) {
  con_names <- c(".__enclos_env__",
                 "availableStudies",
                 "config",
                 "clone",
                 "getStudy",
                 "print",
                 "initialize")
  test_that("`DataSpaceConnection`` contains correct fields and methods", {
    expect_equal(names(con), con_names)
  })

  if (identical(names(con), con_names)) {
    test_that("`print`", {
      cap_output <- capture.output(con$print())
      expect_length(cap_output, 8)

      if (length(cap_output) == 8) {
        expect_equal(cap_output[1], "<DataSpaceConnection>")
        expect_equal(cap_output[2], "  URL: https://dataspace.cavd.org")
        expect_match(cap_output[3], "  User: \\S+@\\S+")
        expect_match(cap_output[4], "  Available studies: \\d+")
        expect_match(cap_output[5], "  - \\d+ studies with data")
        expect_match(cap_output[6], "  - \\d+ subjects")
        expect_match(cap_output[7], "  - \\d+ assays")
        expect_match(cap_output[8], "  - \\d+ data points")
      }
    })

    test_that("`config`", {
      configs <- c("labkey.url.base", "labkey.user.email", "curlOptions", "verbose")
      curlOptions <- c("ssl.verifyhost", "ssl.verifypeer", "followlocation",
                       "sslversion", "useragent", "netrc.file")
      useragent <- paste("DataSpaceR", packageVersion("DataSpaceR"))

      expect_is(con$config, "list")
      expect_equal(names(con$config), configs)

      if (all.equal(names(con$config), configs)) {
        expect_equal(con$config$labkey.url.base, "https://dataspace.cavd.org")
        expect_match(con$config$labkey.user.email, "\\S+@\\S+")
        expect_false(con$config$verbose)
        expect_is(con$config$curlOptions, "CURLOptions")
        expect_equal(names(con$config$curlOptions), curlOptions)

        if (all.equal(names(con$config$curlOptions), curlOptions)) {
          expect_equal(con$config$curlOptions$ssl.verifyhost, 2)
          expect_true(con$config$curlOptions$ssl.verifypeer)
          expect_true(con$config$curlOptions$followlocation)
          expect_equal(con$config$curlOptions$sslversion, 1)
          expect_equal(con$config$curlOptions$useragent, useragent)
          expect_match(con$config$curlOptions$netrc.file, "netrc")
        }
      }
    })

    test_that("`availableStudies`", {
      expect_is(con$availableStudies, "data.frame")
      expect_equal(names(con$availableStudies),
                   c("study_name", "title"))
      expect_gt(nrow(con$availableStudies), 0)
    })

    test_that("`getStudy`", {
      cavd <- try(con$getStudy(""), silent = TRUE)

      expect_is(cavd, "DataSpaceStudy")
      expect_is(cavd, "R6")
    })
  }
}