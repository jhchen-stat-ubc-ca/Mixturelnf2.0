#' pmix.norm
#'
#' @param x The cdf value of the Normal mixture at x.
#' @param alpha A vector of the mixing proportions.
#' @param mu A vector of the component means.
#' @param sigma A vector of the component standard deviations.
#'
#' @author Shaoting Li, Jiahua Chen and Pengfei Li
#'
#' @examples n=3000
#' alpha = c(.2, .5, .3); mu = c(-2, 4, 5); 
#' sigma = c(1, .8, 1.1)*2
#' x = rmix.norm(n, alpha, mu, sigma)
#' pmix.norm(x,alpha,mu,sigma)
#' @export
pmix.norm <- function(x, alpha, mu, sigma) {
  if(any(alpha<0))
    stop("error: negative mixing proportion")
  if(any(sigma<0))
    stop("error: negative standard deviation")
  m1 = length(alpha)
  m2 = length(mu)
  m3 = length(sigma)
  if((m1-m2)^2+(m1-m3)^2 > 0)
    stop("error: differ lengths of alpha, mu and sigma")
  alpha = alpha/sum(alpha)
  mixture.cdf = x*0
  for(i in 1:m1) {
    mixture.cdf = mixture.cdf+alpha[i]*pnorm(x, mu[i], sigma[i])
  }
  return(mixture.cdf)
}