#!/usr/bin/python
# Desp: create to generate snp-sample matrix; using only 2 filters compared to makeMat_SNP_v1.py 
# input: <file contains the input file names for tcga snp level2 data>
# output: <file including snps after filtering> <file: stats about the filtering>
# J.HE
# Last updated: Jan 27,2014

import os
import math
import linecache
import sys, getopt

#------------test--------
#inp = "input_test"
#outp = "output_test"
#outpstat = outp + "_stat"
#------------test end ---

#get command line args
argv = sys.argv[1:]
inp = ''
outp = ''
usage = 'Usage:makeMat_SNP.py -i <input file:list of level2 snp file name.> -o <outputfile: output snp matrix file name>'
example = '~/tools/python/Python_current/python makMat_SNP.py -i /ifs/scratch/c2b2/ac_lab/jh3283/projFocus/ceRNA/data/snpArray/input_makMat_SNP_tumorComm.txt -o /ifs/scratch/c2b2/ac_lab/jh3283/projFocus/ceRNA/data/snpArray/brca_snp_tumor_731.mat' 

try:
  opts, args = getopt.getopt(argv,"hi:o:",["ifile=","ofile="])
except getopt.GetoptError:
  print usage + "\n" + example
  sys.exit(2)
for opt, arg in opts:
  if opt == '-h':
    print usage + "\n" + example 
    sys.exit()
  elif opt in ("-i", "--ifile"):
    inp = arg
  elif opt in ("-o", "--ofile"):
    outp = arg
    outpstat = outp + "_stat"

conf_cut = 0.1 #confidence > 0.1
maf_cut = 0.05 #minor allele frequence maf > 5%

print "input file:" + inp
print "output file:" + outp
print "output stat file:" + outpstat
print "confidence cutoff:" + str(conf_cut)
print "MAF cutoff:" + str(maf_cut)

####------------------function---start---------
# get the number of lines in one file
def file_len(fname):
    with open(fname) as f:
        for i, l in enumerate(f):
            pass
    return i + 1

def sysTime():
	time=os.system("date|awk '{print $4}'")
	print str(time)

def get_nth_line(f,n):
	# with open(f) as ff:
	line = linecache.getline(f,n)
	[key, gt, conf] = line.split("\t")
	if n % 10 == 0 and n > 10:
		linecache.clearcache()
	return key,gt,conf.strip()

def get_MAF(gtlist):
	return 1 - sum(map(int, gtlist)) / (2*len(gtlist))

def logfac(n):
	return math.log(math.factorial(int(n)))
####------------------function---end---------


nsample = file_len(inp)
sampleSize_cut = int(0.1 * nsample) 

with open(inp) as inf:
		for i, line in enumerate(inf):
			if i == 1:
				line_crt = line.strip()
				nsnp = file_len(line_crt)
				break

outp = outp +"_" + str(nsample) + ".mat"
outpstat = outpstat +"_" +  str(nsample) + ".txt"

cnt_f1 = 0
cnt_f2 = 0
fout = open(outp,'w')
#the header
with open(inp) as inf:
  allsamples = [" "] * nsample
  for i, line in enumerate(inf):
  	line_crt = line.strip()
	allsamples[i] = line_crt
  fout.write("Identifier\t"+"\t".join(allsamples) + "\n")    

#all level2 files 
farray=[]
with open(inp) as f:
	for line in f.readlines():
		line_crt = line.strip()
		farray.append(line_crt)	

a=[open(i,'r',81920) for i in farray]
for k in range(nsnp):
	gt = [0] * nsample
	conf = [0] * nsample
	if k < 2:
		for f in a:
			line = f.next()
			pass
		continue
	else :
		ncol = 0
		for f in a:
			line = f.next()
			[key, g, c] = line.split("\t")
			gt[ncol] = int(g)
			conf[ncol] = float(c)
			ncol = ncol + 1
		samples=allsamples 
		allgt = gt		
		# 	filter1  confidence 
		temp = [j for j in range(len(conf)) if(conf[j] < conf_cut)]
		if len(temp) >= (nsample -sampleSize_cut):
		#  	filter2  maf
		   	maf = get_MAF(gt)
			if(maf > maf_cut):
			        fout.write(key +"\t"+ "\t".join(map(str,gt)) + "\n")
			else:
				cnt_f2 = cnt_f2 + 1
				continue
		else:
			cnt_f1 = cnt_f1 + 1
			continue



fout2 = open(outpstat,'w')
fout2.write("Number_of_total_snp" + "\t" + "filtered_out_Missing_GT" + \
	"\t" + "filtered_out_MAF" + \
	"\t"+ "filtered_out_HWE_Test" + \
	"\t" + "Number_of_final" + "\n")
fout2.write(str(nsnp) + "\t" + str(cnt_f1) + "\t" + str(cnt_f2) + "\t" + "\t" + \
	str(nsnp - cnt_f1 - cnt_f2 ) + "\n")
	# str(nsnp - cnt_f1 - cnt_f2) + "\n")
fout.close()
fout2.close()


