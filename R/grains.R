#' grains
#'
#' @description This data set contains the square root of the total number of grains for each planty from Loisel et al.,
#' (1994). Loisel et al., (1994) suggested using a finite normal mixture model. The grains data frame
#' has 150 rows and 1 column.
#'
#' @usage data(grains)
#' @format This data frame contains one column:
#' x: square root of the total number of grains for each planty.
#'
#' @references Loisel, P., Goffinet, B., Monod, H., and Montes De Oca, G. (1994). Detecting a major gene in an
#' F2 population. Biometrics, 50, 512-516.
#' 
#' @examples data(grains)
#' out1 <- pmle.norm(unlist(grains),2,1)
#' out2 <- emtest.norm(unlist(grains),m0 = 2)
#' plotmix.norm(unlist(grains), alpha = out1[[1]][1,], mu = out1[[1]][2,], sigma = out1[[1]][3,], m0 = 2)
#' plotmix.norm(unlist(grains), alpha = out2[[1]][1,], mu = out2[[1]][2,], sigma = out2[[1]][3,], m0 = 2)
#' @source <https://github.com/jhchen-stat-ubc-ca/Mixturelnf2.0>
"grains"