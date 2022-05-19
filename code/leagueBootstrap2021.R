
#####
## TEAMS
#####
allTeams <- c(
  "Washington Generals",
  "Vass Deferens",
  "Mean Wieners",
  "Wonderbots",
  "T and A",
  "SYWA",
  "Overwhelming Underdogs",
  "Boys of Summer",
  "Terminoeckers",
  "Nuclear Arms")

#####
## POSITION MAPPING
#####
posMap <- c("C", "1B", "2B", "3B", "SS", "MI", "CI", "OF", "DH", "BAT BENCH", "SP", "RP", "OP", "PITCH BENCH")
names(posMap) <- c("posC", "pos1b", "pos2b", "pos3b", "posSs", "posMi", "posCi", "posOf", "posDh", "posBatBench", "posSp", "posRp", "posOp", "posPitchBench")
batMask <- !(posMap %in% c("SP", "RP", "OP", "PITCH BENCH"))

#####
## INFO ON THE LEAGUE SCHEDULE
#####
periods <- list(
  list(startDate = as.Date("2021-04-01"),
       endDate = as.Date("2021-04-21"),
       matchups = list(
         c(1, 2),
         c(3, 4),
         c(5, 6),
         c(7, 8),
         c(9, 10))),
  list(startDate = as.Date("2021-04-22"),
       endDate = as.Date("2021-05-11"),
       matchups = list(
         c(1, 3),
         c(2, 4),
         c(5, 8),
         c(6, 9),
         c(7, 10))),
  list(startDate = as.Date("2021-05-12"),
       endDate = as.Date("2021-05-31"),
       matchups = list(
         c(1, 4),
         c(2, 5),
         c(3, 10),
         c(6, 8),
         c(7, 9))),
  list(startDate = as.Date("2021-06-01"),
       endDate = as.Date("2021-06-21"),
       matchups = list(
         c(1, 5),
         c(2, 6),
         c(3, 9),
         c(4, 7),
         c(8, 10))),
  list(startDate = as.Date("2021-06-22"),
       endDate = as.Date("2021-07-11"),
       matchups = list(
         c(1, 6),
         c(2, 7),
         c(3, 8),
         c(4, 10),
         c(5, 9))),
  list(startDate = as.Date("2021-07-16"),
       endDate = as.Date("2021-08-04"),
       matchups = list(
         c(1, 7),
         c(2, 8),
         c(3, 6),
         c(4, 9),
         c(5, 10))),
  list(startDate = as.Date("2021-08-05"),
       endDate = as.Date("2021-08-24"),
       matchups = list(
         c(1, 8),
         c(2, 9),
         c(3, 7),
         c(4, 5),
         c(6, 10))),
  list(startDate = as.Date("2021-08-25"),
       endDate = as.Date("2021-09-13"),
       matchups = list(
         c(1, 9),
         c(2, 10),
         c(3, 5),
         c(4, 8),
         c(6, 7))),
  list(startDate = as.Date("2021-09-14"),
       endDate = as.Date("2021-10-03"),
       matchups = list(
         c(1, 10),
         c(2, 3),
         c(4, 6),
         c(5, 7),
         c(8, 9))))
names(periods) <- paste("period", 1:length(periods), sep="")
