context("Frequency table")

#------- Testing a frequency table with all defaults.
testobject1 <- soctable::frequency(chickwts$feed)

test_that("Class is frequency_table", {
  correct <- "frequency_table"
  input<-class(testobject1)
  identical(input, correct)
})

test_that("Total row is correct", {
  correct<-c("Total", "71", "100")
  input<-testobject1$totrow
  identical(input, correct)
})

test_that("Title exists and is blank", {
  correct<-c("")
  input<-testobject1$title
  identical(input, correct)
})

test_that("Values exists and matches the unique values in the data", {
  correct <- c("casein",    "horsebean", "linseed",   "meatmeal",  "soybean",   "sunflower")
  input <- attributes(testobject1$frequencies)$dimnames$Values
  identical(input, correct)
})



# Does not use unused levels
test_that("Unused levels are not used", {
  levels(chickwts$feed)<- c("casein",    "horsebean", "linseed",   "meatmeal",  "soybean",   "sunflower", "other")
  test_object2<-frequency(chickwts$feed)
  correct <- c("casein",    "horsebean", "linseed",   "meatmeal",  "soybean",   "sunflower")
  input <- attributes(testobject1$frequencies)$dimnames$Values
  data("chickwts")
  identical(input, correct)
})

# NA variations
