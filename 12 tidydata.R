table1 <- read_csv("country,year,cases,population
Afghanistan,1999,745,19987071
Afghanistan,2000,2666,20595360
Brazil,1999,37737,172006362
Brazil,2000,80488,174504898
China,1999,212258,1272915272
China,2000,213766,1280428583")

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

table4a <- read_csv("country,1999,2000
Afghanistan,745,2666
Brazil,37737,80488
China,212258,213766")

table4b <- read_csv("country,1999,2000
Afghanistan,19987071,20595360
Brazil,172006362,174504898
China,1272915272,1280428583")

table2 %>%
  filter(type == "cases") %>%
  ggplot(aes(year, count)) +
  geom_line(aes(group=country)) + 
  geom_point(aes(colour = country))

tb2_cases <- filter(table2, type == "cases")[["count"]]
tb2_country <- filter(table2, type == "cases")[["country"]]
tb2_year <- filter(table2, type == "cases")[["year"]]
tb2_population <- filter(table2, type == "population")[["count"]]
table2_clean <- tibble(country = tb2_country,
                       year = tb2_year,
                       rate = tb2_cases / tb2_population)




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
