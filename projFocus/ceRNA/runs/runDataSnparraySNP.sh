#!/bin/bash
#By: J.He
#TODO: 


#~/scripts/projFocus/ceRNA/renameFiles.sh input_renameFiles.txt

#cut -f2 input_renameFiles.txt |wc 
#ls TCGA*|wc
#ls TCGA* > input_makeMat.temp
#grep -f ../TCGA_barcode_all_in_cnv_meth_snp_EXP.txt input_makeMat.temp |sort > input_makeMat.txt
#rm input_makeMat.temp 
#awk 'BEGIN{FS="."}{for (i=1;i<NF-1;i++) printf $i"-";print $(NF-1)"."$NF}' final.header_snp.sorted >input_makMat_SNP_tumorComm.txt 
#for file in `cat input_makMat_SNP_tumorComm.txt`
#do
#  ls -alth $file
#done

###-------step_1------------
#mv brca_snp_tumor_731.mat  brca_snp_tumor_731_with_HWE_filter.mat 
#rerun at Jan27,witouth HWE filtering.
#~/tools/python/Python_current/python /ifs/home/c2b2/ac_lab/jh3283/scripts/projFocus/ceRNA/makeMat_SNP.py -i input_makMat_SNP_tumorComm.txt -o brca_snp_tumor >> log.RUN 
###-------step_2------------
#~/tools/python/Python_current/python /ifs/home/c2b2/ac_lab/jh3283/scripts/projFocus/ceRNA/annot_SNP.py -i brca_snp_tumor_731.mat -d ~/SCRATCH/database/projFocusRef/annot_GenomeWideSNP_6_5cols_clean.txt -o brca_snp_tumor_731.mat.anno


~/tools/python/Python_current/python /ifs/home/c2b2/ac_lab/jh3283/scripts/projFocus/ceRNA/annotSNP_v2.py -i brca_snp_tumor_731.mat -d ~/SCRATCH/database/projFocusRef/annot_GenomeWideSNP_6_hg19_5col.txt -o brca_snp_tumor_731.mat.anno



