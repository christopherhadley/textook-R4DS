# 11 - Import data

library(tidyverse) # load readr package


read_csv() # reads comma delimited files
read_csv2() # reads semicolon separated files (common in countries where , is used as the decimal place)
read_tsv() # reads tab delimited files
read_delim() # reads in files with any delimiter.

# We will use read_csv in most cases - for other info see http://r4ds.had.co.nz/data-import.html

# simple usage:
heights <- read_csv("data/heights.csv")

# other optional arguemnts (eg):
col_names = FALSE # don't treat row 1 as col names; names cols as X1, X2 etc
col_names = c("x", "y", "z")
skip = 2 # skip 2 lines
comment = "#" # don't import lines that begin with a comment
na = "." # how NAs are labelled in your dataset

# The standard R approach is to use read.csv()
# The 'readr' functions are much faster and produce tibbles

# Strings containing commas need to be in quotes " " (to change the character, use read_delim())

# Parsing - turns strings into stuff
parse_logical(c("TRUE", "FALSE", "NA"))
parse_integer(c("1", "2", "3"))
parse_date(c("2010-01-01", "1979-10-14"))
# All the same - first arg is the string, second arg is how to treat NAs
parse_integer(c("1", "231", ".", "456"), na = ".")

parse_double()
parse_datetime()
parse_date()
parse_time()

# To avoid problems with , and . in numbers, readr has 'locales'
parse_double("1,23", locale = locale(decimal_mark = ","))
# Default locale is US

# readr assumes data is UTF-8

# factors = categorical data
fruit <- c("apple", "banana")
parse_factor(c("apple", "banana", "bananana"), levels = fruit)
# this gives an error for the mis-spelling of banana



# Dates
parse_datetime() # expects ISO8601 date - e.g. 2010-01-01T2010 - this is the most common date format

library(hms)
parse_time("01:10 am")
#> 01:10:00
parse_time("20:10:01")
#> 20:10:01


guess_parser() # guesses which data type is present
parse_guess() # then parses it

# You can specify column types manually - this is good practice: 
challenge <- read_csv(
  readr_example("challenge.csv"), 
  col_types = cols(
    x = col_integer(),
    y = col_character()
  )
)

# can also output using
write_csv(df, 'path.csv')
write_excel_csv()

# Type info is lost when saving to CSV
# For caching interim data, use
write_rds()
read_rds()
# ... these save as an R binary format

# feather package implements a fast binary file format that can be shared across programming languages
library(feather)
write_feather(challenge, "challenge.feather")
read_feather("challenge.feather")

# For other file I/O:

For rectangular data:
haven reads SPSS, Stata, and SAS files.
readxl reads excel files (both .xls and .xlsx).
DBI, along with a database specific backend (e.g. RMySQL, RSQLite, RPostgreSQL etc) allows you to run SQL queries against a database and return a data frame.

For hierarchical data: use jsonlite (by Jeroen Ooms) for json, and xml2 for XML. Jenny Bryan has some excellent worked examples at https://jennybc.github.io/purrr-tutorial/examples.html.

For other file types, try the R data import/export manual and the rio package.