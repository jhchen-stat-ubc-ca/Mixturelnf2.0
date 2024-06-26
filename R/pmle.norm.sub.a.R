#' pmle.norm.sub.a
#'
#' @description It is used in the pmle.norm.sub function, it computes a single EM iteration for the univariate Gaussian mixture.
#' @export
pmle.norm.sub.a <- 
  function(xx, sample.var, m0, para0, lambda, an)  {
    nn = length(xx)
    pdf.sub = matrix(0, m0, nn);
    ww = NULL
    
    alpha = para0[1:m0]
    mu = para0[(m0+1):(2*m0)]
    sigma = para0[(2*m0+1):(3*m0)]
    std.sub = sqrt(sigma)
    
    ## E-step
    for(j in 1:m0) pdf.sub[j,] = dnorm(xx, mu[j], std.sub[j])*alpha[j]
    pdf.mixture = apply(pdf.sub,2,sum) +1e-100
    ## M-step
    for(j in 1:m0) {
      ww = pdf.sub[j,]/pdf.mixture;  
      ww.total = sum(ww)
      alpha[j] = (ww.total+lambda)/(nn+m0*lambda)
      ## modification of Chen, chen and Kalbfleisch
      mu[j] = weighted.mean(xx, ww)
      sigma[j] = (sum(ww*(xx-mu[j])^2)+2*sample.var*an)/(ww.total+2*an)
    }
    ### penalty of Chen, Tan, Zhang
    pdf= dmix.norm(xx, alpha, mu, sqrt(sigma)) + 1e-100
    ### avoid under flow
    loglike = sum(log(pdf))
    temp = sample.var/sigma
    penalty = an*sum(temp - log(temp)) - lambda*sum(log(alpha))
    ploglike = loglike - penalty
    ## reorganize the output to have increasing subpop mean.
    ind = sort(mu,index.return = TRUE)$ix
    return(c(alpha[ind], mu[ind], sigma[ind], loglike, ploglike))
  }