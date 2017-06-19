# 15 - Factors

# Factors are for working with categorical (discrete) data

library(tidyverse)
library(forcats)

# e.g. useful with months
x1 <- c("Dec", "Apr", "Jan", "Mar")

# Using a string to record this variable has two problems:
# There are only twelve possible months, and there’s nothing saving you from typos:
  x2 <- c("Dec", "Apr", "Jam", "Mar")
# It doesn’t sort in a useful way:
  
sort(x1)
#> [1] "Apr" "Dec" "Jan" "Mar"
# You can fix both of these problems with a factor. To create a factor you must start by creating a list of the valid levels:
  
month_levels <- c(
  "Jan", "Feb", "Mar", "Apr", "May", "Jun", 
  "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
)

# This sorts the sorting problem:
y1 <- factor(x1, levels = month_levels) # omitting the levels puts them in alphabetical order
sort(y1)
# errors get converted to NAs:
y2 <- factor(x2, levels = month_levels)


# If data is in a tibble, you can see cats by doing:
gss_cat %>%
  count(race)

ggplot(gss_cat, aes(race)) +
  geom_bar()

# Ex 15.3.1.1 - bar chart of income
gss_cat %>%
  filter(rincome != "Not applicable") %>%
  ggplot(aes(rincome)) + 
  geom_bar() + 
  coord_flip()

# Ex 15.3.1.2 - most common religion
gss_cat %>%
  count(relig,sort = TRUE)
# Answer: protestant
gss_cat %>%
  count(partyid,sort = TRUE)
# Answer: Ind

# Ex 15.3.1.3
gss_cat %>%
  count(relig,denom,sort = TRUE)
# Answer: Protestant
# Another way: 
gss_cat %>%
  ggplot(mapping = aes(x = relig, y=denom)) +
  geom_bin2d() +
  coord_flip()

# Modifying factor order - imagine we want to plot tv hours by religion. This plot is a mess:
relig <- gss_cat %>%
  group_by(relig) %>%
  summarise(
#    age = mean(age, na.rm = TRUE),
    tvhours = mean(tvhours, na.rm = TRUE),
    n = n()
  )
ggplot(relig, aes(tvhours, relig)) + geom_point()
# but this is clearer: 
ggplot(relig, aes(tvhours, fct_reorder(relig, tvhours))) +
  geom_point()

# better to do it in a mutate:
relig %>%
  mutate(relig = fct_reorder(relig, tvhours)) %>%
  ggplot(aes(tvhours, relig)) +
  geom_point()

rincome <- gss_cat %>%
  group_by(rincome) %>%
  summarise(
    age = mean(age, na.rm = TRUE),
    tvhours = mean(tvhours, na.rm = TRUE),
    n = n()
  )

ggplot(rincome, aes(age, fct_reorder(rincome, age))) + geom_point()
# but here there is an implicit ordering of income brackets!

ggplot(rincome, aes(age, fct_relevel(rincome, "Not applicable"))) +
  geom_point()

# re-ordering is also useful for charts (See explanation in the book)
by_age <- gss_cat %>%
  filter(!is.na(age)) %>%
  group_by(age, marital) %>%
  count() %>%
  mutate(prop = n / sum(n))

ggplot(by_age, aes(age, prop, colour = marital)) +
  geom_line(na.rm = TRUE)
# this is easier to read, as the colours are ordered:
ggplot(by_age, aes(age, prop, colour = fct_reorder2(marital, age, prop))) +
  geom_line() +
  labs(colour = "marital")


# Ex 15.4.1 - distribution of tvhours
gss_cat %>%
  ggplot(aes(x = age, y = tvhours)) + geom_point(alpha=1/10) + coord_flip()
summary(gss_cat["tvhours"]) # gives some nice stats of the distribution
gss_cat %>%
  filter(!is.na(tvhours)) %>%
  ggplot(aes(x = tvhours)) + 
  geom_histogram(binwidth = 1)


# Modifying factor levels - eg: 
gss_cat %>%
  mutate(partyid = fct_recode(partyid,
                              "Republican, strong"    = "Strong republican",
                              "Republican, weak"      = "Not str republican",
                              "Independent, near rep" = "Ind,near rep",
                              "Independent, near dem" = "Ind,near dem",
                              "Democrat, weak"        = "Not str democrat",
                              "Democrat, strong"      = "Strong democrat"
  )) %>%
  count(partyid)

# can also collapse levels: 
gss_cat %>%
  mutate(partyid = fct_collapse(partyid,
                                other = c("No answer", "Don't know", "Other party"),
                                rep = c("Strong republican", "Not str republican"),
                                ind = c("Ind,near rep", "Independent", "Ind,near dem"),
                                dem = c("Not str democrat", "Strong democrat")
  )) %>%
  count(partyid)

# Lump together factors:
gss_cat %>%
  mutate(relig = fct_lump(relig)) %>%
  count(relig)

gss_cat %>%
  group_by(relig) %>%
  count(sort = TRUE)


# Ex 15.5.1
gss_cat %>%
  mutate( partyid = fct_collapse(partyid,
               other = c("No answer", "Don't know", "Other party"),
               rep = c("Strong republican", "Not str republican"),
               ind = c("Ind,near rep", "Independent", "Ind,near dem"),
               dem = c("Not str democrat", "Strong democrat")) ) %>%
  count(year, partyid) %>%
  group_by(year) %>%
  mutate(p = n/sum(n)) %>%
  ggplot(aes(x = year, y = p, colour = fct_reorder2(partyid, year, p))) +
  geom_point() +
  geom_line() +
  labs(colour = "Party")
