#!/bin/bash

module load samtools-0.1.18

set -o errexit
set -o nounset

export BOWTIE_INDEXES=/SHARE/USERFS/els7/users/pireddu/alexey/indexes
export CROSSBOW_HOME=/SHARE/USERFS/els7/users/pireddu/alexey/crossbow-1.2.0
export PATH=${CROSSBOW_HOME}/bin/linux64:/SHARE/USERFS/els7/users/pireddu/alexey/programs:${PATH}

if [ $# -ne 3 -a $# -ne 4 ]; then
	echo "Usage:  $(basename ${0}) Destination Reference Input1 [Input2]" >&2
	exit 1
fi

Destination="$(readlink -f ${1})"
Reference="${2}"
Input1="$(readlink -f ${3})"
if [ -n "${4:-}" ]; then
	Input2="$(readlink -f ${4})"
else
	Input2=""
fi
WorkDir="$(mktemp -d --tmpdir=$H7)"
Time="/usr/bin/time -o ${Destination} --append --format \"%C\t%e:%U:%S\" "
nthreads=8

echo "Using: " >&2
printf "\tDestination: ${Destination}\n" >&2
printf "\tReference: ${Reference}\n" >&2
printf "\tInput1: ${Input1}\n" >&2
printf "\tInput2: ${Input2}\n" >&2
printf "\tWorkDir: ${WorkDir}\n" >&2

#function cleanup() {
#	rm -rf "${WorkDir}"
#}
#
#trap cleanup ERR

echo "Starting:  $(date)" | tee -a ${Destination}
#set -x
cd ${WorkDir}
if [ -n "${Input2}" ]; then
	${Time} bowtie -t -S -p ${nthreads} ${Reference} -X 500 -M 1 -1 ${Input1} -2 ${Input2} "${WorkDir}/sam" 2>&1 | grep -v "Warning: Exhausted best-first chunk memory for read"
else
	${Time} bowtie -t -S -p ${nthreads} ${Reference} -X 500 -M 1 ${Input1} "${WorkDir}/sam" 2>&1 | grep -v "Warning: Exhausted best-first chunk memory for read"
fi
${Time} samtools view -@ ${nthreads} -bS -o ${WorkDir}/bam ${WorkDir}/sam
${Time} samtools sort -@ ${nthreads} ${WorkDir}/bam ${WorkDir}/sorted
#${Time} samtools faidx ${WorkDir}/sorted.bam
${Time} samtools mpileup -uf ${BOWTIE_INDEXES}/${Reference}.fasta ${WorkDir}/sorted.bam | bcftools view -bvcg - > ${WorkDir}/raw.bcf
${Time} bcftools view ${WorkDir}/raw.bcf | vcfutils.pl varFilter -D100 > ${WorkDir}/vcf 
echo "Finished:  $(date)" | tee -a ${Destination}

exit 0

