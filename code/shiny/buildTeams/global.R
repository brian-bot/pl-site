source("../../leagueBootstrap2025.R")
require(mlbstats)
require(plyr)
require(dplyr)

today <- Sys.Date()
currentPeriod <- which(sapply(periods, function(x){ today >= x$startDate & today <= x$endDate}))
seasonPeriods <- which(sapply(periods, function(x){ today >= x$startDate }))

## try using team roster api
getAllRosters <- function(){
  tts <- mlbstatsRestGET("teams?sportId=1")$team
  rrs <- lapply(as.list(1:length(tts)), function(i){
    tr <- mlbstatsRestGET(paste0("teams/", tts[[i]]$id, "/roster?rosterType=fullRoster&season=", format(today,'%Y')))$roster
    rr <- lapply(tr, function(x){
      return(data.frame(id = x$person$id, fullName = x$person$fullName, stringsAsFactors = FALSE))
    })
    rr_return <- bind_rows(rr)
    rr_return$teamName <- tts[[i]]$name
    return(rr_return)
  })
  return(bind_rows(rrs))
}
allMlbPlayers <- getAllRosters()

allNames <- data.frame(fullName = allMlbPlayers$fullName,
                       withId = paste0(allMlbPlayers$fullName, " (", allMlbPlayers$id, ")"),
                       withTeam = paste0(allMlbPlayers$fullName, " (", allMlbPlayers$teamName, ")"),
                       stringsAsFactors = FALSE)
rownames(allNames) <- NULL
allNames <- allNames[ !duplicated(allNames$withId), ]
rownames(allNames) <- allNames$withId
allNames <- allNames[ order(allNames$withId), ]
