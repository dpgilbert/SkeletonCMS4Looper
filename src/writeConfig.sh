#!/bin/bash

while  ! voms-proxy-info -exist
do echo "No Proxy found issuing \"voms-proxy-init -voms cms\""
   voms-proxy-init -hours 168 -voms cms
done

DATADIR=$1
TAG=$2

UNIVERSE="vanilla"
EXE="wrapper.sh"
INPUT="wrapper.sh, job_input/input.tar.gz"
# can add other US sites here if desired
SITE="UAF"
SUBMITLOGDIR="${PWD}/submit_logs"
JOBLOGDIR="${PWD}/job_logs"
PROXY=$(voms-proxy-info -path)
USERNAME=$(whoami)

LOGDIR="/data/tmp/$USER/condor_submit_logs/LooperOutput"
OUTDIR="/data/tmp/$USER/condor_job_logs/LooperOutput"
LOG="${LOGDIR}/condor_`date "+%m_%d_%Y"`.log"
OUT="${OUTDIR}/1e.\$(Cluster).\$(Process).out"
ERR="${OUTDIR}/1e.\$(Cluster).\$(Process).err"

if [ ! -d "${LOGDIR}" ]; then
    echo "[writeConfig] creating log directory " ${LOGDIR}
    mkdir -p ${LOGDIR}
fi

if [ ! -d "${OUTDIR}" ]; then
    echo "[writeConfig] creating job output log directory " ${OUT}
    mkdir -p ${OUT}
fi

#
# prepare input sandbox
#

DIR=$PWD

COPYDIR=/hadoop/cms/store/user/${USERNAME}/LooperOutput/${TAG}
echo "[writeConfig] running on dataset ${DATADIR}"
echo "[writeConfig] copying output to ${COPYDIR}"

if [ ! -d "${COPYDIR}" ]; then
    echo "[writeConfig] creating job output directory " ${COPYDIR}
    mkdir -p ${COPYDIR}
fi

#
# write configuration
#
   
echo "
universe=${UNIVERSE}
when_to_transfer_output = ON_EXIT
#the actual executable to run is not transfered by its name.
#In fact, some sites may do weird things like renaming it and such.
transfer_input_files=${INPUT}
+DESIRED_Sites=\"${SITE}\"
Requirements = (Machine != \"uaf-1.t2.ucsd.edu\")
+Owner = undefined
log=${LOG}
output=${OUT}
error =${ERR}
notification=Never
x509userproxy=${PROXY}
" > condor/condor_${TAG}.cmd

    #
    # now set the rest of the arguments 
    # for each job
    # 

    for FILE in `ls ${DATADIR}/*.root`; do
        echo "
executable=${EXE}
transfer_executable=True
arguments=`echo ${FILE##*/} | sed 's/\.root//g'` ${FILE} ${COPYDIR} ${TAG}
queue
" >> condor/condor_${TAG}.cmd
    done

echo "[writeConfig] wrote condor_${TAG}.cmd" 
