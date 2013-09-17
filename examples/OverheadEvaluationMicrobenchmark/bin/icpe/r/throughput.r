#rm(list=ls(all=TRUE))
#data_fn="tmp/"
#folder_fn="results-benchmark-binary"
#results_fn=paste(data_fn,folder_fn,"/raw",sep="")
#output_fn=paste(data_fn,folder_fn,"/results-throughput.pdf",sep="")

#configs.loop=10
#configs.recursion=c(10)
configs.labels=c("No Probe","Deactivated Probe","Collecting Data","Writing Data")
configs.colors=c("black","red","blue","green")
configs.count=length(configs.labels)

## We assume same amount of data in each category
#results.count=20000000
buckets.count=1000
buckets.size=results.count/buckets.count

pdf(output_fn, width=10, height=6.25, paper="special")

for (cr in configs.recursion) {
  for (cl in (1:configs.loop)) {
    results.ts = matrix(nrow=configs.count,ncol=buckets.count,byrow=TRUE,dimnames=list(configs.labels,c(1:buckets.count)))
    for (cc in (1:configs.count)) {
      results_fn_temp=paste(results_fn, "-", cl, "-", cr, "-", cc, ".csv", sep="")
      results=read.csv2(results_fn_temp,quote="",colClasses=c("NULL","numeric"),comment.char="",col.names=c("thread_id","duration_nsec"),nrows=results.count)
      results["rt_musec"]=results["duration_nsec"]/(1000)
      results$duration_nsec <- NULL
      for (ci in (1:buckets.count)) {
        results.ts[cc,ci] <- (buckets.size * 1000*1000) / sum(results[(((ci-1)*buckets.size)+1):(ci*buckets.size),"rt_musec"])
      }
      rm(results,results_fn_temp)
    }
    ts.plot(
      ts(results.ts[1,],end=results.count,deltat=buckets.size),
      ts(results.ts[2,],end=results.count,deltat=buckets.size),
      ts(results.ts[3,],end=results.count,deltat=buckets.size),
      ts(results.ts[4,],end=results.count,deltat=buckets.size),
      gpars=list(col=configs.colors,xlab="Executions"))
    legend("topright",inset=c(0.01,0.01),legend=c(rev(configs.labels)),lty="solid",col=rev(configs.colors),bg="white",title="Mean throughput of ...",ncol=2)
    title(main=paste("Iteration: ", cl, "  Recursion Depth: ", cr),ylab="Throughput (op/s)")
  }
}
invisible(dev.off())