#####
## GET RANGE OF MLB DATA
#####
getRange <- function(startDate, endDate){
  require(plyr)
  require(dplyr)
  
  d0 <- as.Date(startDate)
  d1 <- as.Date(endDate)
  these <- d0:d1
  class(these) <- "Date"
  
  ## BATTERS
  b <- lapply(as.list(these), function(i){
    tmp <- pullData[[as.character(i)]]$batters[, c("id", "fullName", "hits", "baseOnBalls", "intentionalWalks", "hitByPitch", "runs", "rbi", "homeRuns", "stolenBases")]
    for(ii in c("id", "hits", "baseOnBalls", "intentionalWalks", "hitByPitch", "runs", "rbi", "homeRuns", "stolenBases")){
      tmp[[ii]] <- as.numeric(tmp[[ii]])
    }
    return(tmp)
  })
  b[sapply(b, is.null)] <- NULL
  b <- bind_rows(b)
  # b <- do.call(rbind, b)
  bb <- ddply(b, .(fullName, id), summarize,
              hitsbb = sum(hits, na.rm = TRUE) + sum(baseOnBalls, na.rm = TRUE) + sum(hitByPitch, na.rm = TRUE),
              r = sum(runs, na.rm = TRUE),
              rbi = sum(rbi, na.rm = TRUE),
              hr = sum(homeRuns, na.rm = TRUE),
              sb = sum(stolenBases, na.rm = TRUE))
  
  ## PITCHERS
  p <- lapply(as.list(these), function(i){
    a <- pullData[[as.character(i)]]$pitchers[, c("id", "note", "fullName", "battersFaced", "earnedRuns", "inningsPitched", "hits", "baseOnBalls", "strikeOuts")]
    ## FIX INNINGS PITCHED
    tmp <- strsplit(as.character(a$inningsPitched), ".", fixed=T)
    tmp <- sapply(tmp, function(x){
      if(length(x)==1){
        return(as.numeric(x))
      } else{
        return(as.numeric(x[1]) + as.numeric(x[2])/3)
      }
    })
    a$inningsPitched <- tmp
    for(ii in c("id", "battersFaced", "earnedRuns", "inningsPitched", "hits", "baseOnBalls", "strikeOuts")){
      a[[ii]] <- as.numeric(a[[ii]])
    }
    return(a)
  })
  p[sapply(p, is.null)] <- NULL
  p <- bind_rows(p)
  # p <- do.call(rbind, p)
  p$win <- grepl("(W,", p$note, fixed=TRUE)
  p$save <- grepl("(S,", p$note, fixed=TRUE)
  pp <- ddply(p, .(fullName, id), summarize,
              # team = team_abbreviation[ length(team_abbreviation) ],
              g = sum(battersFaced > 0, na.rm = TRUE),
              er = sum(earnedRuns, na.rm = TRUE),
              ip = sum(inningsPitched, na.rm = TRUE),
              hitsbb = sum(hits, na.rm = TRUE) + sum(baseOnBalls, na.rm = TRUE),
              so = sum(strikeOuts, na.rm = TRUE),
              w = sum(win, na.rm = TRUE),
              sv = sum(save, na.rm = TRUE))
  pp$era <- pp$er / pp$ip * 9
  pp$whip <- pp$hitsbb / pp$ip
  
  return(list(batters=bb, pitchers=pp))
}

