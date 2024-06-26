#' emtest.pois
#'
#' @description This function computes the EM-test statistic and the p-value under the null hypothesis with order m = m0.
#' @param x The input data that can either be a vector or a matrix of observations with its 1st column being counts and 2nd column being frequencies.
#' @param CC The optional tuning parameter for the EM-test procedure.
#' @param init.val A user provided initial values for the EM-algorithm to 
#'                 compute the PMLE under the null model.
#' @param n.init The number of initial values chosen for the EM-algorithm.
#' @param n.iter The least amount of iterations for all initial values in the EM-algorithm.
#' @param tol The tolerance value for the convergence of the EM-algorithm. 
#' @param k The number of EM iterations required in order to obtain the EM-test statistic.
#' @param rformat A specific format, please see rousignif.R function. 
#' @param max.iter The maximum amount of iterations.
#'
#' @return The function returns an object of class EM-test with the following elements:
#' The MLE of the parameters under the null hypothesis (order = m0)
#' The PMLE of the parameters under the specific alternative hypothesis whose order is 2m0
#' EM-test statistic
#' P-value
#' Level of penalty
#' The number of iterations
#' @author Shaoting Li, Jiahua Chen and Pengfei Li
#' @references Chen, J. and Li, P. (2011). Tuning the EM-test for the order of finite mixture models. The Canadian Journal of Statistics. 39, 389-404.
#' Li, P. and Chen, J. (2010). Testing the order of a finite mixture model. JASA. 105, 1084-1092.
#' Li, P., Chen, J. and Marriott, P. (2009). Non-finite Fisher information and homogeneity: The EM approach. Biometrika. 96, 411-426.
#'
#' @examples n = 3000
#' mu = c(3, 9, 15)
#' alpha = c(.2, .3, .5)
#' xx = rmix.pois(n, alpha, mu)
#' emtest.pois(xx, m0 = 3, CC = NULL, init.val=NULL, n.init = 10, n.iter = 50, tol = 1e-6, k=3, rformat = F, max.iter = 5000)
#' @export
#' 
#' @seealso plotmix.pois, pmle.pois, rmix.pois
emtest.pois <- function(x, m0 = 1, CC = NULL, init.val=NULL, n.init = 10, 
                        n.iter = 50, tol = 1e-6, k=3, rformat = F, max.iter = 5000)
{
  if(is.vector(x)) {
    min.x = min(x); max.x = max(x)
    count = min.x:max.x
    freq = count*0
    for(i in count) freq[i- min.x + 1]= sum(x==i)
    xx = cbind(count, freq)
  }
  if(is.matrix(x)) {
    if(dim(x)[2]!=2) stop("data matrix should have exactly 2 columns")
    xx = x
  }
  n = sum(freq)	
  ## summarize data into count + freq if not so in the first place.
  
  ###MLE of parameters under the null model	
  if(m0 > 1) {
    out.null= pmle.pois(xx, m0, 0, init.val, n.init, n.iter, tol, max.iter)
    alpha0 = out.null[[1]]
    theta0 = out.null[[2]]
    ln0 = out.null[[3]]
    t0  = rbind(alpha0, theta0)
    temp = tildeB22.pois(alpha0, theta0)
    degenerate = temp[[2]] 
    tb2 = temp[[1]]
  } else {
    alpha0 = 1
    theta0 = sum(count*freq)/sum(freq)
    t0  = rbind(alpha0, theta0)
    ln0 = sum(freq*log(dpois(count, theta0)))
    degenerate = F
    tb2 = 1
  }
  
  if(degenerate) {
    list("MLE under null(order = m0)"= t0,
         "MLE under order = 2*m0" = F,
         "EM-test statistic" = 0,
         "P-value"= 1,
         "Level of penalty"= NULL,
         "degenerate fitted null"= T)
  } else {            ### Chisquare bar coefficients
    if (m0==1) ah = c(0.5,0.5)
    if (m0==2) ah = c(0.5-acos(tb2[1,2])/2/pi, 0.5, acos(tb2[1,2])/2/pi)
    if (m0==3) {
      a0 = 0.5-acos(tb2[1,2])/4/pi-acos(tb2[1,3])/4/pi-acos(tb2[2,3])/4/pi
      a2 = 0.5-a0
      w123 =(tb2[1,2]-tb2[1,3]*tb2[2,3])/sqrt(1-tb2[1,3]^2)/sqrt(1-tb2[2,3]^2)
      w132 =(tb2[1,3]-tb2[1,2]*tb2[3,2])/sqrt(1-tb2[1,2]^2)/sqrt(1-tb2[3,2]^2)
      w231 =(tb2[2,3]-tb2[2,1]*tb2[3,1])/sqrt(1-tb2[2,1]^2)/sqrt(1-tb2[3,1]^2)
      a1 = 0.75-acos(w123)/4/pi-acos(w132)/4/pi-acos(w231)/4/pi
      a3 = 0.5-a1
      ah = c(a0,a1,a2,a3) }
    if (m0 >3) ah = emtest.norm0.thm3(tb2, N=10000, tol=1e-8) 
    ### same formula as for normal mixture with common mean
    
    if(is.null(CC)) {
      if (m0==1) CC = 0.54
      if (m0==2) { temp = exp(5-10.6*tb2[1,2]-123/n); CC = 0.5*temp/(1+ temp)}
      if (m0==3) { temp = exp(3.3-5.5*tb2[1,2]-5.5*tb2[2,3]-165/n); 
      CC = 0.5*temp/(1+ temp) } 
      if (m0 >3)  CC = 0.5
    }
    
    out = EMstat.pois(xx[,1], xx[,2], alpha0, theta0, m0, ln0, 
                      CC, n.init, n.iter, tol, k, max.iter)
    emnk = out[1]
    alpha= out[2:(2*m0+1)]
    theta= out[(2*m0+2):(4*m0+1)]
    t1   = rbind(alpha,theta)
    
    pp =sum(ah*pchisq(emnk, 0:m0, lower.tail = F))
    
    if (rformat==F)  {
      t0=rousignif(t0)
      t1=rousignif(t1)
      emnk=rousignif(emnk)
      pp = rousignif(pp)
      CC=rousignif(CC)
    }
    
    list("MLE under null model (order = m0)"= t0,
         "Parameter estimates under the order = 2m0"= t1,
         "EM-test Statistic"= emnk,
         "P-value"= pp,
         "Level of penalty"=CC)
  }
}