REDCap_process_csv <- function(data) {
  #Load Hmisc library
  if (!require(Hmisc))
    stop("This test requires the 'Hmisc' package")

  label(data$row)="Name"
  label(data$redcap_repeat_instrument)="Repeat Instrument"
  label(data$redcap_repeat_instance)="Repeat Instance"
  label(data$mpg)="Miles/(US) gallon"
  label(data$cyl)="Number of cylinders"
  label(data$disp)="Displacement"
  label(data$hp)="Gross horsepower"
  label(data$drat)="Rear axle ratio"
  label(data$wt)="Weight"
  label(data$qsec)="1/4 mile time"
  label(data$vs)="V engine?"
  label(data$am)="Transmission"
  label(data$gear)="Number of forward gears"
  label(data$carb)="Number of carburetors"
  label(data$color_available___red)="Colors Available (choice=Red)"
  label(data$color_available___green)="Colors Available (choice=Green)"
  label(data$color_available___blue)="Colors Available (choice=Blue)"
  label(data$color_available___black)="Colors Available (choice=Black)"
  label(data$motor_trend_cars_complete)="Complete?"
  label(data$letter_group___a)="Which group? (choice=A)"
  label(data$letter_group___b)="Which group? (choice=B)"
  label(data$letter_group___c)="Which group? (choice=C)"
  label(data$choice)="Choose one"
  label(data$grouping_complete)="Complete?"
  label(data$price)="Sale price"
  label(data$color)="Color"
  label(data$customer)="Customer Name"
  label(data$sale_complete)="Complete?"
  #Setting Units


  #Setting Factors(will create new variable for factors)
  data$redcap_repeat_instrument.factor = factor(data$redcap_repeat_instrument,levels=c("sale"))
  data$cyl.factor = factor(data$cyl,levels=c("3","4","5","6","7","8"))
  data$vs.factor = factor(data$vs,levels=c("1","0"))
  data$am.factor = factor(data$am,levels=c("0","1"))
  data$gear.factor = factor(data$gear,levels=c("3","4","5"))
  data$carb.factor = factor(data$carb,levels=c("1","2","3","4","5","6","7","8"))
  data$color_available___red.factor = factor(data$color_available___red,levels=c("0","1"))
  data$color_available___green.factor = factor(data$color_available___green,levels=c("0","1"))
  data$color_available___blue.factor = factor(data$color_available___blue,levels=c("0","1"))
  data$color_available___black.factor = factor(data$color_available___black,levels=c("0","1"))
  data$motor_trend_cars_complete.factor = factor(data$motor_trend_cars_complete,levels=c("0","1","2"))
  data$letter_group___a.factor = factor(data$letter_group___a,levels=c("0","1"))
  data$letter_group___b.factor = factor(data$letter_group___b,levels=c("0","1"))
  data$letter_group___c.factor = factor(data$letter_group___c,levels=c("0","1"))
  data$choice.factor = factor(data$choice,levels=c("choice1","choice2"))
  data$grouping_complete.factor = factor(data$grouping_complete,levels=c("0","1","2"))
  data$color.factor = factor(data$color,levels=c("1","2","3","4"))
  data$sale_complete.factor = factor(data$sale_complete,levels=c("0","1","2"))

  levels(data$redcap_repeat_instrument.factor)=c("Sale")
  levels(data$cyl.factor)=c("3","4","5","6","7","8")
  levels(data$vs.factor)=c("Yes","No")
  levels(data$am.factor)=c("Automatic","Manual")
  levels(data$gear.factor)=c("3","4","5")
  levels(data$carb.factor)=c("1","2","3","4","5","6","7","8")
  levels(data$color_available___red.factor)=c("Unchecked","Checked")
  levels(data$color_available___green.factor)=c("Unchecked","Checked")
  levels(data$color_available___blue.factor)=c("Unchecked","Checked")
  levels(data$color_available___black.factor)=c("Unchecked","Checked")
  levels(data$motor_trend_cars_complete.factor)=c("Incomplete","Unverified","Complete")
  levels(data$letter_group___a.factor)=c("Unchecked","Checked")
  levels(data$letter_group___b.factor)=c("Unchecked","Checked")
  levels(data$letter_group___c.factor)=c("Unchecked","Checked")
  levels(data$choice.factor)=c("Choice 1","Choice 2")
  levels(data$grouping_complete.factor)=c("Incomplete","Unverified","Complete")
  levels(data$color.factor)=c("red","green","blue","black")
  levels(data$sale_complete.factor)=c("Incomplete","Unverified","Complete")

  data
}
