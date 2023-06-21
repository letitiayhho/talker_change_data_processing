## example on data from Greene (2002)
## grangertest(realcons, realgdp, order = 3)

## TODO: 1 find a sensible lag order for the default, especially after AIC
##       2 pairwise.granger.test on all possible pairs of a matrix

grangertest <- function(x, ...) {
  UseMethod("grangertest")
}

grangertest.formula <- function(formula, data = list(), ...) {
  mt <- terms(formula)
  attr(mt, "intercept") <- 0
  mf <- model.frame(mt, data = data)
  X <- cbind(model.matrix(mt, data = data), model.response(mf))
  colnames(X) <- names(mf)[2:1]
  grangertest(X, ...)
}

grangertest.default <- function(x, y, order = 1, window = 1, na.action = na.omit, ...)
{
  ## either x is a 2-column time series
  ## or x and y are univariate time series
  if((NCOL(x) == 2) && missing(y)) {
    xnam <- colnames(x)[1]
    ynam <- colnames(x)[2]
    x <- as.zoo(x)
    y <- x[,2]
    x <- x[,1]
  } else {
    xnam <- deparse(substitute(x))
    ynam <- deparse(substitute(y))
    x <- as.zoo(x)
    y <- as.zoo(y)
    stopifnot((NCOL(x) == 1), (NCOL(y) == 1))
  }
  
  # Set threshold for windows of computing lagged observations
  if (order > window) {
    lower_bounds <- order - window
  } else {
    lower_bounds <- 0
  }
  if (order < 500 - window) {
    upper_bounds <- order + window
  } else {
    upper_bounds <- 500
  }
  
  ## compute lagged observations
  print('compute lagged observations')
  lagX <- do.call("merge", lapply(lower_bounds:upper_bounds, function(k) lag(x, -k))) # CHANGE TO COMPUTE AROUND ORDER
  lagY <- do.call("merge", lapply(lower_bounds:upper_bounds, function(k) lag(y, -k)))
  
  ## collect series, handle NAs and separate results again
  print('collect series, handle NAs and separate results again')
  all <- merge(x, y, lagX, lagY)
  colnames(all) <- c("x", "y", paste("x", lower_bounds:upper_bounds, sep = "_"), paste("y", lower_bounds:upper_bounds, sep = "_"))
  all <- na.action(all)
  y <- as.vector(all[,2])
  print('is it here?')
  lagX <- as.matrix(all[,(lower_bounds:upper_bounds + 2)])
  lagY <- as.matrix(all[,(lower_bounds:upper_bounds + 2 + order)])
  
  ## fit full model
  fm <- lm(y ~ lagY + lagX)
  
  ## compare models with waldtest
  rval <- waldtest(fm, 2, ...)
  
  ## adapt annotation
  attr(rval, "heading") <- c("Granger causality test\n",
                             paste("Model 1: ", ynam, " ~ ", "Lags(", ynam, ", 1:", order, ") + Lags(", xnam, ", 1:", order,
                                   ")\nModel 2: ", ynam, " ~ ", "Lags(", ynam, ", 1:", order, ")", sep = ""))
  
  return(rval)
}