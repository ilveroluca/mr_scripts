#!/bin/bash

#set -x

set -o errexit
set -o nounset

nNodes=${nNodes:-7}
nSamples=${nSamples:-3}
HADOOP_CONF_DIR=${HADOOP_CONF_DIR:-/SHARE/USERFS/els7/users/pireddu/hadoop-1.2.1/crs4-conf}
HdfsHome=${HdfsHome:-hdfs://oghe070.crs4.int:8020/user/pireddu}

export HADOOP_CONF_DIR HdfsHome

ResultsFileTemplate="d%s_nodes_%s.results"

RootDir=/SHARE/USERFS/els7/users/pireddu/alexey
AlexeyScripts="${RootDir}/mr_scripts"
Workflow="${AlexeyScripts}/crossbow_workflow.sh"

LogFile="${RootDir}/$(date +"%F_%T")_automatic_${nNodes}_node_log"

#################### Error trap ######################

# a generic error trap that prints the command that failed before exiting the script.
function error_trap() {
	printf -v message "Unexpected error.  Command: %s\nExiting\n" "${BASH_COMMAND}"
	printf "${message}" >&2
	printf "${message}" >> ${LogFile}
	exit 1
}

trap error_trap ERR

function log() {
	echo -e $(date +"%F %T") -- $@ >> ${LogFile}
	return 0
}

function start_dataset() {
	log "============== start $* ================"
}

function end_dataset() {
	log "============== end $* ================"
}

function error() {
	log "There's been an error: " $@
	exit 1
}

if [ ! -d "${RootDir}" ]; then
	error "Couldn't find RootDir ${RootDir}"
fi

if [ ! -d "${AlexeyScripts}" ]; then
	error "Couldn't find AlexeyScripts directory ${AlexeyScripts}"
fi

if [ ! -f "${Workflow}" ]; then
	error "Workflow path ${Workflow} doesn't point to a file"
fi


log "nNodes: ${nNodes}"
log "nSamples: ${nSamples}"
log "HADOOP_CONF_DIR: ${HADOOP_CONF_DIR}"
log "HdfsHome: ${HdfsHome}"

################# d1
start_dataset d1

cd ${RootDir}/datasets/d1
log "Loading data"
hadoop dfs -mkdir d1
hadoop dfs -put Schneeberger.2009.single_end.fixed d1/
log "Data loaded.  Waiting..."
sleep 30

log "Launching experiments"
for i in $(seq 1 $nSamples) ; do
	log "sample ${i} of ${nSamples}"
	"${Workflow}" $(printf ${ResultsFileTemplate} $nNodes d1) TAIR10.jar 1 $(($nNodes * 4 - 1)) d1/Schneeberger.2009.single_end.fixed >> ${LogFile} 2>&1
done

end_dataset d1

log "Clearing space"
hadoop dfs -rmr /user/pireddu/d1

############ d2
log "loading data for d2"

cd ${RootDir}/datasets/d2
hadoop dfs -mkdir d2
hadoop dfs -put Galvao.2012.reads1_trimmed.fq d2/ &
hadoop dfs -put Galvao.2012.reads2_trimmed.fq d2/ &
log "Waiting for copy to finish"
wait

log "Copy finished.  Waiting..."
sleep 30

################# d2 half
start_dataset d2_half

log "Launching experiments"
for i in $(seq 1 $nSamples) ; do
	log "sample ${i} of ${nSamples}"
	"${Workflow}" $(printf ${ResultsFileTemplate} $nNodes d2_half) TAIR10.jar 1 $(($nNodes * 4 - 1)) d2/Galvao.2012.reads1_trimmed.fq >> ${LogFile} 2>&1
done

end_dataset d2_half

################# d2 full
start_dataset d2_full

log "Launching experiments"
for i in $(seq 1 $nSamples) ; do
	log "sample ${i} of ${nSamples}"
	"${Workflow}" $(printf ${ResultsFileTemplate} $nNodes d2_full) TAIR10.jar 2 $(($nNodes * 4 - 1)) d2/Galvao.2012.reads{1,2}_trimmed.fq >> ${LogFile} 2>&1
done

end_dataset d2_full

log "Clearing space"
hadoop dfs -rmr /user/pireddu/d2


############ d3
log "loading data for d3"

cd ${RootDir}/datasets/d3
hadoop dfs -mkdir d3
hadoop dfs -put SRR611085_1_fixed.fastq d3/ &
hadoop dfs -put SRR611085_2_fixed.fastq d3/ &
log "Waiting for copy to finish"
wait

log "Copy finished.  Waiting..."
sleep 30


################# d3 half
start_dataset d3_half

log "Launching experiments"
for i in $(seq 1 $nSamples) ; do
	log "sample ${i} of ${nSamples}"
	"${Workflow}" $(printf ${ResultsFileTemplate} $nNodes d3_half) TAIR10.jar 1 $(($nNodes * 4 - 1)) d3/SRR611085_1_fixed.fastq >> ${LogFile} 2>&1
done

end_dataset d3_half

################# d3 full
start_dataset d3_full

log "Launching experiments"
for i in $(seq 1 $nSamples) ; do
	log "sample ${i} of ${nSamples}"
	"${Workflow}" $(printf ${ResultsFileTemplate} $nNodes d3_full) TAIR10.jar 2 $(($nNodes * 4 - 1)) d3/SRR611085_{1,2}_fixed.fastq >> ${LogFile} 2>&1
done

end_dataset d3_full

log "Clearing space"
hadoop dfs -rmr /user/pireddu/d3


############ d4
log "loading data for d4"

cd ${RootDir}/datasets/d4
hadoop dfs -mkdir d4
hadoop dfs -put reads1.fq d4/ &
hadoop dfs -put reads2.fq d4/ &
log "Waiting for copy to finish"
wait

log "Copy finished.  Waiting..."
sleep 30


################# d4 half
start_dataset d4_half

log "Launching experiments"
for i in $(seq 1 $nSamples) ; do
	log "sample ${i} of ${nSamples}"
	"${Workflow}" $(printf ${ResultsFileTemplate} $nNodes d4_half) TAIR10.jar 1 $(($nNodes * 4 - 1)) d4/reads1.fq >> ${LogFile} 2>&1
done

end_dataset d4_half

################# d4 full
start_dataset d4_full

log "Launching experiments"
for i in $(seq 1 $nSamples) ; do
	log "sample ${i} of ${nSamples}"
	"${Workflow}" $(printf ${ResultsFileTemplate} $nNodes d4_full) TAIR10.jar 2 $(($nNodes * 4 - 1)) d4/reads{1,2}.fq >> ${LogFile} 2>&1
done

end_dataset d4_full

log "Clearing space"
hadoop dfs -rmr /user/pireddu/d4

log "All datasets from d1 to d4 finished"
echo "Hey, the runs on $(hostname) are finished" | mail -s "experiments finished" pireddu@crs4.it
