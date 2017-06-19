#12 Tidy data

# Rules for making data 'tidy':
# Each variable must have its own column.
# Each observation must have its own row.
# Each value must have its own cell.

# Also:
# Put each dataset in a tibble.
# Put each variable in a column.

# This relates to blue / green variables in Tableau. In the example below, you can use country, year as indices, and then cases and population are variables. The choice of case/pop is not an index, so table2 fails the tidy test ... 


# Exercises  12.2.1

# 2
# First of all, recreate the tables (good practice of importing data): 

#>       country  year  cases population
#>         <chr> <int>  <int>      <int>
#> 1 Afghanistan  1999    745   19987071
#> 2 Afghanistan  2000   2666   20595360
#> 3      Brazil  1999  37737  172006362
#> 4      Brazil  2000  80488  174504898
#> 5       China  1999 212258 1272915272
#> 6       China  2000 213766 1280428583

# Code to make that tibble: 


# Be careful with which row the " " are on .... 
if you do
read_csv(
	"blah") # This looks ugly, but doesn't require skip=1

read_csv("
	blah
	",skip=1) # This looks nicer, but it treats the " as starting a blank row

# This is the way to do it:
table1 <- read_csv("country,year,cases,population
  Afghanistan,1999,745,19987071
  Afghanistan,2000,2666,20595360
  Brazil,1999,37737,172006362
  Brazil,2000,80488,174504898
  China,1999,212258,1272915272
  China,2000,213766,1280428583")

# Need to be careful ... the following gives the first row as a row in the df, and a row of NAs at the end because of the space before the ", which will mess up plots
# If you remove this, it seems to work.  Working in Sublime and pasting appears to be a bad way of working, as the returns get pasted oddly...
table1 <- read_csv("
country,year,cases,population
  Afghanistan,1999,745,19987071
  Afghanistan,2000,2666,20595360
  Brazil,1999,37737,172006362
  Brazil,2000,80488,174504898
  China,1999,212258,1272915272
  China,2000,213766,1280428583
  ")
table1

# This one's OK:
table2 <- read_csv("country,year,type,count
 Afghanistan,1999,cases,745
 Afghanistan,1999,population,19987071
 Afghanistan,2000,cases,2666
 Afghanistan,2000,population,20595360
 Brazil,1999,cases,37737
 Brazil,1999,population,172006362
 Brazil,2000,cases,80488
 Brazil,2000,population,174504898
 China,1999,cases,212258
 China,1999,population,1272915272
 China,2000,cases,213766
 China,2000,population,1280428583")




# Alternatively (much easier ... appears to be less fragile)
table1 <- tribble(
	~country,~year,~cases,~population,
	"Afghanistan",1999,745,19987071,
	"Afghanistan",2000,2666,20595360,
	"Brazil",1999,37737,172006362,
	"Brazil",2000,80488,174504898,
	"China",1999,212258,1272915272,
	"China",2000,213766,1280428583
)

table2 <- read_csv("
	country,year,type,count
	Afghanistan,1999,cases,745
	Afghanistan,1999,population,19987071
	Afghanistan,2000,cases,2666
	Afghanistan,2000,population,20595360
	Brazil,1999,cases,37737
	Brazil,1999,population,172006362
	Brazil,2000,cases,80488
	Brazil,2000,population,174504898
	China,1999,cases,212258
	China,1999,population,1272915272
	China,2000,cases,213766
	China,2000,population,1280428583
",skip=1)


table4a <- read_csv("country,1999,2000
Afghanistan,745,2666
Brazil,37737,80488
China,212258,213766")

table4b <- read_csv("country,1999,2000
Afghanistan,19987071,20595360
Brazil,172006362,174504898
China,1272915272,1280428583
",skip=1)

table1 %>% 
  mutate(rate = cases / population * 10000) %>% 
  count(year, wt = cases)

library(ggplot2)
ggplot(table1, aes(year, cases)) + 
  geom_line(aes(group = country), colour = "grey50") + 
  geom_point(aes(colour = country))




tb2_cases <- filter(table2, type == "cases")[["count"]]
tb2_country <- filter(table2, type == "cases")[["country"]]
tb2_year <- filter(table2, type == "cases")[["year"]]
tb2_population <- filter(table2, type == "population")[["count"]]
table2_clean <- tibble(country = tb2_country,
       year = tb2_year,
       rate = tb2_cases / tb2_population)
table2_clean

# Gathering and spreading
# To manipulate tables into tidy datasets, use gather() and spread()

# table4a
#> # A tibble: 3 × 3
#>       country `1999` `2000`
#> *       <chr>  <int>  <int>
#> 1 Afghanistan    745   2666
#> 2      Brazil  37737  80488
#> 3       China 212258 213766

#The problem here is that we have two observations per row, not one, and the year is a key value, not names of variables

#This can be changed using: 

table4a %>% 
  gather(`1999`, `2000`, key = "year", value = "cases")
#> # A tibble: 6 × 3
#>       country  year  cases
#>         <chr> <chr>  <int>
#> 1 Afghanistan  1999    745
#> 2      Brazil  1999  37737
#> 3       China  1999 212258
#> 4 Afghanistan  2000   2666
#> 5      Brazil  2000  80488
#> 6       China  2000 213766

So: tell it which columns to change, what the new variable name is ("key") and what the actual observation is ("cases")

# join the two tables table4a and table4b into a single, tidy dataset, join the tables:
tidy4a <- table4a %>% 
  gather(`1999`, `2000`, key = "year", value = "cases")
tidy4b <- table4b %>% 
  gather(`1999`, `2000`, key = "year", value = "population")
left_join(tidy4a, tidy4b)

# The opposite operation is: 
table2
#> # A tibble: 12 × 4
#>       country  year       type     count
#>         <chr> <int>      <chr>     <int>
#> 1 Afghanistan  1999      cases       745
#> 2 Afghanistan  1999 population  19987071

spread(table2, key = type, value = count)
#> # A tibble: 6 × 4
#>       country  year  cases population
#> *       <chr> <int>  <int>      <int>
#> 1 Afghanistan  1999    745   19987071
#> 2 Afghanistan  2000   2666   20595360

spread and gather are not symmetric (i.e. applying one then the other goes not give back the same data frame) because col type info is not transferred between them
variable names are always converted to a char vector
convert = TRUE tries to char vectors to the appropriate type



# Separate and unite data
# Split columns by looking for a regex: 
table3 %>% 
  separate(rate, into = c("cases", "population"), sep = "/") # This separates one column with entries such as 34134/567 into 34134 and 567
# you can pass stings or vectors of integers to separate

# The opposite is unite:
table5 %>% 
  unite(new, century, year, sep = "")


# There are two types of missing values
# - implicit - missing
# - explicit - represented by NA

# The following example show how you can turn an implicit to an explicit:
stocks <- tibble(
  year   = c(2015, 2015, 2015, 2015, 2016, 2016, 2016),
  qtr    = c(   1,    2,    3,    4,    2,    3,    4),
  return = c(1.88, 0.59, 0.35,   NA, 0.92, 0.17, 2.66)
)
# turn na.rm = FALSE to put an NA there: 
stocks %>% 
  spread(year, return) %>% 
  gather(year, return, `2015`:`2016`, na.rm = TRUE)

# Another way: 
stocks %>% complete(year,qtr) # This finds all unique combinations of year and qtr and makes sure that they're all present and adds NAs where necessary

# Can also fill missing values: 
treatment <- tribble(
  ~ person,           ~ treatment, ~response,
  "Derrick Whitmore", 1,           7,
  NA,                 2,           10,
  NA,                 3,           9,
  "Katherine Burke",  1,           4
)

treatment %>% 
  fill(person)






preg <- tribble(
  ~pregnant, ~male, ~female,
  "yes",     NA,    10,
  "no",      20,    12
) %>%
  gather(preg, sex, count, male, female)

# Case study of tidying data: WHO dataset
who
View(who)

# gather cols that we think are values, not variables
who1 <- who %>% 
  gather(new_sp_m014:newrel_f65, key = "key", value = "cases", na.rm = TRUE)
who1

View(who1)
who1 %>% count(key)

# Make column names consistent
who2 <- who1 %>% 
  mutate(key = stringr::str_replace(key, "newrel", "new_rel"))
who2

# Now separate the keys:
who3 <- who2 %>% 
  separate(key, c("new", "type", "sexage"), sep = "_")
who3


who3 %>% 
  count(new)
# So, all rows are 'new' -> let's drop it, along with iso2 and ios3 (redundant)
who4 <- who3 %>% 
  select(-new, -iso2, -iso3)
who5 <- who4 %>% 
  separate(sexage, c("sex", "age"), sep = 1)

# In reality, we'd build a pipe to do it all in one go:
who %>%
  gather(code, value, new_sp_m014:newrel_f65, na.rm = TRUE) %>% 
  mutate(code = stringr::str_replace(code, "newrel", "new_rel")) %>%
  separate(code, c("new", "var", "sexage")) %>% 
  select(-new, -iso2, -iso3) %>% 
  separate(sexage, c("sex", "age"), sep = 1)

# Check that country, iso2 and iso3 show the same info
select(who3, country, iso2, iso3) %>%
  distinct() %>%
  group_by(country) %>%
  filter(n() > 1)


who5 %>%
  group_by(country, year, sex) %>%
  filter(year > 1995) %>%
  summarise(cases = sum(cases)) %>%
  unite(country_sex, country, sex, remove = FALSE) %>%
  ggplot(aes(x = year, y = cases, group = country_sex, colour = sex)) +
  geom_line()
  