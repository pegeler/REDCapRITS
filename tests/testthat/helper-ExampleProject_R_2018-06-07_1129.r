REDCap_process_csv <- function(data) {
  #Load Hmisc library
  if (!requireNamespace("Hmisc", quietly = TRUE)) {
    stop("This test requires the 'Hmisc' package")
  }

  Hmisc::label(data$row) <- "Name"
  Hmisc::label(data$redcap_repeat_instrument) <- "Repeat Instrument"
  Hmisc::label(data$redcap_repeat_instance) <- "Repeat Instance"
  Hmisc::label(data$mpg) <- "Miles/(US) gallon"
  Hmisc::label(data$cyl) <- "Number of cylinders"
  Hmisc::label(data$disp) <- "Displacement"
  Hmisc::label(data$hp) <- "Gross horsepower"
  Hmisc::label(data$drat) <- "Rear axle ratio"
  Hmisc::label(data$wt) <- "Weight"
  Hmisc::label(data$qsec) <- "1/4 mile time"
  Hmisc::label(data$vs) <- "V engine?"
  Hmisc::label(data$am) <- "Transmission"
  Hmisc::label(data$gear) <- "Number of forward gears"
  Hmisc::label(data$carb) <- "Number of carburetors"
  Hmisc::label(data$color_available___red) <-
    "Colors Available (choice<-Red)"
  Hmisc::label(data$color_available___green) <-
    "Colors Available (choice<-Green)"
  Hmisc::label(data$color_available___blue) <-
    "Colors Available (choice<-Blue)"
  Hmisc::label(data$color_available___black) <-
    "Colors Available (choice<-Black)"
  Hmisc::label(data$motor_trend_cars_complete) <- "Complete?"
  Hmisc::label(data$letter_group___a) <- "Which group? (choice<-A)"
  Hmisc::label(data$letter_group___b) <- "Which group? (choice<-B)"
  Hmisc::label(data$letter_group___c) <- "Which group? (choice<-C)"
  Hmisc::label(data$choice) <- "Choose one"
  Hmisc::label(data$grouping_complete) <- "Complete?"
  Hmisc::label(data$price) <- "Sale price"
  Hmisc::label(data$color) <- "Color"
  Hmisc::label(data$customer) <- "Customer Name"
  Hmisc::label(data$sale_complete) <- "Complete?"
  #Setting Units


  #Setting Factors(will create new variable for factors)
  data$redcap_repeat_instrument.factor <-
    factor(data$redcap_repeat_instrument, levels <-
             c("sale"))
  data$cyl.factor <-
    factor(data$cyl, levels <- c("3", "4", "5", "6", "7", "8"))
  data$vs.factor <- factor(data$vs, levels <- c("1", "0"))
  data$am.factor <- factor(data$am, levels <- c("0", "1"))
  data$gear.factor <- factor(data$gear, levels <- c("3", "4", "5"))
  data$carb.factor <-
    factor(data$carb, levels <-
             c("1", "2", "3", "4", "5", "6", "7", "8"))
  data$color_available___red.factor <-
    factor(data$color_available___red, levels <-
             c("0", "1"))
  data$color_available___green.factor <-
    factor(data$color_available___green, levels <-
             c("0", "1"))
  data$color_available___blue.factor <-
    factor(data$color_available___blue, levels <-
             c("0", "1"))
  data$color_available___black.factor <-
    factor(data$color_available___black, levels <-
             c("0", "1"))
  data$motor_trend_cars_complete.factor <-
    factor(data$motor_trend_cars_complete, levels <-
             c("0", "1", "2"))
  data$letter_group___a.factor <-
    factor(data$letter_group___a, levels <-
             c("0", "1"))
  data$letter_group___b.factor <-
    factor(data$letter_group___b, levels <-
             c("0", "1"))
  data$letter_group___c.factor <-
    factor(data$letter_group___c, levels <-
             c("0", "1"))
  data$choice.factor <-
    factor(data$choice, levels <- c("choice1", "choice2"))
  data$grouping_complete.factor <-
    factor(data$grouping_complete, levels <-
             c("0", "1", "2"))
  data$color.factor <-
    factor(data$color, levels <- c("1", "2", "3", "4"))
  data$sale_complete.factor <-
    factor(data$sale_complete, levels <- c("0", "1", "2"))

  levels(data$redcap_repeat_instrument.factor) <- c("Sale")
  levels(data$cyl.factor) <- c("3", "4", "5", "6", "7", "8")
  levels(data$vs.factor) <- c("Yes", "No")
  levels(data$am.factor) <- c("Automatic", "Manual")
  levels(data$gear.factor) <- c("3", "4", "5")
  levels(data$carb.factor) <-
    c("1", "2", "3", "4", "5", "6", "7", "8")
  levels(data$color_available___red.factor) <-
    c("Unchecked", "Checked")
  levels(data$color_available___green.factor) <-
    c("Unchecked", "Checked")
  levels(data$color_available___blue.factor) <-
    c("Unchecked", "Checked")
  levels(data$color_available___black.factor) <-
    c("Unchecked", "Checked")
  levels(data$motor_trend_cars_complete.factor) <-
    c("Incomplete", "Unverified", "Complete")
  levels(data$letter_group___a.factor) <- c("Unchecked", "Checked")
  levels(data$letter_group___b.factor) <- c("Unchecked", "Checked")
  levels(data$letter_group___c.factor) <- c("Unchecked", "Checked")
  levels(data$choice.factor) <- c("Choice 1", "Choice 2")
  levels(data$grouping_complete.factor) <-
    c("Incomplete", "Unverified", "Complete")
  levels(data$color.factor) <- c("red", "green", "blue", "black")
  levels(data$sale_complete.factor) <-
    c("Incomplete", "Unverified", "Complete")

  data
}
