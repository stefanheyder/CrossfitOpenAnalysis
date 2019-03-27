library(jsonlite)
library(tcltk)
library(tidyverse)

for(gender in c("male", "female")) {
    file.information <- file.info(list.files("raw_data", pattern = paste("_",gender, sep = ""), full.names = T))
    latest.raw.file <- rownames(file.information)[which.max(file.information$mtime)]

    print(paste("Reading Raw Data File", latest.raw.file))
    results <- readRDS(latest.raw.file)
    print(paste("Finished Reading", latest.raw.file))

    max.pages <- results[[1]]$pagination$totalPages
    timecaps <- c(15, 20, 10, 12, 20) * 60

    print(paste("Starting Data cleaning for", gender, "athletes"))
    pb <- txtProgressBar(min = 0, max = max.pages, style = 3)
    cleaned.results <- do.call(rbind,
        results %>% 
            lapply(function(results.of.page) {
                if (is.null(results.of.page$statusCode)) {
                    setTxtProgressBar(pb, results.of.page$pagination$currentPage)

                    competitor.names <- results.of.page$leaderboardRows$entrant$competitorName
                    competitor.ids <- results.of.page$leaderboardRows$entrant$competitorId
                    scores <- results.of.page$leaderboardRows$scores 

                    do.call(rbind, scores %>%
                        lapply(function(l) l[,c(3,7)]) %>%
                        lapply(function(score.and.scaled) {
                            score <- as.numeric(score.and.scaled$score)
                            scaled <- score.and.scaled$scaled == "1"

                            remaining.seconds <- score %% 10000
                            Repetitions <- score %/% 10000 - 1000 * !scaled
                            
                            tibble(remaining.seconds = remaining.seconds, Repetitions = Repetitions, WOD = c('19.1', '19.2', '19.3', '19.4', '19.5'), Scaled = scaled)
    }) 
                        ) %>%
                    mutate(FullName = rep(competitor.names, each = 5)) %>%
                    mutate(Athlete.Id = rep(competitor.ids, each = 5)) %>%
                    mutate(Gender = gender) %>%
                    mutate(Time = rep(timecaps, length(scores)) -  remaining.seconds) %>%
                    select(-remaining.seconds)
                } else {
                    list()
                }

})) %>% select(Athlete.Id, FullName, Gender, WOD, Scaled, Repetitions, Time)

    close(pb)
    print("Finished data cleaning")
    clean.file <- sub(".Rds", ".csv", basename(latest.raw.file))
    print(paste("Writing clean data to", clean.file))
    write_csv(cleaned.results, paste("clean_data/", clean.file))
}
