# 16 - Dates and times
library(tidyverse)

library(lubridate)
library(nycflights13)

# R doesn't have a native time class - can use the hms package for one

# Current time:
today() # today's date
now() # timestamp for now

# 16.2.1 From strings...
ymd("2017-01-31")
mdy("January 31st, 2017")
dmy("31-Jan-2017")
ymd(20170131)
ymd(20170131, tz = "UTC")

ymd_hms("2017-01-31 20:11:59")
mdy_hm("01/31/2017 08:01")

# From components of dates:
make_date()
make_datetime()

flights %>% 
  select(year, month, day, hour, minute) %>% 
  mutate(departure = make_datetime(year, month, day, hour, minute))

# tidy up flights dataset with proper times:
# times are in odd format, so we need to us modulo arithmetic to hack times into hours and mins:
make_datetime_100 <- function(year, month, day, time) {
  make_datetime(year, month, day, time %/% 100, time %% 100)
}

flights_dt <- flights %>% 
  filter(!is.na(dep_time), !is.na(arr_time)) %>% 
  mutate(
    dep_time = make_datetime_100(year, month, day, dep_time), 
    arr_time = make_datetime_100(year, month, day, arr_time),# this causes problems with overnight flights - see below - we have used the same day of the flight to define take off and landing times
    sched_dep_time = make_datetime_100(year, month, day, sched_dep_time),
    sched_arr_time = make_datetime_100(year, month, day, sched_arr_time)
  ) %>% 
  select(origin, dest, ends_with("delay"), ends_with("time"))

# time series of flights in a whole yaer (binned to day units)
flights_dt %>%
  ggplot(aes(dep_time)) + 
  geom_freqpoly(binwidth = 86400) # no of secs in one day
# .... shows the number of flights dropping at weekends

datefilter <- ymd(20130315)
flights_dt %>%
#  filter(dep_time < ymd(20130401) & dep_time > ymd(20130315)) %>%
  filter(dep_time < datefilter & dep_time > datefilter - 1) %>%
# this doesn't work ... why not?
#  filter(between(dep_time, datefilter-1, datefilter)) %>%
  ggplot(aes(dep_time)) +
  geom_freqpoly(binwidth = 600)

# Switch types
as_datetime(today())
as_date(now())


# Use the following to find the tzone of a place: 
grep("Australia",OlsonNames(),value=TRUE)
today(tzone = "Australia/Canberra") # time zone specifies that we want the date of that place now - so it can be different to the date here


# Ex 
d1 <- "January 1, 2010"
d2 <- "2015-Mar-07"
d3 <- "06-Jun-2017"
d4 <- c("August 19 (2015)", "July 1 (2015)")
d5 <- "12/30/14" # Dec 30, 2014
mdy(d1)
ymd(d2)
dmy(d3)
mdy(d4)
mdy(d5)


datetime <- ymd_hms("2016-07-08 12:34:56")
year(datetime)
month(datetime) # gives a number
month(datetime,label=TRUE)# gives short name
month(datetime,label=TRUE,abbr=FALSE)# gives long name

mday(datetime) # day of the month
yday(datetime) # day of the year
wday(datetime) # day of the week
wday(datetime,label=TRUE) # day of the week
wday(datetime,label=TRUE,abbr=FALSE) # day of the week


# flights by day:
flights_dt %>%
  mutate(day = wday(dep_time, label = TRUE)) %>%
  ggplot(aes(x = day)) +
  geom_bar()

# weird pattern in delays vs departure time (although not schedule dep time)
flights_dt %>%
  mutate(minute = minute(dep_time)) %>%
  group_by(minute) %>%
  summarise(
    avg_delay = mean(arr_delay, na.rm = TRUE),
    n = n()) %>%
  ggplot(aes(minute, avg_delay)) + geom_line()


# this pattern doesn't exist with scheduled dep times:
sched_dep <- flights_dt %>% 
  mutate(minute = minute(sched_dep_time)) %>% 
  group_by(minute) %>% 
  summarise(
    avg_delay = mean(arr_delay, na.rm = TRUE),
    n = n())

ggplot(sched_dep, aes(minute, avg_delay)) +
  geom_line()

# there is a bias towards planes being schedued at 'nice' times!
ggplot(sched_dep, aes(minute, n)) +
  geom_line()

# Rounding
flights_dt %>% 
  count(week = floor_date(dep_time, "week")) %>%
  ggplot(aes(week, n)) +
  geom_line()

# Setting components:
(datetime <- ymd_hms("2016-07-08 12:34:56"))
#> [1] "2016-07-08 12:34:56 UTC"

year(datetime) <- 2020
datetime
month(datetime) <- 01
datetime
hour(datetime) <- hour(datetime) + 1

# or:
update(datetime, year = 2020, month = 2, mday = 2, hour = 2)

# values too large roll over:
ymd("2015-02-01") %>% 
  update(mday = 30)
ymd("2015-02-01") %>% 
  update(hour = 400)

# setting all flights to be on the same day allows this plot of time of day for all flights within the year
flights_dt %>% 
  mutate(dep_hour = update(dep_time, yday = 1)) %>% 
  ggplot(aes(dep_hour)) +
  geom_freqpoly(binwidth = 300)

# the following doesn't work, as it only picks out the hour, not the time ... 
flights_dt %>% 
  mutate(dep_hour = hour(dep_time)) %>%
  ggplot(aes(dep_hour)) +
  geom_freqpoly(binwidth = .05)


# Ex 16.3.4

# 3 It appears that the dates are recorded using the time zone of the destination, as the largest discrepancies occur for flights way to the west of New York
flights_dt %>%
  mutate(flight_duration = as.numeric(arr_time - dep_time),
         air_time_mins = air_time,
         diff = flight_duration - air_time_mins) %>%
  select(origin, dest, flight_duration, air_time_mins, diff) %>%
  arrange(diff)

# 4
flights_dt %>%
  mutate(sched_dep_hour = hour(sched_dep_time)) %>%
  group_by(sched_dep_hour) %>%
  summarise(avg_dep_delay = mean(dep_delay)) %>%
  ggplot(aes(sched_dep_hour, avg_dep_delay)) +
  geom_smooth() +
  geom_point()

# 5
flights_dt %>%
  mutate(dotw = wday(sched_dep_time, label = TRUE)) %>%
  group_by(dotw) %>%
  summarise(
    avg_dep_delay = mean(dep_delay, na.rm = TRUE),
    avg_arr_delay = mean(arr_delay, na.rm = TRUE)) %>%
  ggplot() + 
  geom_point(aes(x = dotw, y = avg_dep_delay, color = "red")) +
  geom_point(aes(x = dotw, y = avg_arr_delay, color = "blue"))
# Travel on Tuesday or Sunday

# 6
diamonds %>%
  ggplot(aes(x = carat)) + geom_density()
# abnormally large numbers at nice for humans values

ggplot(diamonds, aes(x = carat %% 1 * 100)) +
  geom_histogram(binwidth = 1)

# 16.4 Time spans
# 16.4.1 Durations

# If you substract dates, you get a difftime object: 
h_age <- today() - ymd(19791014)
h_age
str(h_age)
# this is a bit ambiguous, as it can be days, months, years ... 

# lubridate does this:
as.duration(h_age)
# Quickly create time durations: 
dseconds(15)
dminutes(10)
dhours(c(12, 24))
ddays(0:5)
dweeks(3)
dyears(1)
# Durations are always stored in seconds. They can be added and multiplied
tomorrow <- today() + ddays(1)
last_year <- today() - dyears(1)
# althouth this seems to give tomorrow ... 
today()
today() + 1

# Careful! Sometimes you can get odd results because differences are stored in seconds!  Here time zone has changed because of day light saving:
one_pm <- ymd_hms("2016-03-12 13:00:00", tz = "America/New_York")
one_pm
one_pm + ddays(1)

# Periods
# Solution: lubriadate uses periods which are not stored in seconds, but in time periods natural to humans:

one_pm
one_pm + days(1)

seconds(15)
minutes(10)
hours(c(12, 24))
days(7)
months(1:6)
weeks(3)
years(1)


# A leap year
ymd("2016-01-01") + dyears(1)
ymd("2016-01-01") + years(1)

# Daylight Savings Time
one_pm + ddays(1)
one_pm + days(1)

# Moral of the story: use periods rather than durations, unless you know what you are doing!

# Some planes appesr to have arrived before they took off!  
flights_dt %>%
  filter(arr_time < dep_time) %>%
  select(arr_time, dep_time)
# These are overnight flights
flights_dt <- flights_dt %>%
  mutate(overnight = arr_time < dep_time, # define a boolean flag
         arr_time = arr_time + days(overnight*1),
         sched_arr_time = sched_arr_time + days(overnight*1))
# Check that all flights land after taking off!
flights_dt %>% 
  filter(overnight, arr_time < dep_time) 

# intervals
# these are durations with a starting point

next_year <- today() + years(1)
(today() %--% next_year)/ ddays(1)

# Ex 16.4.5
# 1 Every month has different number of days

# 3 
ymd(20150101) + months(0:11)

# 4
floor_date(today(), "year") + months(0:11)

dob = ymd(19820814)

age <- function(dob) {
  (dob %--% today()) %/% years(1)
}
years(1)
age(dob)

# timezones - total mindfield!
# http://r4ds.had.co.nz/dates-and-times.html#time-zones
Sys.timezone()
OlsonNames() # gives names of timezones
