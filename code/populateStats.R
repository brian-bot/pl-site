require(mlbstats)

## SOURCE IN THE LEAGUE BOOTSTRAP CODE
source("code/leagueBootstrap2021.R")

## CHECK TO SEE IF data/hidden EXISTS - IF NOT, CREATE IT
if( !dir.exists("data/hidden") ){
  dir.create("data/hidden")
}

firstDate <- as.Date("2021-04-01")
today <- Sys.Date()
lastDate <- today-1

## PULL ALL OF THE DATA
pullData <- lapply(firstDate:lastDate, function(d){
  d <- as.Date(d, origin="1970-01-01")
  dateData <- getMlbDate(d)
  if( is.null(dateData) ){
    return(NULL)
  }else if( nrow(dateData$batters) == 0 & nrow(dateData$pitchers) == 0){
    return(NULL)
  } else{
    return(dateData)
  }
})
names(pullData) <- as.character(as.Date(firstDate:lastDate, origin="1970-01-01"))

## ORGANIZE ALL OF THE STATS BY SEASON PERIODS
currentPeriod <- which(sapply(periods, function(x){ (today-1) >= x$startDate & (today-1) <= x$endDate}))
finishedPeriods <- which(sapply(periods, function(x){ today > x$endDate}))
seasonPeriods <- which(sapply(periods, function(x){ (today-1) >= x$startDate }))

source("code/getRangeMlb.R")
allStats <- lapply(as.list(seasonPeriods), function(y){
  if( length(currentPeriod) == 1 ){
    if( y == currentPeriod ){
      perData <- getRange(periods[[y]]$startDate, today)
    } else{
      perData <- getRange(periods[[y]]$startDate, periods[[y]]$endDate)
    }
  } else{
    perData <- getRange(periods[[y]]$startDate, periods[[y]]$endDate)
  }
  rownames(perData$batters) <- paste0(perData$batters$fullName, " (", perData$batters$id, ")")
  rownames(perData$pitchers) <- paste0(perData$pitchers$fullName, " (", perData$pitchers$id, ")")
  return(perData)
})
save(allStats, file="data/hidden/allStats.RData")

if(firstDate < lastDate){
  rangeData <- getRange(firstDate, lastDate)
  rownames(rangeData$batters) <- paste0(rangeData$batters$fullName, " (", rangeData$batters$id, ")")
  rownames(rangeData$pitchers) <- paste0(rangeData$pitchers$fullName, " (", rangeData$pitchers$id, ")")
}
save(rangeData, file="data/hidden/rangeData.RData")
