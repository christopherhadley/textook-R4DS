# 13 Relational data

#keys: primary key, foreign key,
#mutating joins: left_join, right_join, inner_join, full_join
#merge vs. joins
#filtering joins: semi_join, anti_join
#set operations: intersect, union, setdiff

library(tidyverse)
library(nycflights13)

# Check that primary keys are unique
planes %>% 
  count(tailnum) %>% 
  filter(n > 1)
weather %>% 
  count(year, month, day, hour, origin) %>% 
  filter(n > 1)
airlines %>%
  count(carrier) %>%
  filter(n>1)
planes %>%
  count(tailnum) %>%
  filter(n>1)
flights %>%
  count(year,month,day,hour,flight,origin,dest,tailnum) %>%
  filter(n>1)

# Add 'surrogate key' to flights table:
# First let's order flights by scheduled departure time and then carrier: 
flights_order <- flights %>%
  arrange(year,month,day,sched_dep_time,carrier,flight) %>%
  mutate(flight_id = row_number()) %>%
  glimpse


# left_join example
# bring in the carrier name, based on carrier code
flights2 <- flights %>% 
  select(year:day, hour, origin, dest, tailnum, carrier)

flights2 %>%
  select(-origin, -dest) %>% # remove origin and dest cols to make narrower
  left_join(airlines, by = "carrier")

# Can do the same using R's base subsetting - which feels a bit like a vlookup
flights2 %>%
  select(-origin, -dest) %>% 
  mutate(name = airlines$name[match(carrier, airlines$carrier)])

# Default
by = NULL # uses all variables that appear in both tables - 'natural' join

by = "x" # joins when 'x' is present in both tables
by = c("a" = "b") # joins when value of a in table1 == value of b in table2


# Exercise
avg_dest_delays <- flights %>%
  group_by(dest) %>%
  summarise(average_delay = mean(arr_delay, na.rm = TRUE)) %>%
  inner_join(airports, by = c(dest = "faa")) 
# we use an inner join to pick out airports for which we have info in the airports table. Using the following filter we see that there are four airports in that table without info in the airports table - these are all in USVI and Puerto Rico
%>%
  filter(is.na(name) == TRUE)

avg_dest_delays %>%
  ggplot(aes(lon, lat, colour = average_delay)) +
  borders("state") +
  geom_point() +
  coord_quickmap()

airports %>%
  semi_join(flights, c("faa" = "dest")) %>%
  ggplot(aes(lon, lat)) +
  borders("state") +
  geom_point() +
  coord_quickmap()

flights_order %>%
  left_join(airports, by = c("origin" = "faa")) %>%
  left_join(airports, by = c("dest" = "faa")) %>%
  select(flight_id, name.x:tzone.y)

# Ex 13.4.6.3
# check tailnum is unique identifier of planes:
planes %>%
  group_by(tailnum) %>%
  count() %>%
  filter(n>1)

# Data is from 2013, so define age relative to then
planes_ages <- planes %>%
  mutate(age = 2013 - year) %>%
  select(tailnum,age)

flights %>%
  inner_join(planes_ages, by = "tailnum") %>%
  group_by(age) %>%
  filter(!is.na(dep_delay)) %>%
  summarise(delay = mean(dep_delay)) %>%
  ggplot(aes(x = age, y = delay)) +
  geom_point() +
  geom_line()

# Ex13.4.6.4
# Let's have a look at weather at origin

flight_weather <- flights %>%
  inner_join(weather, by = c("origin" = "origin",
                             "year" = "year",
                             "month" = "month",
                             "day" = "day",
                             "hour" = "hour"))

#weather %>% filter(precip != 0) %>% select(precip)

flight_weather %>%
  group_by(precip) %>% # how can we group by a continuous variable?
  summarise(delay = mean(dep_delay, na.rm = TRUE)) %>%
  ggplot(aes(x = precip, y = delay)) +
  geom_line() + geom_point()

flight_weather %>%
  group_by(wind_gust) %>% # how can we group by a continuous variable?
  summarise(delay = mean(dep_delay, na.rm = TRUE)) %>%
  filter(wind_gust < 250) %>%
  ggplot(aes(x = wind_gust, y = delay)) +
  geom_line() + geom_point()

flight_weather %>%
  group_by(visib) %>% # how can we group by a continuous variable?
  summarise(delay = mean(dep_delay, na.rm = TRUE)) %>%
  filter(visib < 250) %>%
  ggplot(aes(x = visib, y = delay)) +
  geom_line() + geom_point()

# all of these joins can be achieved with the base function merge(), but dplyr joins are more intuitive, as they are based on SQL syntax, and are faster

semi_join() # keeps rows in table 1 where there are matches with table 2
anti_join() # drops rows in table 1 where there are matches with table 2
# These are useful for diagnosing join mismatches - eg there are many flights that don't have an entry in the planes table
flights %>%
  anti_join(planes, by = "tailnum") %>%
  count(tailnum, sort = TRUE)


# Ex13.5.1.1
# MQ and AA have lots of missing tailnumbers
flights %>%
  anti_join(planes, by = "tailnum") %>%
  count(carrier, sort = TRUE)
# ...however, sometimes they do report tailnumbers...
flights %>%
  filter(!is.na(tailnum) == TRUE) %>%
  count(carrier, sort = TRUE)

flights %>%
  group_by(carrier) %>%
  summarise(sum(is.na(tailnum)), 
            n()) 

filter(flights, carrier == "AA") %>% select(tailnum)

# 2 Planes that have flown at least 100 times
planes_100 <- flights %>%
  group_by(tailnum) %>%
  count(sort = TRUE) %>%
  filter(n > 100)
flights %>% semi_join(planes_100, by = "tailnum")

# Ex 13.5.1.3
library('fueleconomy')
fueleconomy::vehicles %>%
  semi_join(fueleconomy::common, by = c("make", "model"))

# Ex 13.5.1.4
daily_delays <- flights %>%
  filter(dep_delay > 0) %>%
  unite(datenew, year, month, day) %>%
  group_by(datenew) %>%
  summarise(total_delay = sum(dep_delay)) %>%
  arrange(desc(total_delay))

# 2013-3-8 was the worst day
daily_delays %>%
  ggplot(aes(x = datenew, y = total_delay)) + geom_point() + coord_flip()
# Does this plot in the right order, left to right on x axis?

View(daily_delays)

weather %>%
  unite(datenew, year, month, day) %>%
  filter(datenew == "2013_3_8")
View(weathernew)
# Not sure what the answer to this is!  

weather %>%
  group_by(year,month,day) %>%
  count()

# Ex 13.5.1.5
anti_join(flights, airports, by = c("dest" = "faa")) # all flights that go to an airport that's not in our airport list
anti_join(airports, flights, by = c("faa" = "dest")) # all airports without a flight to that originates in New York

# Ex 13.5.1.6

flights %>%
  group_by(tailnum, carrier) %>%
  count(sort = TRUE) %>%
  filter(n() == 1) %>% # somehow this is only counting the first column... (i.e. occurrence of tailnum)
  %>%
  filter(n() > 1)  # filter out single flight planes

