# 21 - Iteration
library(tidyverse)

# Syntax of a simple for-loop: 
output <- vector("double", ncol(df))  # 1. output
for (i in seq_along(df)) {            # 2. sequence
  output[[i]] <- median(df[[i]])      # 3. body
}
output

# seq_along() is better than using 1:length(l), because it correctly handles zero-length vectors: 
y <- vector("double", 0)
seq_along(y)
1:length(y)

mtcars
View(mtcars)
seq_along(mtcars)

# Ex 21.2.1
# 1.1 - mtcars
attributes(mtcars) # has an attr called names

mtcars_means <- vector("double", ncol(mtcars)) # assign space beforehand
names(mtcars_means) <- names(mtcars)
for (i in names(mtcars)) {
   mtcars_means[i] <- mean(mtcars[[i]], na.rm = TRUE)
}
mtcars_means

# 1.2
library(nycflights13)
flights

flights_types <- vector("list", ncol(flights))
names(flights_types) <- names(flights)
for (i in names(flights)) {
  flights_types[[i]] <- class(flights[[i]])
}
flights_types

# 1.3 - iris uniques
str(iris)

data(iris)
iris_uniq <- vector("double", ncol(iris))
names(iris_uniq) <- names(iris)
for (i in names(iris)) {
  iris_uniq[i] <- length(unique(iris[[i]]))
}
iris_uniq

# 1.4 
n <- 10
mu <- c(-10,0,10,100)
normals <- vector("list", length(mu))
for (i in seq_along(normals)) {
  #output[mu] <- 
  normals[[i]] <- rnorm(n, mean = mu[i])
}
normals

# 2
out <- ""
for (x in letters) {
  out <- stringr::str_c(out, x)
}
out
# replace with: 
stringr::str_c(letters, collapse = "")

all.equal()


# Alice the camel
library(stringr)
humps <- c("five", "four", "three", "two", "one", "no")
for (i in humps) {
  cat(str_c("Alice the camel has ", rep(i, 3), " hump", if(i != "one") {"s"}, collapse = "\n"), sep = "\n")
  if (i == "no") {
    cat("Now Alice is a horse.\n")
  } else {
    cat("So go, Alice, go.\n\n")
  }
}

# Ten in the bed
numbers <- c("ten", "nine", "eight", "seven", "six", "five",
             "four", "three", "two", "one")

for (n in numbers) {
  cat("There were", n, "in the bed\n")
  cat("and the little one said,\n")
  if (n == "one") {
    cat("I'm lonely...")
  } else {
    cat("\"Roll over! Roll over!\"\n")
    cat("So they all rolled over and one fell out.\n\n")
  }
}

# I don't know this one, so I'm doing 10 green bottles

n <- 10
seq(n)
for (i in seq(n, 1)) { # define the sequence the other way round
  #cat(str_c(rep(str_c(i, " green bottles hanging on the wall\n"), 2), sep = "\n"))
  
  cat(str_c(i, " green bottle",if(i != 1) {"s"}," hanging on the wall\n"))
  cat(str_c(i, " green bottle",if(i != 1) {"s"}," hanging on the wall\n"))
  cat("And if one green bottle should accidentally fall,\n")
  if (i == 1) {
    cat("There\'ll be no green bottles hanging on wall.\n\n")
  } else {
    
    cat(str_c("There\'ll be ", i - 1, " green bottle", if(i != 2) {"s"}, " hanging on wall.\n\n"))
  }
}

library(microbenchmark)
add_to_vector <- function(n) {
  output <- vector("integer", 0)
  for (i in seq_len(n)) {
    output <- c(output, i)
  }
  output  
}
microbenchmark(add_to_vector(10000), times = 3)


add_to_vector_2 <- function(n) {
  output <- vector("integer", n)
  for (i in seq_len(n)) {
    output[[i]] <- i
  }
  output
}
microbenchmark(add_to_vector_2(10000), times = 3)

# pre-allocated vector is about hundred times faster!

# 21.3 For loop variations

# Ways to loop
# 1 - loop over numeric indices:
for (i in seq_along(xs)) {
  i
}
# 2 - loop over elements - this is useful if you only care about side-effects, like plotting or saving a file - because difficult to save output efficiently
for (x in xs) {
  
}

# 3 - loop over names
results <- vector("list", length(x))
names(results) <- names(x)

# Iteration over an index is best, as you can extract both names and value
for (i in seq_along(x)) {
  name <- names(x)[[i]]
  value <- x[[i]]
}

# 21.3.3 - unkonwn output lengths
# eg simulating random vectors of random lengths
# Don't do this by progressively growing vector - scales badly. Instead, save outputs to different lists and then combine into one

# Flatten a list of vectors into a single vector using unlist()
list <- list("a",1:2,"c")
unlist(list)

# Putting together a long string - save output in a character vector and then combine into one
output <- "a"
output <- list(output, "b")
paste(output, collapse = "")
# is this the same as str_c?

# Generating a big df - instead of rbind()ing each iteration, save output in a list, then use dplyr::bind_rows(output) to combine output into single df

# 21.3.4 unknow sequence lenght - use while loop, not for
while (condition) {
  # do stuff
}
# Any for loop can be re-written as a while loop

# eg - how many coin flips do you need to make before you get HHH?
flip <- function() sample(c("T", "H"), 1)

howmanyflips <- function() {

  flips <- 0
  nheads <- 0
  
  while (nheads < 3) {
    if (flip() == "H") {
      nheads <- nheads + 1
    } else {
      nheads <- 0
    }
    flips <- flips + 1
  }
  flips
  
}

howmanyflips()

# These are mostly used for simulations, rather than analysis

# Ex 21.3.5 
# 1 - read in multiple CSVs with same headers: 
# 1.csv: 
# a,b,c
# 1,2,3

#getwd()
files <- dir("data/", pattern = "\\.csv$", full.names = TRUE)
df <- vector("list", length(files))
for (i in seq_along(files)) {
  df[[i]] <- read_csv(file = files[[i]])
}
df <- bind_rows(df)
df

# 2 - nothing happens if you loop over names and there are none:
x <- c(1,2,3)
names(x)
for (nm in names(x)) {
  print(nm)
}

# 3 - mean of each num col in a df
show_mean <- function(df) {
  means <- vector("double", ncol(df))
  for (nm in names(df)) {
    if (is.numeric(df[[nm]])) {
      cat(nm, ":\t", format(mean(df[[nm]], na.rm = TRUE), digits = 2), "\n")
    }
  }
}
show_mean(iris)


# 4 - ??


# Functional programming
# You can pass functions to functions - eg: 
col_summary <- function(df, fun) {
  out <- vector("double", length(df))
  for (i in seq_along(df)) {
    out[i] <- fun(df[[i]])
  }
  out
}
col_summary(df, median)
col_summary(df, mean)

# In base R, we can use apply(), lapply(), rapply() - but using purrr is much better

# Mapping - looping over a vector, doing something to each element, saving output - so common that we have several functions in purrr:
map() # makes a list.
map_lgl() #makes a logical vector.
map_dbl() #makes a double vector.
map_int() #makes an integer vector.
map_chr() #makes a character vector.

# Each func takes a vector, applies a function to each element, and returns a vector of the same length (and same names); the type is determined by the function we use

# Ex: the for loop above can be replaced with: 
map_dbl(df, mean)
map_dbl(df, median)
map_dbl(df, sd)
# ... so much easier!  Even better is using the pipe: 
df %>% map_dbl(mean)


# Shortcuts
# Ex: split mtcars into three, based on the three uniqe values of cyl: 
unique(mtcars[["cyl"]])


models <- mtcars %>% 
  split(.$cyl) %>% 
  map(function(df) lm(mpg ~ wt, data = df)) # this is called an 'anonymous function'
models

# Shorter syntax: 

models <- mtcars %>%
  split(.$cyl) %>%
  map(~lm(mpg ~ wt, data = .))
# . refers to current list element, in the same way that i refers to current index in a for loop
models

# Let's extract r squared from summary():
# Normally run summary() and extract r.squared
summary(models)


models %>%
  map(summary) %>%
  map_dbl(~.$r.squared)

# Extracting named components is so common that purr allows you to use a string:
models %>%
  map(summary) %>%
  map_dbl("r.squared")

# you can also integer to select elements by a position: 
x <- list(list(1, 2, 3), list(4, 5, 6), list(7, 8, 9))
x %>% map_dbl(2)

# Comparison of maps and base R functions - http://r4ds.had.co.nz/iteration.html#base-r

# Ex 21.5.3
# 1.1 
mtcars %>%
  map_dbl(mean)
# 1.2
nycflights13::flights %>% map(typeof)
# alternatively: 
map(nycflights13::flights, typeof)
# 1.3
iris %>% map(unique) %>% map(length)
# 1.4 - both these are the same:
c(-10, 0, 10, 100) %>% map(rnorm, n = 10)
list(-10, 0, 10, 100) %>% map(rnorm, n = 10)

# 2
map_lgl(mtcars, is.factor)

# 3
map(1:5, runif)

# Error handling - http://r4ds.had.co.nz/iteration.html#dealing-with-failure
# You can use
safely()
possibly()
quietly()


# 21.7 - Mapping over multiple arguments
mu <- list(5, 10, -3)
sigma <- list(1, 5, 10)
# To vary both mean and sd, use map2()
map2(mu, sigma, rnorm, n = 5) %>% str()
# Args before the func are varied, args after are constant

# pmap is for many args:
n <- list(1, 3, 5)
args1 <- list(n, mu, sigma)
args1 %>%
  pmap(rnorm) %>%
  str()

# better to name the parameters; even better to use a df:
params <- tribble(
  ~mean, ~sd, ~n,
  5,     1,  1,
  10,     5,  3,
  -3,    10,  5
)
params %>% 
  pmap(rnorm)

# You can even vary the function: 
f <- c("runif", "rnorm", "rpois")
param <- list(
  list(min = -1, max = 1), 
  list(sd = 5),
  list(lambda = 10)
)
invoke_map(f, param, n = 5) %>% str() # funcs and params need to be in same ordering

# Alternatively: 
sim <- tribble(
  ~f,      ~params,
  "runif", list(min = -1, max = 1),
  "rnorm", list(sd = 5),
  "rpois", list(lambda = 10)
)
sim %>% 
  mutate(sim = invoke_map(f, params, n = 10))

# Walk - this is when you want to call a function for side effects, not for return value, eg printing or saving
# Very simple eg:
list(1, "a", 3) %>%
  walk(print)

# walk2 and pwalk much more useful - for examle, to save multipl plots to different locations:
library(ggplot2)
plots <- mtcars %>%
  split(.$cyl) %>%
  map(~ggplot(., aes(mpg, wt)) + geom_point())
paths <- stringr::str_c(names(plots), ".pdf")
pwalk(list(paths, plots), ggsave, path = tempdir())

# Predicate funcs - keep() and discard()
iris %>%
  discard(is.factor) %>%
  str()

iris %>%
  keep(is.factor) %>%
  str()

# some() and every() determine whether predicate is true for any or all of the elements:
x <- list(1:5, letters, list(10))
x %>% some(is_character)
x %>% every(is_vector)
# Plenty of others: detect, detect_index, sample, head_while, tail_while


# Can join dfs:
dfs <- list(
  age = tibble(name = "John", age = 30),
  sex = tibble(name = c("John", "Mary"), sex = c("M", "F")),
  trt = tibble(name = "Mary", treatment = "A")
)
dfs %>% reduce(full_join)

# Find overlap between lists: 
vs <- list(
  c(1, 3, 5, 6, 10),
  c(1, 2, 3, 7, 8, 10),
  c(1, 2, 3, 4, 8, 9, 10)
)

vs %>% reduce(intersect)

# reduce() takes a binary function (one with two primary inputs) and applies it again and again until there is only a single element left