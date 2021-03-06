#!/usr/bin/env python
#J.HE
#Desp: for projFocus ceRNA, given grplasso result, cross validation it using reference (1k genome, uk10k)
#Input: -i -d -o


##----------------------------
#functions

def getElement(a,l):
	[res for ele in l if ele==a]
	return res
##----------------------------
import os,sys,getopt
import re

argv = sys.argv[1:]
inputfile  = ''
inputDB = ''
output   = ''

usage = '~/tools/python/Python_current/python /ifs/home/c2b2/ac_lab/jh3283/scripts/projFocus/ceRNA/validSNP.py -i ~/SCRATCH/projFocus/ceRNA/knowledgeBase/GWAS'
example = 'python /ifs/home/c2b2/ac_lab/jh3283/scripts/projFocus/ceRNA/validSNP.py -i <input grplasso result file> -d <input snp annoataed matrix> -o <output>'

try:
  opts,args = getopt.getopt(argv,"hi:d:o:")
except getopt.GetoptError:
  print usage + "\n" + example
  sys.exit()

for opt, arg in opts:
    if opt == '-h':
          print usage +"\n" + example
          sys.exit()
    elif opt in ("-i"):
          inputfile = arg
    elif opt in ("-d"):
          inputDB = arg
    elif opt in ("-o"):
          output = arg

print inputfile
print inputDB
print output
pcut = 0.05

rsidPass = []
cnt = 0 
with open(inputfile) as f:
	for line in f.readlines():
		# if re.match("^rs",line):
		if cnt > 0: 
			[col1, col2] = line.strip().split("\t")
			if re.match("^rs",col1) and float(col2) > 0:
				rsidPass.append(col1)
		if cnt ==0 :
			[col1, col2] = line.strip().split("\t")
			if float(col2.split(":")[-1]) > pcut:
				print (col2.split(":")[-1])
				print("no significant \t" + inputfile )
				sys.exit()
			else:
				pass
		cnt = cnt + 1 	
		continue

cntRsid = 0
cntPass = len(rsidPass)
rsidPassInDB = []
with open(inputDB) as f:
	for line in f.readlines():
		line = line.strip()
		if line in rsidPass:
			rsidPassInDB.append(line)
			cntRsid = cntRsid + 1
			if cntRsid == cntPass:
				break
		else:
			continue
rsidPassNew = list(set(rsidPass)-set(rsidPassInDB))

outputH = open(output,'w')
outputH.write("\n".join(rsidPassNew))
outputH.close()
print "#---END---"

