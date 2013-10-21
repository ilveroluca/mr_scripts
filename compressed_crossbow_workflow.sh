#!/bin/bash

module load pdsh

set -o errexit
set -o nounset

export BOWTIE_INDEXES=/SHARE/USERFS/els7/users/pireddu/alexey/indexes
export CROSSBOW_HOME=/SHARE/USERFS/els7/users/pireddu/alexey/crossbow-compress-1.2.0
export PATH=${CROSSBOW_HOME}/bin/linux64:/SHARE/USERFS/els7/users/pireddu/alexey/programs:${PATH}
export HADOOP_PREFIX=/SHARE/USERFS/els7/users/pireddu/hadoop-1.2.1
export PATH=${HADOOP_PREFIX}/bin:$(echo $PATH | sed -e "s%${HADOOP_PREFIX}/bin:\?%%g")

if [ $# -ne 5 -a $# -ne 6 ]; then
	echo "Usage:  $(basename ${0}) Destination Reference NumReads NumReduce Input1 [Input2]" >&2
	exit 1
fi

HdfsHome=${HdfsHome:-hdfs://oghe070.crs4.int:8020/user/pireddu}
AlexeyScripts="/SHARE/USERFS/els7/users/pireddu/alexey/mr_scripts"
Destination="$(readlink -f ${1})"
Reference="${2}"
NumReads="${3}"
NumReduce="${4}"
Input1="${5}"
Input2="${6:-}"
WorkDir=${HdfsHome}/`basename $(mktemp -u)`
Time="/usr/bin/time -o ${Destination} --append --format \"%C\t%e:%U:%S\" "

function clean_up_tmp() {
	echo "Cleaning up local tmp dir" >&2
	pdsh -w $(tr '\n' , < ${HADOOP_CONF_DIR}/slaves) 'rm /tmp/crossbow-* -rf '
	rm /tmp/crossbow-* -rf
}


echo "Using: " >&2
printf "\tHdfsHome: ${HdfsHome}\n" >&2
printf "\tAlexeyScripts: ${AlexeyScripts}\n" >&2
printf "\tDestination: ${Destination}\n" >&2
printf "\tReference: ${Reference}\n" >&2
printf "\tNumReads: ${NumReads}\n" >&2
printf "\tNumReduce: ${NumReduce}\n" >&2
printf "\tInput1: ${Input1}\n" >&2
printf "\tInput2: ${Input2}\n" >&2
printf "\tWorkDir: ${WorkDir}\n" >&2

echo "Starting:  $(date)" | tee -a ${Destination}

# Merge
# with paired reads give both input directories and -numReduceTasks > 0
Merge="hadoop jar ${HADOOP_PREFIX}/contrib/streaming/hadoop-streaming-1.2.1.jar \
-Dmapred.min.split.size=68300900 \
-Dmap.output.key.field.separator=/ \
-Dmapred.text.key.partitioner.options=-k1,1 \
-Dmapred.text.key.comparator.options=-k1,1 \
-Dmapred.output.compress=true \
-Dmapred.output.compression.codec=org.apache.hadoop.io.compress.BZip2Codec \
-partitioner org.apache.hadoop.mapred.lib.KeyFieldBasedPartitioner \
"

if [ -n "${Input2}" ]; then
	${Time} ${Merge} -input "${Input1}" -input "${Input2}" -output "${WorkDir}/merged" -mapper "${AlexeyScripts}/mapperMerge1.py" -reducer "${AlexeyScripts}/reducerMerge1.py" -numReduceTasks ${NumReduce}
else
	# only difference from above is numReduceTasks
	${Time} ${Merge} -input "${Input1}" -output "${WorkDir}/merged" -mapper "${AlexeyScripts}/mapperMerge1.py" -reducer "${AlexeyScripts}/reducerMerge1.py" -numReduceTasks 0
fi

# launch crossbow
${Time} "${CROSSBOW_HOME}/cb_hadoop" --input "${WorkDir}/merged" --output "${WorkDir}/cb_output" --reference "${HdfsHome}/${Reference}"
clean_up_tmp

echo "Finished:  $(date)" | tee -a ${Destination}

echo "Removing work dir ${WorkDir} and /crossbow" >&2
hadoop dfs -rmr "${WorkDir}" || true
hadoop dfs -rmr "/crossbow" || true

echo "Sleeping 60s while HDFS deletes the output" >&2
sleep 60

exit 0
