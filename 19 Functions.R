

# Syntax for functions:
rescale01 <- function(x) {
  rng <- range(x, na.rm = TRUE)
  (x - rng[1]) / (rng[2] - rng[1])
}
rescale01(c(0, 5, 10))

# Functions return the last line that was calculated

# Ex 19.2.1.2 - doesn't work!
x <- c(1:3,Inf,-Inf)
rescale01 <- function(x) {
  ifelse(is.infinite(x) == TRUE, 1, x)
  #ifelse(is.infinite(-x) == TRUE, x <- 0, x <- x)
  rng <- range(x, na.rm = TRUE)
  (x - rng[1]) / (rng[2] - rng[1])
}
rescale01(x)
rescale01(c(0, 5, 10, Inf))


# Ex 19.2.1.5
# there must be a quicker way...
x <- c(1:3, NA, 5)
y <- c(1,NA,NA,4)
both_na <- function(x, y) {
  sum(is.na(x)) + sum(is.na(y))
}
both_na(x,y)


# section -----------------------------------------------------------------

# hit cmd + shift + R to get these section dividers


# Conditionals: 
if (condition) {
  # code executed when condition is TRUE
} else if(that) {
  # blah
} else {
  # code executed when condition is FALSE
}

# Logical operations: && || etc (not & and |)
# == can be vectorised and return a vector of booleans

# Multiple if conditions can be replaced by switch: 
function(x, y, op) {
  switch(op,
         plus = x + y,
         minus = x - y,
         times = x * y,
         divide = x / y,
         stop("Unknown op!")
  )
}

# ifelse takes an input object, computes the test, and returns another object of the same length/size containing the values specified
c <- c(1:10)
ifelse(c %% 2 == 1, "odd", "even")

# Ex 19.4.4
# 2
library(lubridate)
time <- now()
greeting <- function(time) {
  h <- hour(time)
  if (h < 12) { "Good morning"}
  else if(h < 17) {"Good afternoon"}
  else {"Good evening"}
}
greeting(time)

# 3 fizzbuzz...
fizzbuzz <- function(x) {
  if (x %% 15 == 0) {"fizzbuzz"}
  else if (x %% 3 == 0) {"fizz"}
  else if (x %% 5 == 0) {"buzz"}
  else {x}
}

fizzbuzz(11)

# Trying to vectorise this ... I want to write a fizzbuzz function that returns a vector of fizzes and buzzes without doing loops but I can't get it to work!  Return to this!
fizzbuzz2 <- function(x) {
  if (x %% 15 == 0) #{x <- "fizzbuzz"}
  else if (x %% 3 == 0) #{x <- "fizz"}
  else if (x %% 5 == 0) #{x <- "buzz"}
}
y <- c(1:20)
fizzbuzz2(y)
if (y %% 15 == 0) #{x <- "fizzbuzz"}
{"sdafd"}


# -----------------------------------------------------------------------

# Good practice to specify data args first, control parameters last:
# Compute confidence interval around mean using normal approximation
# you can also specify default values - eg:
mean_ci <- function(x, conf = 0.95) {
  se <- sd(x) / sqrt(length(x))
  alpha <- 1 - conf
  mean(x) + se * qnorm(c(alpha / 2, 1 - alpha / 2))
}

x <- runif(100)
mean_ci(x)
mean_ci(x, conf = 0.99)

# ... args - you can write funcs that take any number of inputs, and also write wrappers that pass on the args:
commas <- function(...) stringr::str_c(..., collapse = ", ")
commas(letters[1:10])

# Another useful function:
rule <- function(..., pad = "-") {
  title <- paste0(...)
  width <- getOption("width") - nchar(title) - 5
  cat(title, " ", stringr::str_dup(pad, width), "\n", sep = "")
}
rule("Important output")

# this doesn't work, as collapse appears twice - once here (passed on in ...) and again in specification of commas
commas(letters, collapse = "-")


# return - can return value using return() but best to limit this to cases when you are returning an early, simpler answer

f <- function() {
  if (!x) {
    return(something_short)
  }
  
  # Do 
  # something
  # that
  # takes
  # many
  # lines
  # to
  # express
}


# R allows you to redefine normal functions and be naughty, like this: 
`+` <- function(x, y) {
  if (runif(1) < 0.1) {
    sum(x, y)
  } else {
    sum(x, y) * 1.1
  }
}
# So, 10% of the time we get the right answer to the following: 
1 + 2

table(replicate(1000, 1 + 2))

# Remove the function definition:
rm(`+`)
1 + 2


