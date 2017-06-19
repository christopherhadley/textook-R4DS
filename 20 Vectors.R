# 20 - Vectors

# It's important to understand vectors, as they underlie tibbles etc
# This is all base R, but we'll use purr package to remove some inconsistencies

library(tidyverse)

# Types of vectors:
# 1 - Atomic - logical, integer, double, character, complex, and raw.
# 2 - Lists

typeof()
length()

# Augemented vectors

# Factors are built on top of integer vectors.
# Dates and date-times are built on of numeric vectors.
# Data frames and tibbles are built on top of lists.


# Numeric - you can make an integer by writing an L after a number
x <- 1L

# Doubles are approximations - eg:
x <- sqrt(2)^2
x - 2
# .. so when comparing, don't use ==, but dplyr::near()

# Special values: 
# Integers: NA
# Doubles: NA, NaN, Inf, -Inf

# Don't use ==, but: 
is.infinite()
is.na()
is.nan()

x <- c(1:4, Inf, Inf, -Inf, NA)

is.finite(x)
is.infinite(x)
!is.infinite(x)

# ... so NA is neither finite nor infinite...

# Ex 20.3.5
# 2:
dplyr::near # this shows the source code for near() - it calcalutes whether two numbers are within the square root of the smallest number that the machine can represent

# 5: 
library(readr)
# These functions parse strings into logical, int, double:
parse_logical(c("TRUE", "FALSE", "1", "0", "true", "t", "NA"))
parse_integer(c("1235", "0134", "NA"))
parse_number(c("1.0", "3.5", "1,000", "NA"))

# Coercion
# Explicit coercion - use of functions like as.integer() etc

# Implicit coercion
# e.g. using logicals in a numeric context:
x <- sample(20, 100, replace = TRUE)
# Can make a vector of booleans:
y <- x > 10
y
# ... and then sum them up to give the number of trues:
sum(y)

# In older code, you somtimes see the opposite (logical -> int):
if (length(x)) {
  # do something if the lenght is non-null
}

# Better practice is to be explicit:
length(x) > 0

# When combining types, the most complex wins:
typeof(c(TRUE, 1L))
typeof(c(1L, 1.5))
typeof(c(1.5, "a"))

# Concatenate vectors into one:
a <- c(1,2,3)
b <- c(4,5)
c <- c(a,b)
c


# 20.4.2 Testing types: 
# R provides base functions such as is.vector(), but these can return odd results.  Best to use the following, from the purrr package: 
is_logical()
is_integer()
is_double()
is_numeric()
is_character()
is_atomic()
is_list()
is_vector()

# There are also funcs like:
is_scalar_atomic()
# ... which checks that the length is 1

# 20.4.3
# R will also implictly coerce the length of vectors and recycle shorter vectors
# Most built-in funcs are vectorised, so we can do this:
sample(10) + 100
runif(10) > 0.5
# There aren't any scalars ... 'scalars' are vectors of unit length

# In this example, the short vector is repeated cyclically: 
1:10 + 1:2
# ... when the length of the longer vector is not an int multiple of the shorter, you get a message: 
1:10 + 1:3

# Vectorised functions in tidyverse will give errors when you recycle anything other than a scalar. For this reason you need to use rep()

tibble(x = 1:4, y = 1:2)
tibble(x = 1:4, y = rep(1:2, 2)) # repeats the vector
tibble(x = 1:4, y = rep(1:2, each = 2)) # repeates each element of the vector


# 20.4.4 Naming vectors
c(x = 1, y = 2, z = 4)
purrr:set_names(1:3, c("a", "b", "c"))

# 20.4.5 Subsetting
filter() # works with tibbles

# Four types of things you can subset a vector with: 
# 1 - vector of integers (all +ve, all -ve, or zero)
x <- c("one", "two", "three", "four", "five")
x[c(3, 2, 5)]
# -ve inputs drop the elements at the specified positions:
x[c(-1, -3, -5)]

# 2 - subsetting with logical - this returns all values where condition is TRUE
x <- c(10, 3, NA, 5)
x[!is.na(x)] # return all elements that are not NA
x[x %% 2 == 0] # all elements that are even or NA

# 3 - named vectors
x <- c(abc = 1, def= 2, xyz = 3)
x[c("xyz", "def", "def")]

# 4 - whole thing (useful for matrices)
x[]

# Variation - [[]] always extracts a single element, and always drops names - useful in for loops

# Ex 20.4.6
x <- c(10, 3, NA, 5)
mean(is.na(x)) # proportion of missing values
mean(!is.na(x)) # proportion of values that are present
sum(!is.finite(x)) # number of values that are not finite
mean(!is.finite(x)) # proportion of v alues that are not finite - ie NA, NaN, Inf, -Inf



# The function is.vector only checks whether the object has no attributes other than names. Thus a list is a vector:
is.vector(list(a = 1, b = 2))
# But any object that has an attribute (other than names) is not:
x <- 1:10
attr(x, "something") <- TRUE
is.vector(x)

# The function is.atomic explicitly checks whether an object is one of the atomic types (“logical”, “integer”, “numeric”, “complex”, “character”, and “raw”) or NULL.

is.atomic(1:10)
is.atomic(list(a = 1))
#The function is.atomic will consider objects to be atomic even if they have extra attributes.

# 3 - these are basically the same: 
set_names(1:4, c("a", "b", "c", "d"))
setNames( 1:3, c("foo", "bar", "baz") )
# ... but by looking at source code, we can see that set_names checks that the object is a vector, and that the set of names is of the same length as the vector:
set_names
setNames

# 4.1 - last element of a vector
x <- c(1:5)
x_last_value <- function(v) { # should really consider case of zero lenght items, but this appears to work:
  v[[length(v)]]
}
x_last_value(numeric())

# 4.2 - even positions
x_evens <- function(v) {
  v[1:length(v) %% 2 == 0]
}
x_evens(c(1:5))
x_evens(letters)

# 4.3 - all but last
x_all_but_last <- function(v) { # should really consider case of zero length items, but this appears to work:
  v[1:length(v) - 1]
}
x_all_but_last(letters)

# 4.4 - even numbers
x_even_elements <- function(v) {
  v[!is.na(v) & v %% 2 == 0]
}
x_even_elements(c(1:20, NA, NA))


# 5 - different handling of NA etc: 
x <- c(-5:5, Inf, -Inf, NaN, NA)
x
x[x <= 0]
x[-which(x > 0)]

x[NA]
x[NaN]

# 6 - you get NAs (hardly surprising!)
x <- c(1:10)
x[11]
x <- c("a" = 1, "b" = 2)
x["a"]
x["c"]


# 20.5 - lists
x_named <- list(a = 1, b = 2, c = 3)
str(x_named)
typeof(x_named)

# you can have lists of lists
z <- list(list(1, 2), list(3, 4))
str(z)

# [ extracts part of list - returns a list
# [[]] extracts a single element
# $ extracts a named element of a list


# A great explanation is the pepper shaker - 20.5.3 - http://r4ds.had.co.nz/vectors.html#lists-of-condiments

# subsetting with tibbles works the same way - but the difference is that the tibbles require all elements (cols) to have the same length
x <- tibble(a = 1:2, b = 3:4)
x[["a"]] # returns the first col as a list
x["a"] # returns the first col as a tibble
x[1] # returns a tibble of the left col
x[1, ] # returns a tibble of the top row

# 20.6 Attributes
# Think of these as named list of of vectors that can be attached to any object
x <- 1:10
attr(x, "greeting")
attr(x, "greeting") <- "Hello"
attr(x, "farewell") <- "Goodbye"
attributes(x)

# 3 important attributes: : names, dimensions, classes
# R implements a form of OOP called S3

# Atomic vectors and lists are building blocks for vector types like factors, dates etc.  Hadley W calls these augmented vectors, since they are vectors with other attributes such as a class etc

# Factors - cagtegorical data - built on top of integers with a levels attribute
x <- factor(c("ab", "cd", "ab"), levels = c("ab", "cd", "ef"))
typeof(x)
attributes(x)

# Dates are numerical vectors that represnt number of days since 1/1/70
x <- as.Date("1971-01-01")
unclass(x)
typeof(x)
attributes(x)

# date-times are number of seconds since 1/1/1970 midnight

