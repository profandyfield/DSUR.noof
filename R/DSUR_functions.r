#' Function rcontrast
#'
#' DSUR, page 457.
#' This function computes effect sizes for the orthogonal contrasts.
#'
#' @param t t-value of the test.
#' @param df degrees of freedom.
#' @return None
#' @export
#' @examples 
#' rcontrast(2.474, 12)
rcontrast <- function(t, df) {
  r <- sqrt(t^2/(t^2 + df)) 
  print(paste("r = ", r))
}
  
#' Function rFromWilcox 
#'
#' DSUR, page 665.
#' This function computes effect sizes from models created using wilcox.test().
#'
#' @param wilcoxModel a model created using wilcox.test().
#' @param N total sample size.
#' @return ans list of calculation results
#' @export
# @examples
# rFromWilcox(sunModel, 20)
rFromWilcox <- function(wilcoxModel, N) {
  z <- qnorm(wilcoxModel$p.value/2)
  r <- z/sqrt(N)
  cat(wilcoxModel$data.name, "Effect Size, r = ", r)
}

#' KMO Kaiser-Meyer-Olkin Measure of Sampling Adequacy 
#'
#' DSUR, page 776.
#' Function by G. Jay Kerns, Youngstown State University
#' see http://tolstoy.newcastle.edu.au/R/e2/help/07/08/22816/html
#' This function computes Kaiser-Meyer-Olkin Measure of Sampling Adequacy.
#' Needs the MASS package.
#'
#' @param data dataframe to compute the kmo on.
#' @return None
#' @export
#' @examples
#' kmo(data.frame(c(1,2,3), c(1,2,3), c(1,2,3)))
kmo <- function(data){
  if(requireNamespace("MASS", quietly = TRUE)) {
    
    X <- cor(as.matrix(data)) 
    iX <- MASS::ginv(X) 
    S2 <- diag(diag((iX^-1)))

    AIS <- S2%*%iX%*%S2                      # anti-image covariance matrix
    IS <- X+AIS-2*S2                         # image covariance matrix
    Dai <- sqrt(diag(diag(AIS)))
    IR <- MASS::ginv(Dai)%*%IS%*%MASS::ginv(Dai)         # image correlation matrix
    AIR <- MASS::ginv(Dai)%*%AIS%*%MASS::ginv(Dai)       # anti-image correlation matrix
    a <- apply((AIR - diag(diag(AIR)))^2, 2, sum)   
    AA <- sum(a) 
    b <- apply((X - diag(nrow(X)))^2, 2, sum)   
    BB <- sum(b)
    MSA <- b/(b+a)                        # indiv. measures of sampling adequacy
    AIR <- AIR-diag(nrow(AIR))+diag(MSA)  # Examine the anti-image of the
                                        # correlation matrix. That is the
                                        # negative of the partial correlations,
                                        # partialling out all other variables.
    kmo <- BB/(AA+BB)                     # overall KMO statistic

    # Reporting the conclusion 
    if (kmo >= 0.00 && kmo < 0.50){ 
      test <- 'The KMO test yields a degree of common variance unacceptable for FA.'
    } else if (kmo >= 0.50 && kmo < 0.60){ 
      test <- 'The KMO test yields a degree of common variance miserable.' 
    } else if (kmo >= 0.60 && kmo < 0.70){ 
      test <- 'The KMO test yields a degree of common variance mediocre.' 
    } else if (kmo >= 0.70 && kmo < 0.80){ 
      test <- 'The KMO test yields a degree of common variance middling.' 
    } else if (kmo >= 0.80 && kmo < 0.90){ 
      test <- 'The KMO test yields a degree of common variance meritorious.' 
    } else { 
      test <- 'The KMO test yields a degree of common variance marvelous.'     
    }

    ans <- list( overall = kmo,
		report = test,
		individual = MSA,
		AIS = AIS,
                AIR = AIR )

    return(ans)
  } else {
    stop("Package 'MASS' (version >= 7.3-45) needed. Please install.", call. = FALSE)
  }
} # end of kmo()

# Function factor.structure
# function missing in book

#' Function meanOfVariable
#'
#' DSUR, page 228.
#' This function calculates the mean value of a variable.
#'
#' @param variable the variable to calculate the mean value of.
#' @return None
#' @export
#' @examples 
#' meanOfVariable(c(1,2,3))
meanOfVariable <- function(variable) {
  mean <- sum(variable)/length(variable) 
  cat("Mean = ", mean)
}

#' Function logisticsPseudoR2s
#' 
#' DSUR, page 332.
#' This function calculates the various values of R^2 from a logistic regression model.
#'
#' @param logModel logistic regression model
#' @return None
#' @export
# @examples
# logisticPseudoR2s(eelModel.1)
logisiticPseudoR2s <- function(logModel) {
  dev <- logModel$deviance
  nullDev <- logModel$null.deviance
  modelN <- length(logModel$fitted.values)
  R.l <- 1-dev/nullDev
  R.cs <- 1-exp(-(nullDev-dev)/modelN)
  R.n <- R.cs/(1-(exp(-(nullDev/modelN))))
  
  cat("Pseudo R^2 for logistics regression\n")
  cat("Hosmer and Lemeshow R^2: \t", round(R.l, 3), "\n")
  cat("Cox and Snell R^2\t: ", round(R.cs, 3), "\n")
  cat("Nagelkerke R^2\t: ", round(R.n, 3), "\n")
}

#' Function rmMeanAdjust
#'
#' DSUR, page 365.
#' This function adjusts scores for the fact they were from a repeated-measures design.
#'
#' @param dataframe 2-dimensional dataframe with the scores that need adjustment.
#' @return output table of variables and adjustment.
#' @export
#' @examples
#' rmMeanAdjust(data.frame(c(1,2,3), c(1,2,3)))
rmMeanAdjust <- function(dataframe) {
  varNames <- names(dataframe)
  pMean <- (dataframe[,1] + dataframe[,2])/2
  gradmean <- mean(c(dataframe[,1], dataframe[,2]))
  adj <- adj <- gradmean - pMean
  varA_adj <- dataframe[,1] + adj 
  varB_adj <- dataframe[,2] + adj 
  output <- data.frame(varA_adj, varB_adj)
  names(output) <- c(paste(varNames[1], "Adj", sep="_"), 
		      paste(varNames[2], "Adj", sep="_"))
  return(output)
}

#' Function ttestfromMeans
#'
#' DSUR, page 375.
#' This function calculates a t-test for the means, standard deviations, and sample sizes of two groups.
#'
#' @param x1 mean of group 1.
#' @param x2 mean of group 2.
#' @param sd1 standard deviation of group 1.
#' @param sd2 standard deviation of group 2.
#' @param n1 sample size of group 1.
#' @param n2 sample size of group 2.
#' @return None
#' @export
# @examples
# ttestfromMeans(x1, x2, sd1, sd2, n1, n2)
ttestfromMeans <- function(x1, x2, sd1, sd2, n1, n2) {
  df <- n1+n2-2
  poolvar <- (((n1-1)*sd1^2)+((n2-1)*sd2^2))/df
  t <- (x1-x2)/sqrt(poolvar*((1/n1)+(1/n2)))
  sig <- 2*(1-pt(abs(t),df))
  paste("t(df = ", df, ") = ", t, ", p = ", sig, sep= "")
}

#' Function residual.stats
#'
#' DSUR, page 785.
#' This function wraps all of the factor analysis residual commands.
#'
#' @param matrix residual matrix. (Calculate using factor.residuals()).
#' @return None
#' @export
# @examples 
# residual.stats(resids)
residual.stats <- function(matrix) {
  residuals <- as.matrix(matrix[upper.tri(matrix)]) 
  large.resid <- abs(residuals) > 0.05
  numberLargeResids <-(large.resid)
  propLargeResid <- numberLargeResids/nrow(residuals) 
  rmsr <- sqrt(mean(residuals^2))
  
  cat("Root means squared residual = ", rmsr, "\n")
  cat("Number of absolute residuals > 0.05 = ", numberLargeResids, "\n")
  cat("Proportions of absolute residuals > 0.05 = ", propLargeResid, "\n")
  hist(residuals)
}










