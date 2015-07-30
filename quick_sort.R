# http://www.uio.no/english/services/it/research/hpc/courses/r/2013-04_parallel_r.pdf
# http://www.uio.no/english/services/it/research/hpc/courses/r/2013-04_parallel_r.pdf
qsort <- function(array){
  less=as.vector(0)
  equal=as.vector(0)
  greater=as.vector(0)
  x=0
  if (length(array) > 1){
    pivot = array[1]
    for(x in 1:length(array)){
      if (array[x] < pivot)
        less = c(less,array[x])
      if (array[x] == pivot)
        equal = c(equal,array[x])
      if (array[x] > pivot)
        greater = c(greater,array[x])
    }
    if(less[1]==0)
      less = less[-1];
    if(equal[1]==0)
      equal = equal[-1]
    if(greater[1]==0)
      greater = greater[-1]
    
    array = c(qsort(less),equal,qsort(greater))
    return(array)
  }
  else
    return(array)
}

qsortMP1 <- function(array){
  less=as.vector(0)
  equal=as.vector(0)
  greater=as.vector(0)
  x=0
  if (length(array) > 1){
    pivot = array[1]
    for(x in 1:length(array)){
      if (array[x] < pivot)
        less = c(less,array[x])
      if (array[x] == pivot)
        equal = c(equal,array[x])
      if (array[x] > pivot)
        greater = c(greater,array[x])
    }
    if(less[1]==0)
      less = less[-1];
    if(equal[1]==0)
      equal = equal[-1]
    if(greater[1]==0)
      greater = greater[-1]
    
    array = c(lapply(less,qsort),equal,lapply(greater,qsort))
    return(array)
  }
  else
    return(array)
}


# Parallel Computing
# https://beckmw.wordpress.com/2014/01/21/a-brief-foray-into-parallel-processing-with-r/

#// ===============
#number of iterations in the loop
iters<-10
#vector for appending output
ls<-vector('list',length=iters)

#start time
strt<-Sys.time()

#loop
for(i in 1:iters){
  
  #counter
  cat(i,'\n')
  
  to.ls<-rnorm(1e6)
  to.ls<-summary(to.ls)
  
  #export
  ls[[i]]<-to.ls
  
}

#end time
print(Sys.time()-strt)
# Time difference of 2.944168 secs

#//=================
#iterations to time
iters<-seq(10,100,by=10)

#output time vector for  iteration sets
times<-numeric(length(iters))

#loop over iteration sets
for(val in 1:length(iters)){
  
  cat(val,' of ', length(iters),'\n')
  
  to.iter<-iters[val]
  
  #vector for appending output
  ls<-vector('list',length=to.iter)
  
  #start time
  strt<-Sys.time()
  
  #same for loop as before
  for(i in 1:to.iter){
    
    cat(i,'\n')
    
    to.ls<-rnorm(1e6)
    to.ls<-summary(to.ls)
    
    #export
    ls[[i]]<-to.ls
    
  }
  
  #end time
  times[val]<-Sys.time()-strt
  
}

#plot the times
library(foreach)
library(doParallel)
library(ggplot2)

to.plo<-data.frame(iters,times)
ggplot(to.plo,aes(x=iters,y=times)) + 
  geom_point() +
  geom_smooth() + 
  theme_bw() + 
  scale_x_continuous('No. of loop iterations') + 
  scale_y_continuous ('Time in seconds')

# // ============

#predict times
mod<-lm(times~iters)
predict(mod,newdata=data.frame(iters=1e4))/60
# 45.75964


#//=============
#import packages
library(foreach)
library(doParallel)

#number of iterations
iters<-1e4

#setup parallel backend to use 8 processors
cl<-makeCluster(8)
registerDoParallel(cl)

#start time
strt<-Sys.time()

#loop
ls<-foreach(icount(iters)) %dopar% {
  
  to.ls<-rnorm(1e6)
  to.ls<-summary(to.ls)
  to.ls
  
}

print(Sys.time()-strt)
stopCluster(cl)

#Time difference of 10.00242 mins



#// ==========
mp1 <- function(n) {
  n1=0
  for(n1 in 1 :length(n)){
    n2 = n^2}
  return(n2)
}

x1 = sample(50000)
> system.time(sort(x1))
user  system elapsed 
0.005   0.001   0.006 
> system.time(qsort(x1))
user  system elapsed 
19.535   9.867  29.557 
> system.time(lapply(x1,qsort))
user  system elapsed 
2.943   0.012   2.956 
> system.time(qsortMP(x1))
user  system elapsed 
6.767   2.982   9.755 
> system.time(lapply(x1,qsortMP))
user  system elapsed 
2.922   0.011   2.936 
> system.time(mclapply(x1,qsort,mc.cores=4))
user  system elapsed 
4.717   0.776   1.630 
> system.time(mclapply(x1,qsort,mc.cores=8))
user  system elapsed 
3.758   0.983   1.864
> system.time(mclapply(x1,qsortMP,mc.cores=8))
user  system elapsed 
4.931   1.247   1.835 
# 4core
> cl <- makeCluster(4, type = "PSOCK")
> system.time(parLapply(cl, x1, qsort))
user  system elapsed 
0.029   0.002   0.137 
> cl <- makeCluster(8, type = "PSOCK")
> system.time(parLapply(cl, x1, qsort))
user  system elapsed 
0.029   0.002   0.122 


> cl <- makeCluster(8, type = "MPI") # need install.packages("snow") => Rmpi => install.packages("Rmpi", type="source") ==> "console: brew install open-mpi"
# http://www.uio.no/english/services/it/research/hpc/courses/r/2013-04_parallel_r.pdf
cl <- makeCluster(8, type = "MPI")
system.time(parLapply(cl, x1, qsort))
stopCluster(cl)
mpi.exit()  # or mpi.quit(), which quits R as well

> system.time(parLapply(cl, x1, qsort))
user  system elapsed 
1.141   0.009   1.220 