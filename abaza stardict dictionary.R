setwd("/home/agricolamz/_DATA/OneDrive1/_Work/_Handouts/2017 II Abaza expedition/Abaza seminar/2017.01.23 Abaza syllable structure/abz-rus dict")
library(rvest); library(tidyverse); library(stringr); library(httr)

alphabet <- c("А", "Б", "В", "Г", "ГВ", "ГЪ", "ГЪВ", "ГЪЬ", "ГЬ", "ГI", "ГIВ", "Д", "ДЖ", "ДЖВ", "ДЖЬ", "ДЗ", "Е",
              "Ё", "Ж", "ЖВ", "ЖЬ", "З", "И", "Й", "К", "КВ", "КЪ", "КЪВ", "КЪЬ", "КЬ", "КI", "КIВ", "КIЬ", "Л", "ЛЬ",
              "М", "Н", "О", "П", "ПI", "Р", "С", "Т", "ТЛ", "ТШ", "ТI", "У", "Ф", "Х", "ХВ", "ХЪ", "ХЪВ", "ХЬ", "ХI", "ХIВ",
              "Ц", "ЦI", "Ч", "ЧВ", "ЧI", "ЧIВ", "Ш", "ШВ", "ШI", "Щ", "Ъ", "Ы", "Ь", "Э", "Ю", "Я")

# create links to download
links <- paste0("http://www.abazinka.ru/ru/letter/", alphabet)

# download all words from the links pages
words <- c(
  sapply(links, function(x){
    source <- read_html(x)
    source %>% 
      html_nodes("td.st_aw") %>%
      html_text() %>% 
      str_replace_all(., "\r\n", "") %>% 
      str_replace_all(., "  ", "")
    }
    ))

words <- unlist(words)
words <- unname(words)
write.csv(words, "words.csv", row.names = F)
rm(words, links, alphabet) # some cleaning

# Some changes in csv file made by hand in LibreOffice
# remove acutes, asterisks and \n

# Download all meanings
words <- read.csv("words.csv")
links <- paste0("http://www.abazinka.ru/abaza/russian/", words$normalized)
meanings <- c(
  sapply(links, function(x){
    user <- GET(x, add_headers('user-agent' = 'r'))
    source <- read_html(user)
    source %>% 
      html_text() ->
      text
    source %>%
      html_nodes("td.kmj_rs") %>% 
      html_text() ->
      phrase1
    if(!identical(phrase1, character(0)))
      sapply(phrase1, function(y){
        text <<- gsub(y, paste("", y), text)})
    source %>%
      html_nodes("td.tvb_rs") %>% 
      html_text() ->
      phrase2
    if(!identical(phrase2, character(0)))
    sapply(phrase2, function(y){
      text <<- gsub(y, paste("", y), text)})
    source %>%
      html_nodes("td.kmj_as") %>% 
      html_text() ->
      phrase3
    if(!identical(phrase3, character(0)))
      sapply(phrase3, function(y){
        text <<- gsub(y, paste("", y), text)})
    return(text)
  }
  ))
words -> meanings
meanings <- unlist(meanings)
meanings <- unname(meanings)

words2$meaning <- meanings

write.table(words2, "words.csv", row.names = F, sep = "\t")
rm(words, links, source, meanings) # some cleaning

words <- read.table("words.csv", sep = "\t", stringsAsFactors = F, header = T)

# add "\n" before 1. and 1)
sapply(1:9, function(x){
  words$meaning <<- str_replace_all(words$meaning, paste0(x, "\\."), paste0("\\\\n", x, "\\."))})

sapply(1:9, function(x){
  words$meaning <<- str_replace_all(words$meaning, paste0(x, "\\)"), paste0("\\\\n", x, "\\)"))})

words$meaning <- str_replace_all(words$meaning, ";", ";\\\\n")
words$meaning <- str_replace_all(words$meaning, "\\\\n\\\\n", "\\\\n")

# remove duplicates
dict <- unique(words)

write.table(dict, "abaza-russian.tab", row.names = F, sep = "\t", col.names = F)

# That is all. Next step is stardict-editor from stardict-tools package