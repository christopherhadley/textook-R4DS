# 18 - Pipes

# pipe is loaded by tidyverse, but if you only need the pipe, use:
library(magrittr)

# The pipe doesn't work with pipes (see textbook for explanation):
# 1 - functions that use the current env
# 2 - funcs that use lazy evaluation
# you can use tryCatch() and other funcs for error handling

# Don't use a pipe when:
# 1 - you have more than 10 steps
# 2 - you are combinging more than one data source
# 3 - the program has a non-linear logic (i.e. data doesn't just flow downwards)

# sometimes functions don't return anything - you might wish to print, plot or save, but continue with calculations. To circumvent this, use the T pipe:

rnorm(100) %>%
  matrix(ncol = 2) %T>%
  plot() %>%
  str()

# The following gives a NULL:
rnorm(100) %>%
  matrix(ncol = 2) %>%
  plot() %>%
  str()

# Other pipes:
# Functions that don't have a df-based API (eg inputs are vectors) - use %$%
# This explodes cariables in a df, so you can refer to them individually: 
mtcars %$%
  cor(disp, mpg)


# For assignment, you can replace this: 
mtcars <- mtcars %>%
  transform(cyc = cyl*2)

# ... with this: 
mtcars %<>% transform(cyl = cyl*2)
# ... although Hadley Wickham advises against this, as assignments should be explicit