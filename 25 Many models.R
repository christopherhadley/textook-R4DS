# 25 - Many models

library(modelr)
library(tidyverse)

library(gapminder) # Hans Rosling's data!

gapminder %>%
  ggplot(aes(year, lifeExp, group = country)) +
  geom_line(alpha = 1/3)

# Let's look at the UK: 
uk <- gapminder %>%
  filter(country == "United Kingdom")
uk %>%
  ggplot(aes(year, lifeExp)) + 
  geom_line() + 
  ggtitle("Full data")

uk_mod <- lm(lifeExp ~ year, data = uk)
uk %>%
  add_predictions(uk_mod) %>%
  ggplot(aes(year, pred)) + 
  geom_line() + 
  ggtitle("Linear trend")

uk %>%
  add_residuals(uk_mod) %>%
  ggplot(aes(year, resid)) + 
  geom_line() + 
  ggtitle("Linear trend")

# We can do this for country in term - but there's a better way - use purrr to iterate!
# However, we are iterating not over columns, but groups of rows
# We therefore need a nested dataframe. We start with a grouped df and 'nest' it
by_country <- gapminder %>%
  group_by(country, continent) %>%
  nest()
by_country

# This creates a tibble with one row per country, and a col called 'data' that includes a tibble for that country
# the data col is tricky to look at - it's a complicated list, and they're still working on tools for this = using str() is not recommended as the output will be v long

# in grouped df, each row = observation
# in nested df, each row = group

# Or: in nested df, each row is a 'meta observation' with complete time record for each country, not just a single point

# Now we can define a function for fitting a model to each country: 
country_model <- function(df) {
  lm(lifeExp ~ year, data = df)
}
# We could do it by country: 
models <- map(by_country$data, country_model)
models
# ... but instead of creating a new object, why not store it in the df by_country? Makes it much neater - otherwise we'll end up with lots of objects with one entry per country

by_country <- by_country %>% 
  mutate(model = map(data, country_model))
by_country
# Advantage: everything is in sync when you filter or arrange
by_country %>%
  filter(continent == "Europe")

# Now calculate residuals for each model: 
by_country <- by_country %>% 
  mutate(
    resids = map2(data, model, add_residuals)
  )
by_country
# Now we can unnest: 
resids <- unnest(by_country, resids)
resids
# Now that we have a regular df, let's look at the residuals:
resids %>% 
  ggplot(aes(year, resid)) +
  geom_line(aes(group = country), alpha = 1 / 3) + 
  geom_smooth(se = FALSE)

resids %>% 
  ggplot(aes(year, resid, group = country)) +
  geom_line(alpha = 1 / 3) + 
  facet_wrap(~continent)

# Model quality - use glance() to extract usual model measures (eg R squared)
glance <- by_country %>% 
  mutate(glance = map(model, broom::glance)) %>% 
  unnest(glance, .drop = TRUE) # .drop drops eerything other than 'glance' tibble
glance
# a bit of a mess, as 'glance' is the name of the function, the intermediate tibble, and the resulting object, but you get the idea

glance %>%
  arrange(r.squared)
# Worst models all in Africa

glance %>% 
  ggplot(aes(continent, r.squared)) + 
  geom_jitter(width = 0.1, alpha = 1/3)

# pick out the columns with a bad fit: 
bad_fit <- filter(glance, r.squared < 0.25)

gapminder %>% 
  semi_join(bad_fit, by = "country") %>% 
  ggplot(aes(year, lifeExp, colour = country)) +
  geom_line()

# Ex 25.2.5
# 3 - removing need for semi_join: 
glance2 <- by_country %>% 
  mutate(glance = map(model, broom::glance)) %>% 
  unnest(glance) %>% 
  filter(r.squared < 0.25) %>%
  unnest(data) %>%
  ggplot(aes(year, lifeExp, colour = country)) + 
  geom_line()


# 25. 3 list columns
# See the text book for discussion of this: http://r4ds.had.co.nz/many-models.html#list-columns-1
# Basic workflow: 
# 1 - create list-column using: nest, summarise + list, mutate + a map
# 2 - You create other intermediate list-columns by transforming existing list columns with map(), map2() or pmap() - like we did above when creating list-col of models
# 3 - simplify list-col back down to df or atomic vectors

# Creating list-columns
# by nest()

# Either nest grouped dfs: 
gapminder %>% 
  group_by(country, continent) %>% 
  nest()
# Or nest ungrouped dfs, by telling it what to nest on: 
gapminder %>% 
  nest(year:gdpPercap)

# From vectorised functions: 
# Lots of functions take atomic vectors -> lists (eg str_split). If you do this inside mutate, you get a list column
df <- tribble(
  ~x1,
  "a,b,c", 
  "d,e,f,g"
)
df %>% 
  mutate(x2 = stringr::str_split(x1, ","))
# unnest() knows what to do:
df %>% 
  mutate(x2 = stringr::str_split(x1, ",")) %>% 
  unnest()

