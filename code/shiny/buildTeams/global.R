source("../../leagueBootstrap2023.R")

load("../../../data/hidden/rangeData.RData")
allNames <- data.frame(fullName = c(rangeData$batters$fullName, rangeData$pitchers$fullName),
                       withId = c(rownames(rangeData$batters), rownames(rangeData$pitchers)),
                       stringsAsFactors = FALSE)
rownames(allNames) <- NULL
allNames <- allNames[ !duplicated(allNames), ]
rownames(allNames) <- allNames$withId
allNames <- allNames[ order(allNames$withId), ]

today <- Sys.Date()
currentPeriod <- which(sapply(periods, function(x){ today >= x$startDate & today <= x$endDate}))
seasonPeriods <- which(sapply(periods, function(x){ today >= x$startDate }))
