# 24 - model building
library(tidyverse)
library(modelr)
options(na.action = na.warn)

library(nycflights13)
library(lubridate)

# It looks like lower quality diamons are more expensive: 
ggplot(diamonds, aes(cut, price)) + geom_boxplot()
ggplot(diamonds, aes(color, price)) + geom_boxplot()
ggplot(diamonds, aes(clarity, price)) + geom_boxplot()

# This is probably because cheaper diamons are larger, and weight is the main driver of cost
ggplot(diamonds, aes(carat, price)) + 
  geom_hex(bins = 50)

# Fit a model to separate out the effect of weight
# Tweak data: remove v large diamonds, and log transform the carat and price variables

diamonds2 <- diamonds %>%
  filter(carat <= 2.5) %>%
  mutate(lprice = log2(price), lcarat = log2(carat))

# This makes it easier to see a linear relationship
ggplot(diamonds2, aes(lcarat, lprice)) +
  geom_hex(bins = 50)

mod_diamond <- lm(lprice ~ lcarat, data = diamonds2)

grid <- diamonds2 %>%
  data_grid(carat = seq_range(carat, 20)) %>%
  mutate(lcarat = log2(carat)) %>%
  add_predictions(mod_diamond, "lprice") %>%
  mutate(price = 2^lprice)

ggplot(diamonds2, aes(carat, price)) + 
  geom_hex(bins = 50) + 
  geom_line(data = grid, colour = "red", size = 1)

# Verify that we have removed patterns by looking at residuals:
diamonds2 <- diamonds2 %>%
  add_residuals(mod_diamond, "lresid")

ggplot(diamonds2, aes(lcarat, lresid)) +
  geom_hex(bins = 50)

# Now we can re-do our initial motivating plots: 
ggplot(diamonds2, aes(cut, lresid)) + geom_boxplot()
ggplot(diamonds2, aes(color, lresid)) + geom_boxplot()
ggplot(diamonds2, aes(clarity, lresid)) + geom_boxplot()
# A residual of -1 means that the average lprice was one unit lower than predicted by weight/carat alone

# A more complicated model: 
mod_diamond2 <- lm(lprice ~ lcarat + color + cut + clarity, data = diamonds2)

grid <- diamonds2 %>% 
  data_grid(cut, .model = mod_diamond2) %>% 
  add_predictions(mod_diamond2)
grid
ggplot(grid, aes(cut, pred)) + 
  geom_point()

diamonds2 <- diamonds2 %>% 
  add_residuals(mod_diamond2, "lresid2")

ggplot(diamonds2, aes(lcarat, lresid2)) + 
  geom_hex(bins = 50)

# Ex 24.2.3
# 1 - the stripes represent the fact that many diamonds have carats near 'nice' round numbers

diamonds2 %>% 
  filter(abs(lresid2) > 1) %>% 
  add_predictions(mod_diamond2) %>% 
  mutate(pred = round(2 ^ pred)) %>% 
  select(price, pred, carat:table, x:z) %>% 
  arrange(price)

mod_diamond2 <- lm(lprice ~ lcarat + color + cut + clarity, data = diamonds2)

diamonds2 %>% 
  add_predictions(mod_diamond2) %>%
  add_residuals(mod_diamond2) %>%
  summarise(sq_err = sqrt(mean(resid^2)),
            abs_err = mean(abs(resid)),
            p975_err = quantile(resid, 0.975),
            p025_err = quantile(resid, 0.025))

# 24.3 - number of flights per day
daily <- flights %>%
  mutate(date = make_date(year, month, day)) %>%
  group_by(date) %>%
  summarise(n = n())
daily

ggplot(daily, aes(date, n)) + 
  geom_line()

# strong dotw effect:
daily <- daily %>%
  mutate(wday = wday(date, label = TRUE))

ggplot(daily, aes(wday, n)) +
  geom_boxplot()

# Let's fit a model to this:
mod <- lm(n ~ wday, data = daily)

grid <- daily %>%
  data_grid(wday) %>%
  add_predictions(mod, "n")
ggplot(daily, aes(wday, n)) +
  geom_boxplot() +
  geom_point(data = grid, colour= "red", size = 8)

# Now computer the residuals (the remaining pattern):
daily <- daily %>%
  add_residuals(mod)

daily %>%
  ggplot(aes(date, resid)) + 
  geom_ref_line(h = 0) + 
  geom_line()

# This chart shows the deviation from the expected number of flights given the dotw trend

ggplot(daily, aes(date, resid, colour = wday)) + 
  geom_ref_line(h = 0) + 
  geom_line()
# This shows American public holidays, and shows that there are more Sat flights in the summer (holidays) and miuch fewere in the autumn. Thanks giving, Christmas 

daily %>% 
  filter(resid < -100)

daily %>% 
  ggplot(aes(date, resid)) + 
  geom_ref_line(h = 0) + 
  geom_line(colour = "grey50") + 
  geom_smooth(se = FALSE, span = 0.20) +
  scale_x_date(NULL, date_breaks = "1 month", date_labels = "%b")


daily %>% 
  filter(wday == "Sat") %>% 
  ggplot(aes(date, n)) + 
  geom_point() + 
  geom_line() +
  scale_x_date(NULL, date_breaks = "1 month", date_labels = "%b")

# Create a 'term' variable that defines school holidays:
term <- function(date) {
  cut(date, 
      breaks = ymd(20130101, 20130605, 20130825, 20140101),
      labels = c("spring", "summer", "fall") 
  )
}

daily <- daily %>% 
  mutate(term = term(date)) 

daily %>% 
  filter(wday == "Sat") %>% 
  ggplot(aes(date, n, colour = term)) +
  geom_point(alpha = 1/3) + 
  geom_line() +
  scale_x_date(NULL, date_breaks = "1 month", date_labels = "%b")

# How does this variable affect the other dotw?
daily %>% 
  ggplot(aes(wday, n, colour = term)) +
  geom_boxplot()

# The term effect seems reasonably strong - so let's fit a separate dotw effect for each term: 
mod1 <- lm(n ~ wday, data = daily)
mod2 <- lm(n ~ wday * term, data = daily)

daily %>% 
  gather_residuals(without_term = mod1, with_term = mod2) %>% 
  ggplot(aes(date, resid, colour = model)) +
  geom_line(alpha = 0.75)

# Still could be better - let's look to see what the model is doing:
grid <- daily %>% 
  data_grid(wday, term) %>% 
  add_predictions(mod2, "n")

ggplot(daily, aes(wday, n)) +
  geom_boxplot() + 
  geom_point(data = grid, colour = "red") + 
  facet_wrap(~ term)
# ... lots of outliers!

# We can improve this by using MASS:rlm() which is more robust to outliers when fitting a linear model
mod3 <- MASS::rlm(n ~ wday * term, data = daily)

daily %>% 
  add_residuals(mod3, "resid") %>% 
  ggplot(aes(date, resid)) + 
  geom_hline(yintercept = 0, size = 2, colour = "white") + 
  geom_line()

# Ex 3 - create new variable that splits Sat by term: 
daily <- daily %>%
  mutate(wday2 = 
           case_when(.$wday == "Sat" & .$term == "summer" ~ "Sat-summer",
                     .$wday == "Sat" & .$term == "fall" ~ "Sat-fall",
                     .$wday == "Sat" & .$term == "spring" ~ "Sat-spring",
                     TRUE ~ as.character(.$wday)))

mod4 <- lm(n ~ wday2 * term, data = daily)

daily %>% 
  gather_residuals(without_term = mod1, sat_term = mod4) %>% 
  ggplot(aes(date, resid, colour = model)) +
  geom_line(alpha = 0.75)

library(broom)
glance(mod4) %>%
  r.squared

glance(mod4) %>% select(r.squared, sigma, AIC, df)
glance(mod2) %>% select(r.squared, sigma, AIC, df)

# 4- new variables
# Use the other guy's definition of holidays: 
daily <- daily %>%
  mutate(wday3 = 
           case_when(
             .$date %in% lubridate::ymd(c(20130101, # new years
                                          20130121, # mlk
                                          20130218, # presidents
                                          20130527, # memorial
                                          20130704, # independence
                                          20130902, # labor
                                          20131028, # columbus
                                          20131111, # veterans
                                          20131128, # thanksgiving
                                          20131225)) ~
               "holiday",
             .$wday == "Sat" & .$term == "summer" ~ "Sat-summer",
             .$wday == "Sat" & .$ term == "fall" ~ "Sat-fall",
             .$wday == "Sat" & .$term == "spring" ~ "Sat-spring",
             TRUE ~ as.character(.$wday)))

mod5 <- lm(n ~ wday3, data = daily)

daily %>% 
  gather_residuals(without_term = mod1, lots_of_terms = mod5) %>% 
  ggplot(aes(date, resid, colour = model)) +
  geom_line(alpha = 0.75) + 
  scale_x_date(NULL, date_breaks = "1 month", date_labels = "%b")

# Not sure what this shows ... the residuals seem to be much higher for some 'holidays' (as defined by our variable) and lower for others ... 

monday_first <- function(x) {
  forcats::fct_relevel(x, levels(x)[-1])  
}
