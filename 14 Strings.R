
library(tidyverse)
library(stringr)

# Quotes
string1 <- 'Ce-ci n\'est pas un string'
string1b <- "Ce-ci n'est pas un string"
string2 <- 'To use "quotes" you need single quotes'

double_quote <- "\"" 
single_quote <- '\'' # or "'"

# The printed representation of a string is not the same as the string itself - use WriteLines to print the string itself
writeLines(string1)
writeLines(string1b)
writeLines(string2)
writeLines(double_quote)
double_quote

# The following have their usual Linux-type meaning; type ?'"' to get a full list of special chars
newline <- "\n"
tab <- "\t"
writeLines(newline)
writeLines(str_c("sdfasd", tab, "sdafdsaf"))

str_length("dfsadf") # 
str_c("asdf","ghgh") # concatenate

#str_c is vectorised and recycles short vectors
str_c("prefix-", c("a", "b", "c"), "-suffix")

# zero length objects are dropped - useful when used with 'if'
name <- "Hadley"
time_of_day <- "morning"
birthday <- FALSE

str_c(
  "Good ", time_of_day, " ", name,
  if (birthday) " and HAPPY BIRTHDAY",
  "."
)

# collapse vector -> string
str_c(c("x", "y", "z"), collapse = ",")

# substrings
x <- c("Apple", "Banana", "Pear")
str_sub(x, 1, 3)
str_sub(x, -3, -1)
str_sub(x, 1, 1) <- str_to_lower(str_sub(x, 1, 1))

# there is a locale setting, which affects capitalisation and sorting
x <- c("apple", "eggplant", "banana")
str_sort(x, locale = "en")  # English
str_sort(x, locale = "haw") # Hawaiian

# Standard R equivalent
paste(sep="-", "sdfas","asfa") # equiv to str_c(sep="-", "sdfas","asfa")
paste0("sdfas","asfa") # equiv to str_c("sdfas","asfa")

# Ex 14.2.5.3 - cut out middle of string (or the one to the left for even)
position <- str_length(string1) %/% 2
str_sub(string1, start = position, position + 1)

para <- "The locale is specified as a ISO 639 language code, which is a two or three letter abbreviation. If you don’t already know the code for your language, Wikipedia has a good list. If you leave the locale blank, it will use the current locale, as provided by your operating system."
writeLines(str_wrap(para, width = 15, indent = 12, exdent = 10))


# 14.3 Regexes
x <- c("apple", "banana", "pear")
str_view(x, "an")


# . matches any character
str_view(x, ".a")

# to match a dot, we need a \\
dot <- "\\."
writeLines(dot)

str_view(c("abc", "a.c", "bef"), "a\\.c")

# to match a \, you need \\\\
# escape the \ (add another) to create a literal \.  Then you need the regular expression \\, and to create that you need another string, which has to have each slash doubled:
x <- "a\\b"
writeLines(x)
str_view(x,"\\\\")

# Things become clearer if we write the regex as a separate string: 
y <- "\\\\" 
writeLines(y) # should give \\ - this then matches the double slash in x
str_view(x,y)

# Ex 14.3.1.1
# 1 - \ would escape the next character in the first string
# \\ gives you \ in the regex, which escapes then next char in the regex
# \\\ first two \ give a literal backslash in the regex, the third will escape the next char. So in the regex, this will escape some escaped character

# 2 Match the sequence "'\
x <- "\"\'\\"
writeLines(x)

y <- "\"\'\\\\"
writeLines(y)
str_view(x,y)

# 3 \..\..\.. first attempt at answering question (wrong - it matches that exact sequence of characters)
x <- "\\..\\..\\.."
y <- "\\\\\\.\\.\\\\\\.\\.\\\\\\.\\."
writeLines(y)
str_view(x,y)

# 3 the regex \..\..\.. will match a dot, then any char, a dot, any char, dot, char
x <- ".s.h.d"
y <- "\\..\\..\\.."
writeLines(y)
str_view(x,y)

# 14.3.2 anchors

# ^ match start of string
# $ match end of string

x <- c("apple", "banana", "pear")
# Find an 'a' at the start of a string: 
str_view(x, "^a")
# Find an 'a' at the end of a string:
str_view(x, "a$")

# Mnemonic to remember which way round: if you start with power ^ you end up with money $

x <- c("apple pie", "apple", "apple cake")
str_view(x, "apple")
str_view(x, "^apple$")

# Ex 14.3.2.1
# 1 - match the literatl string "$^$"
x <- "$^$"
writeLines(x)
# Need regex \$\^\$
# and hence string:
y <- "\\$\\^\\$"
writeLines(y)
str_view(x,y)

# 2 
w <- stringr::words

m <- "^y"
str_view(w,m,match = TRUE)

m <- "x$"
str_view(w,m,match = TRUE)

m <- "^...$"
str_view(w,m,match = TRUE)

m <- "......."
str_view(w,m,match = TRUE)

# 14.3.3 character classes and alternatives
# \d matches any digit
# \s whitespace (tab, space, newline)
# [abc] a, b or c
#  [^abc] anything other than a, b, c

# need to double escape the \ - e.g. \\d as a string will give the RE \d

# alternation" abc|def matches abc or def
str_view(c("grey", "gray"), "gr(e|a)y")

# Ex 14.3.3.1
# 1
# Need the regex: ^[aeiou], hence the string \^\[aeiou\]

m <- "^[aeiou]"
writeLines(m)
str_view(w,m,match=TRUE)

# 2 only contain consonants: 
m <- "^[^aeiou]+$"
writeLines(m)
str_view(w,m,match=TRUE)
str_view(w,"^[^aeiou]+$",match=TRUE)

# 3 i before e except after c
m <- "(cei|[^c]ie)"
str_view(w,m,match=TRUE)
# find words that break this:
m <- "(cie|[^c]ei)"
str_view(w,m,match=TRUE)
# Rule doesn't work!

# 4 - find words without a qu
m <- "q[^u]"
str_view(w,m,match=TRUE)

# 5
# ou instead of o
# ae and oe instead of a and o
# ends in ise not ize


engb <- "ou|ise$|ae|oe|yse$"
str_view(w,engb,match=TRUE)
#???
enus <- "ize$|yze$"
str_view(w,enus,match=TRUE)


# repetition
# ? = 0 or 1
# + = 1 or more
# * = 0 or more

# colou?r matches either UK or US spellings
# {n} = n occurrences exactly
# {n,} = n or more occurrences
# {,m} = at most m occurrences
# {n,m} = between n and m occurrences

# matches are 'greedy' -i.e. matches longest string possible; to make them lazy, put ? at the end

# Ex 14.3.4.1
# 1 equivs:
# ? = {0,1} or {,1}
# + = {1,}
# * = {0,}

# regex ^.*$ matches any string
# "\\{.+\\}" this is a string describing regex \{.+\}, which matches strings of at least 1 character within curly brackets
# \d{4}-\d{2}-\d{2} is a regex matching numbers like: xxxx-xx-xx (eg dates yyyy-mm-dd)
# "\\\\{4}" is a string matching four slashes!
m <- "\\\\{4}"
writeLines(m)

# 7 all words beginning with 3 consonants
# ^[aeiou]{3}
m <- "^[^aeiou]{3}"
writeLines(m)
str_view(w,m,match=TRUE)

# Three or more vowels in a row
m <- "[aeiou]{3,}"
writeLines(m)
str_view(w,m,match=TRUE)

# Two or more vowel consonant pairs in a row
m <- "([aeiou][^aeiou]){2,}"
writeLines(m)
str_view(w,m,match=TRUE)

