load("~/Dropbox/MDMRT/Tasks/MDMRT_scan/imaging_analyses/activation_table/HOA_rois.RData")

activations=data.frame(contrast=c(),cluster=c(),region=c(),numvox=c())
#con="model007task001cope014"
#con="model007task002cope010"
#con="model007_task001cope14_min_task002cope010"
#con="model002t1c2vt2c2_conj_model001t3c14"
#con="model001_task003_cope14"
#con="model002t1c1vt2c1"
#con="model003t1c2vt2c2"
#con="model010_task001_cope011"
con="model038_task001_cope006"
clust=0
for (c in 3:1){
	 clust=clust+1
	 tmp=read.table(paste("~/Dropbox/MDMRT/Tasks/MDMRT_scan/imaging_analyses/activation_table/",con,"_cluster_cluster",c,".txt",sep=""),header=T)
	 tmp=cbind(tmp,HOA_rois)
	 tmp=subset(tmp,tmp$numvox>9)
	 tmp=tmp[order(-tmp$numvox),]
	 activations=rbind(activations,data.frame(contrasts=rep(con,length(tmp$numvox)),cluster=rep(clust,length(tmp$numvox)),region=tmp$Region.Name,numvox=tmp$numvox))	
	 }

write.table(activations, file=paste("~/Dropbox/MDMRT/Tasks/MDMRT_scan/imaging_analyses/activation_table/",con,"_table.csv",sep=""),row.names = F, sep=",")
