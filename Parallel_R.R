library(parallel)
library(rjags)

cl <- makeCluster(4)                       # Request # cores
clusterExport(cl, c("dwri.od.data", "inits", "params", "Nst")) # Make these available to each core
clusterSetRNGStream(cl = cl, 1259)

system.time({ # no status bar (% complete) when run in parallel
  out <- clusterEvalQ(cl, {
    library(rjags)
    jm <- jags.model("dwri_od3.txt", dwri.od.data, inits, n.adapt=300000, n.chains=1) # Compile model and run burnin
    out <- coda.samples(jm, params, n.iter=100000, thin=40) # Sample from posterior distribution
    return(as.mcmc(out))
  })
}) # 

stopCluster(cl) # need this for R to release RAM from each core