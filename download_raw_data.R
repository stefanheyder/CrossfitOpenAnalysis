library(jsonlite)
library(tcltk)

paths <- c(
    male = "https://games.crossfit.com/competitions/api/v1/competitions/open/2019/leaderboards?country_champions=0&division=1&sort=0&scaled=0&page=",
    female = "https://games.crossfit.com/competitions/api/v1/competitions/open/2019/leaderboards?country_champions=0&division=1&sort=0&scaled=0&page="
)

for(gender in c("male", "female")) {

    path <- paths[gender]
    results <- list()
    results[[1]] <- fromJSON(txt = paste(path, 1))

    max.pages <- results[[1]]$pagination$totalPages
    print(paste("Downloading Data from ", path, "for all", gender, "atheletes. A total of ", max.pages, "pages will be downloaded"))
    pb <- txtProgressBar(min = 0, max = max.pages, style = 3)
    for (page in 2:max.pages) {
        setTxtProgressBar(pb, page)
        results[[page]] <- fromJSON(txt = paste(path, page))
    }
    close(pb)
    saveRDS(results, paste("raw_data/", format(Sys.time(), "%Y-%m-%d_%H:%M:%S"), gender, "_raw_data.Rds", sep = ""))
}
