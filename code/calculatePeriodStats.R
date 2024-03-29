
## RELIES UPON SOURCING OF code/populateStats.R FOR SUCCESSFUL EXECUTION

## NOW THIS IS WHERE WE START TO PULL EVERYTHING TOGETHER WITH ROSTERS
allRosters <- lapply(as.list(names(seasonPeriods)), function(y){
  tr <- lapply(as.list(allTeams), function(x){
    a <- read.delim(file.path("data", "penguinRosters", y, paste(gsub(" ", "", tolower(x), fixed=T), ".tsv", sep="")), as.is=T)
    # rownames(a) <- a$withId
    
    if(nrow(allStats[[y]]$batters)==0 & nrow(allStats[[y]]$pitchers)==0){
      anyStats <- FALSE
    } else{
      anyStats <- TRUE
    }
    
    ## BATTER STATS
    batCols <- c("players", "position", "hitsbb", "r", "rbi", "hr", "sb")
    bs <- a[a$position %in% posMap[batMask], ]
    rownames(bs) <- bs$withId
    bs <- merge(bs, allStats[[y]]$batters, by='row.names', all.x=T, all.y=F)
    bs <- bs[, intersect(batCols, names(bs))]
    bs$position <- factor(bs$position, levels=posMap[batMask])
    bs <- bs[order(bs$position), ]
    
    ## PTICHER STATS
    pitchCols <- c("players", "position", "g", "ip", "er", "era", "hitsbb", "whip", "so", "w", "sv")
    ps <- a[a$position %in% posMap[!batMask], ]
    rownames(ps) <- ps$withId
    ps <- merge(ps, allStats[[y]]$pitchers, by='row.names', all.x=T, all.y=F)
    ps <- ps[, intersect(pitchCols, names(ps))]
    ps$position <- factor(ps$position, levels=posMap[!batMask])
    ps <- ps[order(ps$position), ]
    
    return(list(battingStats=bs, pitchingStats=ps, anyStats=anyStats))
  })
  names(tr) <- allTeams
  tr
})
names(allRosters) <- names(seasonPeriods)


## PRE-COMPUTE ALL STATS FOR ALL seasonPeriods
leagueBatters <- lapply(allRosters, function(y){
  lb <- lapply(y, function(x){
    if(!x$anyStats){
      cs <- rep(0, 5)
      names(cs) <- c("r", "hitsbb", "hr", "rbi", "sb")
      return(cs)
    } else{
      tmp <- x$battingStats[ !grepl("BENCH", x$battingStats$position), c("r", "hitsbb", "hr", "rbi", "sb")]
      cs <- colSums(tmp, na.rm=TRUE)
      return(cs)
    }
  })
  do.call(rbind, lb)
})
leaguePitchers <- lapply(allRosters, function(y){
  lp <- lapply(y, function(x){
    if(!x$anyStats){
      cs <- rep(0, 5)
      names(cs) <- c("w", "sv", "so", "era", "whip")
      return(cs)
    } else{
      tmp <- x$pitchingStats[ !grepl("BENCH", x$pitchingStats$position), c("ip", "er", "so", "w", "sv", "hitsbb")]
      cs <- colSums(tmp, na.rm=TRUE)
      cs["era"] <- cs["er"] / cs["ip"] * 9
      cs["whip"] <- cs["hitsbb"] / cs["ip"]
      return(cs[c("w", "sv", "so", "era", "whip")])
    }
  })
  do.call(rbind, lp)
})


leagueStats <- lapply(as.list(names(seasonPeriods)), function(y){
  tmp <- as.data.frame(cbind(leagueBatters[[y]], leaguePitchers[[y]]))
  tmpNames <- names(tmp)
  
  rankStats <- tmp
  rankStats$era <- -1*rankStats$era
  rankStats$whip <- -1*rankStats$whip
  pts <- rank(rankStats$hitsbb) + rank(rankStats$r) + rank(rankStats$rbi) + rank(rankStats$hr) + rank(rankStats$sb) + rank(rankStats$era) + rank(rankStats$so) + rank(rankStats$w) + rank(rankStats$sv) + rank(rankStats$whip)
  
  tmp$team <- rownames(tmp)
  tmp$points <- pts
  tmp[, c("team", "points", tmpNames)]
})
names(leagueStats) <- paste("period", seasonPeriods, sep="")

if(length(finishedPeriods) > 0){
  wl <- lapply(as.list(names(finishedPeriods)), function(y){
    tmp <- leagueStats[[y]]
    pts <- tmp$points
    wlt <- data.frame(w=rep(0, 10), l=rep(0, 10), t=rep(0, 10))
    rownames(wlt) <- rownames(tmp)
    for(i in 1:5){
      mu <- periods[[y]]$matchups[[i]]
      wlt$w[ mu[1] ] <- as.numeric(pts[ mu[1] ] > pts[ mu[2] ])
      wlt$l[ mu[1] ] <- as.numeric(pts[ mu[1] ] < pts[ mu[2] ])
      wlt$w[ mu[2] ] <- as.numeric(pts[ mu[2] ] > pts[ mu[1] ])
      wlt$l[ mu[2] ] <- as.numeric(pts[ mu[2] ] < pts[ mu[1] ])
      ## COMPLICATED TIE RULES - BAD PROGRAMMING, BUT JUST GET IT RIGHT
      if(pts[ mu[1] ] == pts[ mu[2] ]){
        team1cats <- 
          (tmp$hitsbb[ mu[1] ] > tmp$hitsbb[ mu[2] ]) + 
          (tmp$r[ mu[1] ] > tmp$r[ mu[2] ]) + 
          (tmp$rbi[ mu[1] ] > tmp$rbi[ mu[2] ]) + 
          (tmp$hr[ mu[1] ] > tmp$hr[ mu[2] ]) + 
          (tmp$sb[ mu[1] ] > tmp$sb[ mu[2] ]) + 
          (tmp$era[ mu[1] ] < tmp$era[ mu[2] ]) + 
          (tmp$so[ mu[1] ] > tmp$so[ mu[2] ]) + 
          (tmp$w[ mu[1] ] > tmp$w[ mu[2] ]) + 
          (tmp$sv[ mu[1] ] > tmp$sv[ mu[2] ]) + 
          (tmp$whip[ mu[1] ] < tmp$whip[ mu[2] ])
        team2cats <- 
          (tmp$hitsbb[ mu[2] ] > tmp$hitsbb[ mu[1] ]) + 
          (tmp$r[ mu[2] ] > tmp$r[ mu[1] ]) + 
          (tmp$rbi[ mu[2] ] > tmp$rbi[ mu[1] ]) + 
          (tmp$hr[ mu[2] ] > tmp$hr[ mu[1] ]) + 
          (tmp$sb[ mu[2] ] > tmp$sb[ mu[1] ]) + 
          (tmp$era[ mu[2] ] < tmp$era[ mu[1] ]) + 
          (tmp$so[ mu[2] ] > tmp$so[ mu[1] ]) + 
          (tmp$w[ mu[2] ] > tmp$w[ mu[1] ]) + 
          (tmp$sv[ mu[2] ] > tmp$sv[ mu[1] ]) + 
          (tmp$whip[ mu[2] ] < tmp$whip[ mu[1] ])
        wlt$w[ mu[1] ] <- as.numeric(team1cats > team2cats)
        wlt$l[ mu[1] ] <- as.numeric(team1cats < team2cats)
        wlt$w[ mu[2] ] <- as.numeric(team2cats > team1cats)
        wlt$l[ mu[2] ] <- as.numeric(team2cats < team1cats)
        wlt$t[ mu[1] ] <- as.numeric(team1cats == team2cats)
        wlt$t[ mu[2] ] <- as.numeric(team2cats == team1cats)
      }
    }
    wlt$points <- pts
    return(wlt)
  })
  standings <- Reduce("+", wl)
  standings$team <- rownames(standings)
  standings <- standings[ order(standings$w+.5*standings$t, standings$points, decreasing = T), c("team", "w", "l", "t", "points")]
} else{
  standings <- data.frame(team = names(allRosters$period1),
                          w = rep(0, 10),
                          l = rep(0, 10),
                          t = rep(0, 10), 
                          stringsAsFactors = FALSE)
}
