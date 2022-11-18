#' maxmm.exp
#'
#' @description This function computes the PMLE of parameters under the alternative model given a beta value. 
#' @param x The input data that can be either a vector or a matrix with the 1st column being the observed values
#' and the 2nd column being the corresponding frequency.
#' @param beta 
#' @param theta0 
#' @param len The number of initial values chosen for the EM-algorithm.
#' @param niter The least amount of iterations for all initial values in the EM-algorithm.
#' @param tol The tolerance value for the convergence of the EM-algorithm.
#'
#' @return
#' @export
#'
#' @examples
maxmm.exp <-
  function(x,beta,theta0,len,niter,tol)
  {
    m0=length(beta)
    
    ###Calculate eta_h's (the cut points of parameter space of theta)
    eta=rep(0,m0+1)
    eta[1]=min(x)
    eta[m0+1]=max(x)
    if(m0>1)
    {
      for(i in 2:m0)
        eta[i]=(theta0[i-1]+theta0[i])/2
    }
    output=c()
    for (i in 1:len)
    {
      ###initial values for EM-algorithm
      alpha=runif(m0,0,1)
      alpha=alpha/sum(alpha)
      alpha1=alpha*beta
      alpha2=alpha*(1-beta)
      theta1=rep(0,m0)
      theta2=rep(0,m0)
      for (l in 1:m0)
      {
        theta1[l]=runif(1,eta[l],eta[l+1])
        theta2[l]=runif(1,eta[l],eta[l+1])
      }
      
      for (j in 1:niter)###run niter EM-iterations first
      {
        pdf.part1=apply(as.matrix(1/theta1,ncol=1),1,dexp,x=x)
        pdf.part2=apply(as.matrix(1/theta2,ncol=1),1,dexp,x=x)
        pdf.component1=t(t(pdf.part1)*alpha1)+1e-100/m0
        pdf.component2=t(t(pdf.part2)*alpha2)+1e-100/m0
        pdf=apply(pdf.component1,1,sum)+apply(pdf.component2,1,sum)
        w1=pdf.component1/pdf
        w2=pdf.component2/pdf
        alpha=apply(w1+w2,2,mean)
        alpha1=alpha*beta
        alpha2=alpha*(1-beta)
        theta1=apply(w1*x,2,sum)/apply(w1,2,sum)
        theta2=apply(w2*x,2,sum)/apply(w2,2,sum)
        for(l in 1:m0)
        {
          theta1[l]=max(min(theta1[l],eta[l+1]),eta[l])
          theta2[l]=max(min(theta2[l],eta[l+1]),eta[l])
        }
      }
      pdf.part1=apply(as.matrix(1/theta1,ncol=1),1,dexp,x=x)
      pdf.part2=apply(as.matrix(1/theta2,ncol=1),1,dexp,x=x)
      pdf.component1=t(t(pdf.part1)*alpha1)+1e-100/m0
      pdf.component2=t(t(pdf.part2)*alpha2)+1e-100/m0
      pdf=apply(pdf.component1,1,sum)+apply(pdf.component2,1,sum)
      ln=sum(log(pdf))
      output=rbind(output,c(alpha,theta1,theta2,ln))
    }
    index=which.max(output[,(3*m0+1)])
    alpha=output[index,1:m0]
    theta=output[index,(m0+1):(2*m0)]
    ln0=output[index,(3*m0+1)]
    err=1
    t=0
    pdf.part1=apply(as.matrix(1/theta1,ncol=1),1,dexp,x=x)
    pdf.part2=apply(as.matrix(1/theta2,ncol=1),1,dexp,x=x)
    pdf.component1=t(t(pdf.part1)*alpha1)+1e-100/m0
    pdf.component2=t(t(pdf.part2)*alpha2)+1e-100/m0
    pdf=apply(pdf.component1,1,sum)+apply(pdf.component2,1,sum)
    while (err>tol & t<2000)###EM-iteration with the initial value with the largest penalized log-likelihood
    {
      w1=pdf.component1/pdf
      w2=pdf.component2/pdf
      alpha=alpha=apply(w1+w2,2,mean)
      alpha1=alpha*beta
      alpha2=alpha*(1-beta)
      theta1=apply(w1*x,2,sum)/apply(w1,2,sum)
      theta2=apply(w2*x,2,sum)/apply(w2,2,sum)
      for(l in 1:m0)
      {
        theta1[l]=max(min(theta1[l],eta[l+1]),eta[l])
        theta2[l]=max(min(theta2[l],eta[l+1]),eta[l])
      }
      pdf.part1=apply(as.matrix(1/theta1,ncol=1),1,dexp,x=x)
      pdf.part2=apply(as.matrix(1/theta2,ncol=1),1,dexp,x=x)
      pdf.component1=t(t(pdf.part1)*alpha1)+1e-100/m0
      pdf.component2=t(t(pdf.part2)*alpha2)+1e-100/m0
      pdf=apply(pdf.component1,1,sum)+apply(pdf.component2,1,sum)
      ln1=sum(log(pdf))
      err=ln1-ln0
      ln0=ln1
      t=t+1
    }
    list("alpha"=alpha,"theta1"=theta1,"theta2"=theta2)
  }