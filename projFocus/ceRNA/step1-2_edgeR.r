#!/usr/bin/Rscript
#Author: Jing He
#Date:24 Oct,2013 
#Last Updated:
#COMMENTS: need edgeR installed; 
#input: <string:path you wnat your results to be> 
# 		  <string:name of your design file(4 cols, tab delimite:example)
#		    <string:name of count matrix file>
# 		  <string:name of your output files>
#output: <file:pdf of 2 plots> <file: txt of differetial expresssed genes>
####TODO: need more development

sysInfo = Sys.info()
if(sysInfo['sysname']=="Darwin" ){
  source("/Volumes/ifs/home/c2b2/ac_lab/jh3283/scripts/projFocus/ceRNA/projFocusCernaFunctions.R")
  setwd("/Volumes/ifs/data/c2b2/ac_lab/jh3283/projFocus/result/02022014/expression/")
  rootd = "/Volumes/ifs/scratch/c2b2/ac_lab/jh3283/"
  figd = "/Volumes/ifs/scratch/c2b2/ac_lab/jh3283/projFocus/ceRNA/report/figure/"
}else if(sysInfo['sysname']=="Linux" ){
  source("/ifs/home/c2b2/ac_lab/jh3283/scripts/projFocus/ceRNA/projFocusCernaFunctions.R")
  print("working from Linux")
  setwd("/ifs/data/c2b2/ac_lab/jh3283/projFocus/result/02022014/expression")
  rootd = "/ifs/data/c2b2/ac_lab/jh3283/projFocus/"
  figd = "/ifs/data/c2b2/ac_lab/jh3283/projFocus/report/topDown_02042014/fig/"
}
args = getArgs()
usage = "Usage: Rscript bridegCeRAN.r --  file <gene.list>  "
example = "Example: /ifs/home/c2b2/ac_lab/jh3283/tools/R/R_current/bin/Rscript /ifs/home/c2b2/ac_lab/jh3283/scripts/projFocus/ceRNA/filterGrplasso.r --file grplasso_coeff --cut 0.05 --out gcGenes_GeneVarNet"
if(length(args) < 3 || is.null(args)){
  print(usage)
  print(example)
  print(args)
  stop("Input parameter error!")
}else{
  print(args)
}

setwd(system("pwd",intern=T))
# cwd         = getwd()
# tumor  = args['tumor'] 
# normal = args['normal']
# output = args['out'] 
# print(paste("current working directory:",cwd))


##-----test
tumor  =  "brca_exp_level3_02042014.mat"
normal =  "brca_expNormal_level3_02042014.mat"
output =  "brca_ucCeRNETCancerGeneDEG_edgeR_02042014"
genelist = "/Volumes/ifs/data/c2b2/ac_lab/jh3283/projFocus/data/cancer.gene_UCceRNET.list"
# genelist = "/Volumes/ifs/home/c2b2/ac_lab/jh3283/SCRATCH/projFocus/ceRNA/data/tcgaPaper/tcga.16papers.gene.freqBg1.brcaCeRNETRegulator"
#  genelist = "/Volumes/ifs/scratch/c2b2/ac_lab/jh3283/projFocus/ceRNA/data/tcgaPaper/tcga.16papers.gene.freqBg1"
# genelist = "/Volumes/ifs/scratch/c2b2/ac_lab/jh3283/projFocus/ceRNA/data/tcgaPaper/tcga.16papers.genename"

reportDir = "/Volumes/ifs/data/c2b2/ac_lab/jh3283/projFocus/report/topDown_02042014/fig"
outputPDF = paste(reportDir,"/",output,".pdf",sep="")
##----------------------------
getData = function(file,type="T",glist){
  gene = unlist(read.table(glist))
  data = read.delim(file,header=T)
  gene = gene[ gene %in% data[,1] ]
  data = data[data[,1] %in% gene,-1]
  rownames(data)=gene
  colnames(data) = vapply(colnames(data),FUN=function(x){substr(x,start=9,stop=16)},'a')
  
  sample = colnames(data)
  design = rep(type,ncol(data))
  names(design) = sample
  return(list(data=data,design=design,gene=gene))
}

##--------
#load data
setwd("/Volumes/ifs/data/c2b2/ac_lab/jh3283/projFocus/result/02022014/expression")

dataT = getData(tumor,type='tumor',genelist)
dataN = getData(normal,type='normal',genelist)
cntSampleT = ncol(dataT$data)
cntSampleN = ncol(dataN$data)
cntGene = nrow(dataT$data)
dataMat = cbind(dataT$data,dataN$data)
gene = dataT$gene
row.names(dataMat) = gene

design = c(dataT$design,dataN$design)
condition <- factor( design )

##----------------------------
#fitting model
library(edgeR)
y <- DGEList(counts=dataMat,group=condition)
y <- calcNormFactors(y, method="TMM") 
y <- estimateCommonDisp(y)
y <- estimateTagwiseDisp(y)
et <- exactTest(y)
# save(et,file=paste(output_file,".rda",sep=""))

###----------------------------
de <- decideTestsDGE(et, p=0.05, adjust.method="BH")
detags <- rownames(topTags(et, n=50))

require(limma)
designMat = model.matrix(~design)
dataMatVoom = voom(as.matrix(dataMat),designMat,plot=TRUE)
outputIndex = which(abs(et$table$logFC) >1 & et$table$PValue < 0.05,arr.ind=T) ##2 FC
dataMatVoomDegTumor = dataMatVoom$E[outputIndex,which(as.character(design)=="tumor")]
dataMatVoomDeg  = dataMatVoom$E[outputIndex,]


#output
pdf(outputPDF)
plotMDS(y, cex=0.5)
plotBCV(y, cex=0.4)
plotSmear(et, de.tags=detags)
abline(h = c(-1, 1), col = "blue")
require(gplots)
mycol = bluered(256)
heatmap.2(dataMatVoom$E,col=mycol,trace="none",cexRow=0.3,cexCol=0.3,main="All ucCeRNET cancer Genes")
heatmap.2(dataMatVoomDeg,col=mycol,trace="none",cexRow=0.3,cexCol=0.3, main = "FC>2 ucCeRNET Cancer Genes")
dev.off()

# outTag <- topTags(et,n=Inf,adjust.method="bonferroni",sort.by="p.value")
# write.table(outTag,file=paste(output,".DEG.txt",sep=""),sep="\t",quote=F)

outTagMat_header <- as.matrix(t(c("Gene",colnames(dataMatVoom))))
write.table(outTagMat_header,file=paste(output,"DEG.mat",sep=""),sep="\t",quote=F,col.names=F,row.names=F)
write.table(outTagMat,file=paste(output,"DEG.mat",sep=""),sep="\t",quote=F,append = TRUE,col.names=F)
