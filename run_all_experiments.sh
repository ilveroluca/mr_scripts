#!/bin/bash

nNodes=8
nSamples=3
ResultsFileTemplate="d%s_nodes_%s.results"

RootDir=/SHARE/USERFS/els7/users/pireddu/alexey
Workflow=crossbow_workflow.sh
LogFile="${RootDir}/automatic_${nNodes}_node_log"

set -o errexit
set -o nounset

function log() {
	echo $(date "+%Y-%m-%d %H:%M:%S") $* >> ${LogFile}
}

function start_dataset() {
	log "============== start $* ================"
}

function end_dataset() {
	log "============== end $* ================"
}


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
	"${RootDir}/${Workflow}" $(printf ${ResultsFileTemplate} $nNodes d1) TAIR10.jar 1 $(($nNodes * 4 - 1)) d1/Schneeberger.2009.single_end.fixed >> ${LogFile} 2>&1
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
	"${RootDir}/${Workflow}" $(printf ${ResultsFileTemplate} $nNodes d2_half) TAIR10.jar 1 $(($nNodes * 4 - 1)) d2/Galvao.2012.reads1_trimmed.fq >> ${LogFile} 2>&1
done

end_dataset d2_half

################# d2 full
start_dataset d2_full

log "Launching experiments"
for i in $(seq 1 $nSamples) ; do
	log "sample ${i} of ${nSamples}"
	"${RootDir}/${Workflow}" $(printf ${ResultsFileTemplate} $nNodes d2_full) TAIR10.jar 2 $(($nNodes * 4 - 1)) d2/Galvao.2012.reads{1,2}_trimmed.fq >> ${LogFile} 2>&1
done

end_dataset d2_full

log "Clearing space"
hadoop dfs -rmr /user/pireddu/d2


############ d3
log "loading data for d3"

cd ${RootDir}/datasets/d3
hadoop dfs -mkdir d3
hadoop dfs -put SRR611085_1.fastq d3/ &
hadoop dfs -put SRR611085_2.fastq d3/ &
log "Waiting for copy to finish"
wait

log "Copy finished.  Waiting..."
sleep 30


################# d3 half
start_dataset d3_half

log "Launching experiments"
for i in $(seq 1 $nSamples) ; do
	log "sample ${i} of ${nSamples}"
	"${RootDir}/${Workflow}" $(printf ${ResultsFileTemplate} $nNodes d3_half) TAIR10.jar 1 $(($nNodes * 4 - 1)) d3/SRR611085_1.fastq >> ${LogFile} 2>&1
done

end_dataset d3_half

################# d3 full
start_dataset d3_full

log "Launching experiments"
for i in $(seq 1 $nSamples) ; do
	log "sample ${i} of ${nSamples}"
	"${RootDir}/${Workflow}" $(printf ${ResultsFileTemplate} $nNodes d3_full) TAIR10.jar 2 $(($nNodes * 4 - 1)) d3/SRR611085_{1,2}.fastq >> ${LogFile} 2>&1
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
	"${RootDir}/${Workflow}" $(printf ${ResultsFileTemplate} $nNodes d4_half) TAIR10.jar 1 $(($nNodes * 4 - 1)) d4/reads1.fq >> ${LogFile} 2>&1
done

end_dataset d4_half

################# d4 full
start_dataset d4_full

log "Launching experiments"
for i in $(seq 1 $nSamples) ; do
	log "sample ${i} of ${nSamples}"
	"${RootDir}/${Workflow}" $(printf ${ResultsFileTemplate} $nNodes d4_full) TAIR10.jar 2 $(($nNodes * 4 - 1)) d4/reads{1,2}.fq >> ${LogFile} 2>&1
done

end_dataset d4_full

log "Clearing space"
hadoop dfs -rmr /user/pireddu/d4

log "All datasets from d1 to d4 finished"
echo "Hey, the runs are finished" | mail -s "experiments finished" pireddu@crs4.it
