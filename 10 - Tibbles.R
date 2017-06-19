# 10 - Tibbles

# Tibbles are fancier versions of the usual data.frame

library(tidyverse) # use the tibble package

as_tibble(iris) # convert a df to a tibble
as.data.frame() # convert back from tibble to df

# Make a new tibble - specify by cols:
tibble(
  x = 1:5, 
  y = 1, 
  z = x ^ 2 + y
)
# Inputs of length 1 get repeated


# Transposed tibble - tribble() - specify by rows: 
tribble(
  ~x, ~y, ~z,
  #--|--|----
  "a", 2, 3.6,
  "b", 1, 8.5
)

# Equivalent to:
tibble(
	x = c("a", "b"),
	y = c(2, 1),
	z = c(3.6, 8.5)
)

# Printing - by default, only 10 rows are shown, but this can be overriden:
nycflights13::flights %>% 
  print(n = 10, width = Inf) # width = inf means all cols

# refer to parts of a tibble (same for df)
df <- tibble(
  x = runif(5), # uniform distribution
  y = rnorm(5) # normal distribution
)

# Extract by name
df$x
#> [1] 0.434 0.395 0.548 0.762 0.254
df[["x"]]
#> [1] 0.434 0.395 0.548 0.762 0.254

# Extract by position
df[[1]]
#> [1] 0.434 0.395 0.548 0.762 0.254

# to use in a pipe, you need to use '.' placeholder
df %>% .$x
df %>% .[["x"]]

# Find whether something is a df or a tibble:
class(mtcars)
#> [1] "data.frame"
class(as_tibble(mtcars))
#> [1] "tbl_df"     "tbl"        "data.frame"


# Exercises 10.5
# 4
annoying <- tibble(
  `1` = 1:10,
  `2` = `1` * 2 + rnorm(length(`1`))
)
annoying$`1`

ggplot(data = annoying, mapping=aes(x = `1`, y=`2`)) + 
	geom_point()

# rename cols
annoying[["3"]] <- annoying$`2` / annoying$`1`
annoying[["3"]] <- annoying[["2"]] / annoying[["1"]]
#Renaming the columns to one, two, and three:
annoying <- rename(annoying, one = `1`, two = `2`, three = `3`)

# tibble::enframe() converts named vectors to a tibble
enframe(c(a = 1, b = 2, c = 3))

