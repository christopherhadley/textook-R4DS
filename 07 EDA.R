# Ex 7.3.4


# Finding the maximum values of variables:
diamonds %>% summarise(max(x)) # select max(x) from diamonds

# Lots of outliers - zero sized diamonds! Scale y axis with coord_cartesian to show this: 
ggplot(data = diamonds) +
  geom_histogram(mapping = aes(x = x), binwidth = .1) +  
  coord_cartesian(ylim = c(0, 50))

# There is a blank spot in the price!  
ggplot(data = diamonds) +
  geom_histogram(mapping = aes(x = price), binwidth = 10) + coord_cartesian(ylim = 50)

# Missing values
# Best way to handle these is to replace odd values with blanks (rather than dropping entire row)

# Drop row:
diamonds2 <- diamonds %>% 
  filter(between(y, 3, 20))

 # Replace:
diamonds2 <- diamonds %>% 
	mutate(y = ifelse(y < 3 | y > 20, NA, y))

# Scale frequency plots so that each category has unit area under the curve:
ggplot(data = diamonds, mapping = aes(x = price, y = ..density..)) + 
  geom_freqpoly(mapping = aes(colour = cut), binwidth = 500)

 # box plot example
 ggplot(data = diamonds, mapping = aes(x = cut, y = price)) +
  geom_boxplot()

ggplot(data = mpg) +
  geom_boxplot(mapping = aes(x = reorder(class, hwy, FUN = median), y = hwy)) +
  coord_flip()


# Ex 7.5.1.1
# 1

nycflights13::flights %>% 
  mutate(
    cancelled = is.na(dep_time),
    sched_hour = sched_dep_time %/% 100,
    sched_min = sched_dep_time %% 100,
    sched_dep_time = sched_hour + sched_min / 60
  ) %>% 
  ggplot(mapping = aes(sched_dep_time)) + 
    geom_freqpoly(mapping = aes(colour = cancelled, y = ..density..), binwidth = .5)

# Covariation
# Nice place to start - number of measurements for each pair of possible outcomes
ggplot(data = diamonds) +
	geom_count(mapping = aes(x = cut, y = color))

# Visualise the count of this with a heatmap: 
diamonds %>% 
  count(color, cut) %>%  
  ggplot(mapping = aes(x = color, y = cut)) +
    geom_tile(mapping = aes(fill = n))

# To colour by proportion within the row, define a new quantity
diamonds %>% 
  count(color, cut) %>%
  group_by(color) %>%
  mutate(prop = n / sum(n)) %>%
  ggplot(mapping = aes(x = color, y = cut)) +
	  geom_tile(mapping = aes(fill = prop)) +
	  scale_fill_viridis(limits = c(0, 1))

# To scale by proportion of color within cut, just change group by: 
diamonds %>% 
  count(color, cut) %>%
  group_by(cut) %>%
  mutate(prop = n / sum(n)) %>%
  ggplot(mapping = aes(x = color, y = cut)) +
  geom_tile(mapping = aes(fill = prop)) +
  scale_fill_viridis(limits = c(0, 1))

# You can bin a continuous variable and treat it like a discrete variable:
ggplot(data = smaller, mapping = aes(x = carat, y = price)) + 
  geom_boxplot(mapping = aes(group = cut_width(carat, 0.1)))


# Linear regression
library(modelr)

mod <- lm(log(price) ~ log(carat), data = diamonds)

diamonds2 <- diamonds %>% 
  add_residuals(mod) %>% 
  mutate(resid = exp(resid))

ggplot(data = diamonds2) + 
  geom_point(mapping = aes(x = carat, y = resid))


# 7.7 ggplot2 calls
# So far we've been writing: 
ggplot(data = faithful, mapping = aes(x = eruptions)) + 
  geom_freqpoly(binwidth = 0.25)
# But the args are always in the same order, so you can omit the names:
ggplot(faithful,aes(eruptions)) + 
  geom_freqpoly(binwidth = 0.25)