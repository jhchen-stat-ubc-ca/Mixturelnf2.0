#' emtest.exp
#'
#' @description This function computes the EM-test statistic and the p-value for the null hypothesis H0:m=m0.
#' @param x The input data that can be either a vector or a matrix with the 1st column being the observed values
#' and the 2nd column being the corresponding frequency. 
#' @param m0 The order under null hypothesis.
#' @param C A optional tuning parameter for the EM-test procedure.
#' @param inival The initial values chosen for the EM-algorithm in order to compute the PMLE under the null model.
#' @param len The number of initial values chosen for the EM-algorithm.
#' @param niter The least amount of iterations for all initial values in the EM-algorithm.
#' @param tol The tolerance value for the convergence of the EM-algorithm.
#' @param k The number of EM iterations needed to obtain the EM-test statistic.
#' @param rformat The format of the output, rformat=T means the format is determined by R.
#'		rformat=F means the format is determined by our default setting. When the output is
#'		larger than 0.001, it is determined by round(output,3); When the output is less than 0.001,
#'		it is determined by signif(output,3).
#'
#' @return
#' @export
#'
#' @examples
emtest.exp <-
  function(x,m0=1,C=NULL,inival=NULL,len=10,niter=50,tol=1e-6,k=3,rformat=FALSE)
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
    
    ###MLE of parameters under the null model	
    outnull=phi0.exp(x,m0,0,inival,len,niter,tol)
    alpha=outnull$alpha
    theta=outnull$theta
    t0=rbind(alpha,theta)
    
    n=length(x)
    ###Size of penalized function
    if (m0==1)
    {
      if (is.null(C))
        C=exp(0.74+82/n)/(1+exp(0.74+82/n))
      ah=c(0.5,0.5)
    }
    if (m0==2)
    {
      tb2=tb2.exp(outnull$alpha,outnull$theta)
      if (is.null(C))
        C=exp(2.3-8.5*tb2[1,2])/(1+exp(2.3-8.5*tb2[1,2]))
      ah=c(0.5-acos(tb2[1,2])/2/pi,0.5,acos(tb2[1,2])/2/pi)
    }
    if (m0==3)
    {
      tb2=tb2.exp(outnull$alpha,outnull$theta)
      if (is.null(C))
        C=exp(2.2-5.9*tb2[1,2]-5.9*tb2[2,3])/(1+exp(2.3-5.9*tb2[1,2]-5.9*tb2[2,3])) 
      
      a0=0.5-acos(tb2[1,2])/4/pi-acos(tb2[1,3])/4/pi-acos(tb2[2,3])/4/pi
      a2=0.5-a0
      w123=(tb2[1,2]-tb2[1,3]*tb2[2,3])/sqrt(1-tb2[1,3]^2)/sqrt(1-tb2[2,3]^2)
      w132=(tb2[1,3]-tb2[1,2]*tb2[3,2])/sqrt(1-tb2[1,2]^2)/sqrt(1-tb2[3,2]^2)
      w231=(tb2[2,3]-tb2[2,1]*tb2[3,1])/sqrt(1-tb2[2,1]^2)/sqrt(1-tb2[3,1]^2)
      a1=0.75-acos(w123)/4/pi-acos(w132)/4/pi-acos(w231)/4/pi
      a3=0.5-a1
      ah=c(a0,a1,a2,a3)
    }
    if (m0>3)
    {
      if (is.null(C))
        C=0.5
      tb2=tb2.exp(outnull$alpha,outnull$theta)
      ah=emtest.thm3(tb2,N=10000,tol=1e-8)
    }
    
    out=emstat.exp(x,outnull,C,len,niter,tol,k)
    emnk=out[1]
    alpha=out[2:(2*m0+1)]
    theta=out[(2*m0+2):(4*m0+1)]
    t1=rbind(alpha,theta)
    p=sum(ah*pchisq(emnk,0:m0,lower.tail = F))
    
    if (rformat==F)
    {
      t0=rousignif(t0)
      t1=rousignif(t1)
      emnk=rousignif(emnk)
      p=rousignif(p)
      C=rousignif(C)
    }
    
    list('MLE of parameters under null hypothesis (order = m0)'=t0,
         'Parameter estimates under the order = 2m0'=t1,
         'EM-test Statistic'=emnk,
         'P-value'=p,
         'Level of penalty'=C)
  }