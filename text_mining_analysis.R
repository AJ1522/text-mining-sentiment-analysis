getwd()
install.packages("tidyverse")
install.packages("SnowballC")
install.packages("wordcloud")
install.packages("RColorBrewer")
install.packages("ggplot2")
install.packages("RCurl")
install.packages("tm")
install.packages("SentimentAnalysis")
install.packages("syuzhet")

#Load libraries 
library(tidyverse)
library(SnowballC)
library(wordcloud)
library(RColorBrewer)
library(ggplot2)
library(RCurl)
library(tm)
library(SentimentAnalysis)
library(syuzhet)

# Load your dataset
data <- read.csv("ACBR.csv", stringsAsFactors = FALSE, encoding = "UTF-8")

summary(data)


#Create a corpus from the reviews column
corpus <- Corpus(VectorSource(data$Review))


# Data Preprocessing (lowercasing, removing punctuation, stopwords, etc.)
corpus <- tm_map(corpus, content_transformer(tolower))
corpus <- tm_map(corpus, removePunctuation)
corpus <- tm_map(corpus, removeNumbers)
corpus <- tm_map(corpus, removeWords, stopwords("english"))
corpus <- tm_map(corpus, stripWhitespace)

# Apply stemming 
corpus <- tm_map(corpus, stemDocument)

#Create Term-Document Matrix (TDM) for Word Cloud
tdm <- TermDocumentMatrix(corpus)
m <- as.matrix(tdm)
word_freqs <- sort(rowSums(m), decreasing = TRUE)
word_freqs_df <- data.frame(word = names(word_freqs), freq = word_freqs)

#Generate Word Cloud
wordcloud(words = word_freqs_df$word, freq = word_freqs_df$freq, min.freq = 1,
          max.words = 100, random.order = FALSE, rot.per = 0.35, 
          colors = brewer.pal(8, "Dark2"))

# Sentiment Analysis using NRC Lexicon
sentiment_scores <- get_nrc_sentiment(as.character(data$Review))

# Calculate the mean sentiment scores and print the results
mean_sentiments <- colSums(sentiment_scores) / nrow(sentiment_scores)
print(mean_sentiments)

# Visualize Sentiment Analysis (Emotions)
sentiment_summary <- as.data.frame(colSums(sentiment_scores))
sentiment_summary <- rownames_to_column(sentiment_summary, "emotion")
colnames(sentiment_summary) <- c("emotion", "count")


# Plot the sentiment/emotion distribution
ggplot(sentiment_summary, aes(x = emotion, y = count, fill = emotion)) +
  geom_bar(stat = "identity") +
  theme_minimal() +
  theme(legend.position = "none", panel.grid.major = element_blank()) +
  labs(x = "Emotion", y = "Total Count") +
  ggtitle("Sentiment Analysis of Reviews") +
  theme(plot.title = element_text(hjust = 0.5))

# Sentiment Polarity Analysis
sentiment_polarity <- analyzeSentiment(data$Review)

summary(sentiment_polarity$SentimentGI)

# Visualize the polarity distribution
ggplot(sentiment_polarity, aes(x = SentimentGI)) +
  geom_histogram(binwidth = 0.1, fill = "blue", color = "black") +
  labs(x = "Sentiment Polarity", y = "Frequency") +
  ggtitle("Sentiment Polarity Distribution")

# Export sentiment scores to CSV 
write.csv(sentiment_scores, "sentiment_analysis_results.csv")
