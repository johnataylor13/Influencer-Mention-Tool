
#Libraries
library(dplyr)
library(RCurl)
library(httr)
library(twitteR)
library(stringr)
library(sparklyr) 
library(devtools)
library(aws.s3)
library(openxlsx)
library(xlsx)
library(stringi)
library(stringr)
setwd("/Users/johntaylor/Desktop")


#emails
emails <- read.xlsx("/Users/johntaylor/Box Sync/Analytics/NFL/Influencer Mention Tool/Data/NFL Emails.xlsx")
#Reading in an examples
email_text <- emails$Text[1]
example_name <- "Jerry Jones"
#Cleaning example text
email_text <- str_replace(gsub("\\s+", " ", str_trim(email_text)), "B", "b")
#Check if email text contains example name
emails$name_check <- lapply(emails$Text, function(x) grepl(example_name, x))
#Extract quotes
quotes <- stri_extract_all_regex(email_text, '(?<=“).*?(?=”)')
quotes <- unlist(quotes)
quotes <- as.data.frame(quotes)




#Twitter


#To be converted to box
search_words <- read.csv("/Users/johntaylor/Box Sync/Analytics/NFL/Influencer Mention Tool/Data/NFL Elite Terms.csv")
search_words <- as.list(search_words$Terms)
accounts <- read.csv("/Users/johntaylor/Box Sync/Analytics/NFL/Influencer Mention Tool/Data/NFL Elite Audience.csv")
accounts <- as.list(accounts$Handle)

#Pulling in their tweets
tweet_amount <- 1000
twitterverse <- twListToDF(userTimeline(accounts[1], n=1))
twitterverse <- twitterverse[0,]
for (j in 1:length(accounts)) {
    twitterverse_loop <- twListToDF(userTimeline(accounts[j], n=tweet_amount, includeRts = T, excludeReplies = F))
    twitterverse <- rbind(twitterverse, twitterverse_loop)
}
twitterverse$wordflag <- lapply(twitterverse$text, function(x) grepl(paste(search_words, collapse = "|"), x, ignore.case = T))
twitterverse$wordflag <- unlist(twitterverse$wordflag)
twitterverse$word_count <- ifelse(twitterverse$wordflag == T, 1, 0)
write.csv(twitterverse, "twitterverse.csv")
