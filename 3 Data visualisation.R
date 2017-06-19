# R for Data Science – Notes

# 3. Data visualisation
# 3.2 First steps

# Load tidyverse (compilation of useful packages) by typing (needs to be done every session)

library(tidyverse)

# plot a graph - always put the + at the end of the line

ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy))
# first command sets up a blank coordinate system
# second command makes the points


# Template for graphing
ggplot(data = <DATA>) + 
  <GEOM_FUNCTION>(mapping = aes(<MAPPINGS>))

 # Finding number of rows and cols:
 nrow(mtcars)
 ncol(mtcars)

# Making coloured points - map a variable to an 'aesthetic'
# 'colour' spelling also works
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy, color = class))

# other aesthetics include 'alpha' and 'shape' - e.g.:
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy, shape = class))

 # ggplot2 takes care of most basic stuff, but you can also manually set a colour:
 ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy), color = "blue")




# 3.5 Facets
# These are effectively subplots within a big plot (variable should be discrete)
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy)) + 
  facet_wrap(~ class, nrow = 2)

  # to facet the plot using two variables, do this:
  ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy)) + 
  facet_grid(drv ~ cyl)

 # 3.6 Geometric objects
 # left
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy))

# right
ggplot(data = mpg) + 
  geom_smooth(mapping = aes(x = displ, y = hwy))

 # More ggplot2 tips on the cheat sheet! https://www.rstudio.com/resources/cheatsheets/


# Can add multiple geoms in the same plot:
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy)) +
  geom_smooth(mapping = aes(x = displ, y = hwy))


# Same, but more concise: 
ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) + 
  geom_point() + 
  geom_smooth()

# Ex 3.6.1
# 1 geom_line, geom_boxplot, geom_histogram, geom_area
# 3 se turns shared confidence intervals on/off
# 6 

ggplot(data = mpg, mapping = aes(x = displ, y = hwy, group = drv, colour = drv)) + 
  geom_point() + 
  geom_smooth(se = FALSE)


# graph 1:
ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) + 
  geom_point() + 
  geom_smooth(se = FALSE)

# graph 2: 
ggplot(data = mpg, mapping = aes(x = displ, y = hwy, group = drv)) + 
  geom_point() + 
  geom_smooth(se = FALSE)

# graph 3:
ggplot(data = mpg, mapping = aes(x = displ, y = hwy, group = drv, colour = drv)) + 
  geom_point() + 
  geom_smooth(se = FALSE)

# graph 4
ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) + 
  geom_point(mapping = aes(group = drv, colour = drv)) + 
  geom_smooth(se = FALSE)

# graph 5
ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) + 
  geom_point(mapping = aes(group = drv, colour = drv)) + 
  geom_smooth(se = FALSE, mapping = aes(linetype = drv))

# graph 6
ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) + 
  geom_point(colour = "white", size = 4.5, mapping = aes(group = drv, colour = drv), show.legend = TRUE) +
  geom_point(size = 2, mapping = aes(group = drv, colour = drv), show.legend = TRUE)

# layers are added sequentially; show.legend = TRUE puts additional layers on the legend, which doesn't automatically happen


# 3.7
# Bar charts - the following chart just gives the count of each value of x
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut))

# Some charts plot the data, others calculate some aggregate value:
# - bar charts, histograms etc -> bins data, plots the bin freq
# - smoothers fit a model
# - boxplot plots a summary of the data
# The algorithm used to do this is called a 'stat'

# Every geom has a default stat, and every stat has a default geom
# The following are interchangeable: 
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut))

ggplot(data = diamonds) + 
  stat_count(mapping = aes(x = cut))

# Coloured bar chart
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, fill = cut))

# Stacked bar chart - just set fill to be a different colour
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, fill = clarity))

  # Stacked proportion
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, fill = clarity), position = "fill")

# Side by side bars
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, fill = clarity), position = "dodge")

# Can add jitter to scatter plots to reveal structure in data on large scales (makes it less accurate on small lengthscales)

# overplotting - the following doesn't give any indication of how many points there are:
ggplot(data = mpg, mapping = aes(x = cty, y = hwy)) + 
  geom_point()
# but this gives scaled points:
ggplot(data = mpg, mapping = aes(x = cty, y = hwy)) + 
  geom_count()
# and this gives jittered points:
ggplot(data = mpg, mapping = aes(x = cty, y = hwy)) + 
  geom_jitter()


# boxplots
ggplot(data = mpg, mapping = aes(x = class, y = hwy)) + 
  geom_boxplot() +
  coord_flip()

# You can assign a chart to a variable and then call it later
bar <- ggplot(data = diamonds) + 
  geom_bar(
    mapping = aes(x = cut, fill = cut), 
    show.legend = FALSE,
    width = 1
  ) + 
  theme(aspect.ratio = 1) +
  labs(x = NULL, y = NULL)

bar + coord_flip()
bar + coord_polar()

# Can make pie charts - but I'm not quite sure what this one is showing!
d <- ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, fill = clarity), position = "fill")

d + coord_polar(theta = "clarity")

# coord_fixed - fixed aspect ratio

# geom_abline - reference line

# Grammar of charts:
ggplot(data = <DATA>) + 
  <GEOM_FUNCTION>(
     mapping = aes(<MAPPINGS>),
     stat = <STAT>, 
     position = <POSITION>
  ) +
  <COORDINATE_FUNCTION> +
  <FACET_FUNCTION>