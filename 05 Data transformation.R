# 5 Data Transformation with dplyr

# Pick observations by their values (filter()).
# Reorder the rows (arrange()).
# Pick variables by their names (select()).
# Create new variables with functions of existing variables (mutate()).
# Collapse many values down to a single summary (summarise()).


jan1 <- filter(flights, month == 1, day == 1)

# Can use logical operations:
filter(flights, month == 11 | month == 12)
# short hand:
nov_dec <- filter(flights, month %in% c(11, 12))

& and
| or
! not

# De Morgan’s law: !(x & y) is the same as !x | !y, and !(x | y) is the same as !x & !y.
#Don't use && and || for this

is.na()

# Exercises 5.2.4 - put View() around these to view the whole lot
# 1.1 
filter(flights, arr_delay >= 120)
# 1.2
filter(flights, dest == "IAH" | dest == "HOU")
or
filter(flights, dest %in% c("IAH","HOU"))
# 1.3
filter(flights, carrier %in% c("AA","DL","UA"))
# 1.4
filter(flights, carrier %in% c(7,8,9))
# 1.5
filter(flights, dep_delay == 0 & arr_delay >= 120)
# 1.6
filter(flights, dep_delay >= 60 & (dep_delay - arr_delay >= 30))
# 1.7

filter(flights, dep_time >= 0 & dep_time <= 0600 )
filter(flights, between(dep_time,0,600))
filter(flights, is.na(dep_time)

# 5.3 Arrange
arrange(flights, year, month, day) # select * from flights order by year, month, day asc
arrange(flights, desc(arr_delay)) # select * from flights order by arr_delay desc

arrange(flights, is.na())

#5.3.1 Exercises
# 1 - order NAs to the start: 
arrange(flights, desc(is.na(dep_time)))
# 2
arrange(flights, desc(arr_delay))
# 3
arrange(flights, air_time/distance)
# 4
arrange(flights, distance)

# Select
select(flights, year, month, day) # select year, month, day from flights
# Various helper functions: starts_with, ends_with, contains, matches, num_range

rename(flights, tail_num = tailnum)


# Mutate - add new cols
flights_sml <- select(flights, 
  year:day, 
  ends_with("delay"), 
  distance, 
  air_time
)
mutate(flights_sml,
  gain = arr_delay - dep_delay,
  speed = distance / air_time * 60
)

# can use transmute() to only keep new columns

transmute(flights,
  dep_time,
  hour = dep_time %/% 100, # integer division by 100
  minute = dep_time %% 100 # integer division and keep remainder
)

# Ex 5.5.2
# 1
transmute(flights,
  dep_time,
  hour = dep_time %/% 100, # integer division by 100
  minute = dep_time %% 100, # integer division and keep remainder
  minutes_since_midnight = hour * 60 + minute
)

select(flights,air_time,arr_time - dep_time)

transmute(flights,
	dep_time,
	arr_time,
	air_time,
	arr_time - dep_time,
	dep_time_minutes = (dep_time %/% 100) * 60 + (dep_time %% 100),
	arr_time_minutes = (arr_time %/% 100) * 60 + (arr_time %% 100),
	minutes_in_air = arr_time_minutes - dep_time_minutes,
	minutes_in_air %/% 60,
	minutes_in_air %% 60
)


# 4 most delayed flights: 
flights_ranked <- mutate(flights,
	rank = min_rank(desc(dep_delay)))
View(arrange(flights_ranked,rank))

# SQL-like operations:
flights %>% distinct(carrier) # select distinct carrier from flights



# 5.6 Summarise and group by
by_day <- group_by(flights, year, month, day)
summarise(by_day, delay = mean(dep_delay, na.rm = TRUE))

# equivalent to: select year, month, day, average(delay) from flights group by 1,2,3


# Pipes - pass data frames from one operation to another: 
delays <- flights %>% 
  group_by(dest) %>% 
  summarise(
    count = n(),
    dist = mean(distance, na.rm = TRUE),
    delay = mean(arr_delay, na.rm = TRUE)
  ) %>% 
  filter(count > 20, dest != "HNL")
# we need na.rm so that it ignores NAs; otherwise we get NA in the final result
# This is similar to using IFERROR in Excel

# Alternative without pipes is the following (messy):
by_dest <- group_by(flights, dest)
delay <- summarise(by_dest,
  count = n(),
  dist = mean(distance, na.rm = TRUE),
  delay = mean(arr_delay, na.rm = TRUE)
)
delay <- filter(delay, count > 20, dest != "HNL")


# Another example of summarise:
not_cancelled %>% 
  group_by(year, month, day) %>% 
  summarise(
    first = min(dep_time),
    last = max(dep_time)
  )


 # counts
 n() # count
 sum(!is.na(x)) # counts number of non-NAs

# The following do the same:
not_cancelled %>% count(dest)
not_cancelled %>% count(dest, sort = TRUE) # This orders by the count rather than dest
not_cancelled %>% group_by(dest) %>% summarise(n())

not_cancelled %>% count(dest,origin)
not_cancelled %>% group_by(dest,origin) %>% summarise(n())





# Ex 5.6.7.
# 3 - missing data; better to use: 
cancelled <- flights %>%
	filter(is.na(dep_time) | is.na(arr_time))

# Cancelled flights by day:
cancelled %>%
	group_by(year,month,day) %>%
	summarise(
		n()
	)

# Summary of flights by day: 
flights %>%
group_by(year,month,day) %>%
summarise(
	number_flights = n(),
	number_cancelled_flights = sum(is.na(dep_time) | is.na(arr_time)),
	prop_flights_cancelled = number_cancelled_flights / number_flights,
	avg_delay2 = mean(arr_delay[arr_delay > 0])
) %>% 
ggplot(mapping = aes(x = prop_flights_cancelled, y = avg_delay2)) + 
	geom_point(alpha=1/10)

ggplot(mapping = aes(x = day, y = prop_flights_cancelled)) +
	geom_point(alpha = 1/10)
# Trying to find the pattern of delays by day ... need to concatenate the date variables into a single field to plot on x axis

# Be careful with aggregate functions and grouping - just like in SQL. Window functions work naturally with grouped data.  


