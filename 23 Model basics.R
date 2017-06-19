# 23 - Model basics

library(tidyverse)
library(modelr)
options(na.action = na.warn)

# A simple model
# Simulated data: 
ggplot(sim1, aes(x, y)) +
  geom_point()

# All the code from Hadley's discussion: 
sim1_mod <- lm(y ~ x, data = sim1)
coef(sim1_mod)

models <- tibble(
  a1 = runif(250, -20, 40),
  a2 = runif(250, -5, 5)
)

ggplot(sim1, aes(x, y)) + 
  geom_abline(aes(intercept = a1, slope = a2), data = models, alpha = 1/4) +
  geom_point() 

model1 <- function(a, data) {
  a[1] + data$x * a[2]
}
model1(c(7, 1.5), sim1)

measure_distance <- function(mod, data) {
  diff <- data$y - model1(mod, data)
  sqrt(mean(diff ^ 2))
}
measure_distance(c(7, 1.5), sim1)

sim1_dist <- function(a1, a2) {
  measure_distance(c(a1, a2), sim1)
}

models <- models %>% 
  mutate(dist = purrr::map2_dbl(a1, a2, sim1_dist))
models


ggplot(sim1, aes(x, y)) + 
  geom_point(size = 2, colour = "grey30") + 
  geom_abline(
    aes(intercept = a1, slope = a2, colour = -dist), 
    data = filter(models, rank(dist) <= 10)
  )


ggplot(models, aes(a1, a2)) +
  geom_point(data = filter(models, rank(dist) <= 10), size = 4, colour = "red") +
  geom_point(aes(colour = -dist))

grid <- expand.grid(
  a1 = seq(-5, 20, length = 25),
  a2 = seq(1, 3, length = 25)
) %>% 
  mutate(dist = purrr::map2_dbl(a1, a2, sim1_dist))

grid %>% 
  ggplot(aes(a1, a2)) +
  geom_point(data = filter(grid, rank(dist) <= 10), size = 4, colour = "red") +
  geom_point(aes(colour = -dist)) 


ggplot(sim1, aes(x, y)) + 
  geom_point(size = 2, colour = "grey30") + 
  geom_abline(
    aes(intercept = a1, slope = a2, colour = -dist), 
    data = filter(grid, rank(dist) <= 10)
  )

best <- optim(c(0, 0), measure_distance, data = sim1)
best$par
#> [1] 4.22 2.05

ggplot(sim1, aes(x, y)) + 
  geom_point(size = 2, colour = "grey30") + 
  geom_abline(intercept = best$par[1], slope = best$par[2])



# Let's fit a linear model (minimise the least square distances between model and data)

sim1_mod <- lm(y ~ x, data = sim1)
coef(sim1_mod)


# Ex 23.2.1
# 1

sim1a <- tibble(
  x = rep(1:10, each = 3),
  y = x * 1.5 + 6 + rt(length(x), df = 2)
)
sim1a_mod <- lm(y ~ x, data = sim1)
coef(sim1a_mod)
sim1a_mod %>% 
  ggplot(aes(x, y)) + 
  geom_point()

# Our approach here is to look at predictions, rather than focusing on the coefficients

 # Generate evenly-spaced grid of values covering space where data lies: 
grid <- sim1 %>% 
  data_grid(x)
grid
# this finds every combination of all x values from every argument

# Now add predictions from the model: 
grid <- grid %>% 
  add_predictions(sim1_mod) 
grid
# Now visualise: 
ggplot(sim1, aes(x)) +
  geom_point(aes(y = y)) +
  geom_line(aes(y = pred), data = grid, colour = "red", size = 1)
# Does the same as geom_abline() but this works for any type of model

# Residuals
# Residuals tell you what the model has missed - the difference between the predicted value and the actual value
sim1 <- sim1 %>% 
  add_residuals(sim1_mod)
sim1

ggplot(sim1, aes(resid)) + 
  geom_freqpoly(binwidth = 0.5)
# Average of residuals is obviously always zero

# Plot residuals - if they look like noise, then model has done a good job of capturing patterns in the model: 
ggplot(sim1, aes(x, resid)) + 
  geom_ref_line(h = 0) +
  geom_point()

# Ex 23.3.3
# 1 - loess - local polynomial regression
sim1_loess <- loess(y ~ x, data = sim1)
grid_loess <- sim1 %>%
  add_predictions(sim1_loess)
sim1 <- sim1 %>%
  add_predictions(sim1_loess, var = "pred_loess") %>%
  add_residuals(sim1_loess, var = "resid_loess")

plot_sim1_loess <- ggplot(sim1, aes(x, y)) +
  geom_point() + 
  geom_line(aes(x, y = pred), data = grid_loess, colour = "red")

# This is the same as plotting geom_smooth()
plot_sim1_loess +
  geom_smooth(colour = "blue", se = FALSE, alpha = 0.20)

# other functions:
gather_predictions() # adds cols .model and .pred, and repeats inputs rows for each model
spread_predictions() # adds one col for each model

# Categorical data
mod2 <- lm(y ~ x, data = sim2)
sim2

grid <- sim2 %>%
  data_grid(x) %>%
  add_predictions(mod2)
grid
# this calculates the mean value for each category:
ggplot(sim2, aes(x)) +
  geom_point(aes(y = y)) +
  geom_point(data = grid, aes(y = pred), colour = "red")

# Combination of continuous and categorical predictors: 
sim3 # has both - x1 (cts - although only has discrete values?!) and x2 (letters)
str(sim3)
ggplot(sim3, aes(x1, y)) +
  geom_point(aes(colour = x2))

# Two possible models: 
mod1 <- lm(y ~ x1 + x2, data = sim3) # treats x1 and x2 as independent variables
mod2 <- lm(y ~ x1 * x2, data = sim3) # interaction of the variables - effectively a 'crossed term' - translates as y = a_0 + a_1 * x1 + a_2 * x2 + a_12 * x1 * x2

# Now we make predictions:
grid <- sim3 %>% 
  data_grid(x1, x2) %>% 
  gather_predictions(mod1, mod2)
grid

ggplot(sim3, aes(x1, y, colour = x2)) + 
  geom_point() + 
  geom_line(data = grid, aes(y = pred)) + 
  facet_wrap(~ model)

sim3 <- sim3 %>% 
  gather_residuals(mod1, mod2)

ggplot(sim3, aes(x1, resid, colour = x2)) + 
  geom_point() + 
  facet_grid(x2 ~ model)

model_matrix(sim3, y ~ x1 + x2)
model_matrix(sim3, y ~ x1 * x2)
View(sim3)
# Residuals have more patterns in mod1, at least for b (by eye)

mod1 <- lm(y ~ x1 + x2, data = sim4)
mod2 <- lm(y ~ x1 * x2, data = sim4)

grid <- sim4 %>% 
  data_grid(
    x1 = seq_range(x1, 5), # seq_range will give five values between the max and min (equally spaced)
    x2 = seq_range(x2, 5) 
  ) %>% 
  gather_predictions(mod1, mod2)
grid

# Examples:
seq_range(c(0.0123, 0.923), n = 5)
seq_range(c(0.0123, 0.923), n = 5, pretty = TRUE) # gives 'nice' sequences to human eye
seq_range(c(0.0123, 0.923), n = 5, trim = 0.1) # trims 10% off each end

ggplot(grid, aes(x1, x2)) + 
  geom_tile(aes(fill = pred)) +
  facet_wrap(~ model)

ggplot(grid, aes(x1, pred, colour = x2, group = x2)) + 
  geom_line() +
  facet_wrap(~ model)
ggplot(grid, aes(x2, pred, colour = x1, group = x1)) + 
  geom_line() +
  facet_wrap(~ model)

# Even with two variables, it's hard to come up with good visualisations, but this is OK - you shouldn't expect it to be easy to understand interactions of variables!

# MODEL SPECIFICATION IS ODD!  THE SYMBOLS + AND * IN THE SPECIFICATION MEAN SOMETHING ELSE!
# If model involves + * ^ or -, you need to put this inside I(), so R doesn't treat it like part of the model specification - eg 
# y ~ x + I(x^2) is translated to y = a_1 + a_2*x + a_3*x^2
# If you specify y ~ x^2 + x, R will compute y ~ x*x + x, and x*x is the interaction of x with itself, i.e. x

# Check with model_matrix() to see what equation lm() is trying to fit

df <- tribble(
  ~y, ~x,
  1,1,
  2,2,
  3,3
)
model_matrix(df, y ~ x^2 + x)
model_matrix(df, y ~ I(x^2) + x)

# Polynomial models
model_matrix(df, y ~ poly(x, 2))

# there is a problem with such models - outside of the data range, polynomials rapidly shoot off to +ve or -ve inf.  One safer alternative is to use the natural spline, splines::ns()

library(splines)

model_matrix(df, y ~ ns(x, 2))

# Rows with missing values get dropped
df <- tribble(
  ~x, ~y,
  1, 2.2,
  2, NA, 
  3, 3.5, 
  NA, 10
)

mod <- lm(y ~ x, data = df)
# Suppress warning: 
mod <- lm(y ~ x, data = df, na.action = na.exclude)
# Number of observation: (!)
nobs(mod)

# Other models - http://r4ds.had.co.nz/model-basics.html#other-model-families
# linear models assume that the residuals have a normal distribution

# These work in a similar method in terms of the actual functions etc

