#' pmle.norm
#'
#' @description This function computes the PMLE or MLE of the parameters under a mixture of normals with unequal variance.
#' @param x The data that can either be a vector or a matrix with the 1st column being the observed values
#' and the 2nd column being the corresponding frequencies.
#' @param m0 The order of the finite mixture model, default value: m0 = 1.
#' @param lambda The size of the penalized function of the mixing distribution, default value: lambda = 0.
#' @param inival The initial values chosen for the EM-algorithm, a 3m0-dimension vector including m0 mixing proportions, 
#' m0 component means and m0 component variances, or a matrix with 3m0 columns, default value: inival = NULL. (if not provided, random initial values are used.)
#' @param len The number of initial values chosen for the EM-algorithm, default value: len = 10.
#' @param niter The smallest number of iterations required for all initial values in the EM-algorithm. 
#' The algorithm runs EM-iteration niter times from each initial value. 
#' The iteration will restart from the parameter value with the highest likelihood value at the point and run until convergence. default value: niter = 50.
#' @param tol The tolerance value for the convergence of the EM-algorithm, default value: tol = 1e-6.
#' @param rformat The format of the output. If rformat=T, 
#' it means the output format is determined by R software. 
#' If rformat=F, it means the output format is determined by our default setting. 
#' When the output is larger than 0.001, it is determined by round(output,3); 
#' When the output is less than 0.001, it is determined by signif(output,3).
#' The default value of rformat is F.
#'
#' @return  The PMLE or MLE of the parameters with order = m0 (mixing proportions, mixing means
#           and mixing variances), log-likelihood value at the PMLE or MLE and the penalized log-likelihood
#           value at the PMLE.

#' @export 
#'
#' @examples #load the pearson's crab data, fit the 2 and 3 component normal mixture models,
#'plot the histgorams of the observations and the fitted densities.
#'data(pearson)
#'out1 <- pmle.norm(pearson,2,1)
#'plotmix.norm(pearson,out1)
#'
#'# Not run:
#'out2 <- pmle.norm(pearson,3,1)
#'plotmix.norm(pearson,out2)
#'par(mfrow=c(1,1))
#'
#'# End(Not run)
pmle.norm <-
  function(x,m0=1,lambda=0,inival=NULL,len=10,niter=50,tol=1e-6,rformat=FALSE)
  {
    if (is.data.frame(x))
    {
      if (ncol(x)==2)
        x=as.matrix(x)
      if (ncol(x)==1 | ncol(x)>2)
        x=x[,1]
    }
    if (is.matrix(x))
    {
      xx=c()
      for (i in 1:nrow(x))
        xx=c(xx,rep(x[i,1],x[i,2]))
      x=xx
    }
    
    out=phi.norm(x,m0,lambda,inival,len,niter,tol)
    alpha=out[[1]]
    mean=out[[2]]
    var=out[[3]]
    loglik=out[[4]]
    ploglik=out[[5]]
    
    if (rformat==F)
    {
      alpha=rousignif(alpha)
      mean=rousignif(mean)
      var=rousignif(var)
      loglik=rousignif(loglik)
      ploglik=rousignif(ploglik)
    }
    
    if (m0>1)
    {
      list('PMLE of mixing proportions'=alpha,
           'PMLE of means'=mean,
           'PMLE of variances'=var,
           'log-likelihood'=loglik,
           'Penalized log-likelihood'=ploglik)
    }
    else
    {
      list('MLE of mixing proportions'=alpha,
           'MLE of means'=mean,
           'MLE of variances'=var,
           'log-likelihood:'=loglik)
    }
  }