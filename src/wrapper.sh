#!/bin/bash

#
# args
#

FILEID=$1
FILE=$2
COPYDIR=$3
TAG=$4

echo "[wrapper] FILEID    = " ${FILEID}
echo "[wrapper] FILE      = " ${FILE}
echo "[wrapper] COPYDIR   = " ${COPYDIR}

#
# set up environment
#
CMSSW_VERSION=CMSSW_9_4_6_patch1

###version using cvmfs install of CMSSW
echo "[wrapper] setting env"
export SCRAM_ARCH=slc6_amd64_gcc630
source /cvmfs/cms.cern.ch/cmsset_default.sh
OLDDIR=`pwd`
cd /cvmfs/cms.cern.ch/$SCRAM_ARCH/cms/cmssw/$CMSSW_VERSION/src
#cmsenv
eval `scramv1 runtime -sh`
cd $OLDDIR

# ### version using nfs install of CMSSW
# echo "[wrapper] setting env"
# export SCRAM_ARCH=slc6_amd64_gcc493
# source /nfs-7/cmssoft/cms.cern.ch/cmssw/cmsset_default.sh
# OLDDIR=`pwd`
# cd /nfs-7/cmssoft/cms.cern.ch/cmssw/slc6_amd64_gcc493/cms/cmssw-patch/$CMSSW_VERSION/src
# #cmsenv
# eval `scramv1 runtime -sh`
# cd $OLDDIR

echo

echo "[wrapper] printing env"
printenv
echo 

echo "[wrapper] hostname  = " `hostname`
echo "[wrapper] date      = " `date`
echo "[wrapper] linux timestamp = " `date +%s`
echo "[wrapper] checking input file with ls"
ls -alrth ${FILE}

# catch exit code
if [ $? -ne 0 ]; then
    echo "[wrapper] could not find input file, trying xrootd instead"
    FILESHORT=${FILE#/hadoop/cms}
    xrdfs redirector.t2.ucsd.edu ls ${FILESHORT}
    if [ $? -ne 0 ]; then
	echo "[wrapper] could not find input file with xrootd either, exiting"
	exit 1
    else
	echo "[wrapper] found file with xrootd, will proceed"
	FILE="root://redirector.t2.ucsd.edu/"${FILESHORT}
    fi
fi

#
# untar input sandbox
#

echo "[wrapper] extracting input sandbox"

TEMP=job_input_${TAG}_${FILEID}

cp -r job_input $TEMP

cd $TEMP
echo "[wrapper] input contents are"
ls -a

echo "[wrapper] directory contents are"
ls

#
# run it
#
echo "[wrapper] running: ./CMS4Looper.exe ${FILEID} ${FILE}"

./CMS4Looper.exe ${FILEID} ${FILE}

#
# do something with output
#

echo "[wrapper] output is"
ls

#
# clean up
#

echo "[wrapper] copying file"
OUTPUT=`ls | grep ${FILEID}`
echo "[wrapper] OUTPUT = " ${OUTPUT}

if [ ! -d "${COPYDIR}" ]; then
    echo "creating output directory " ${COPYDIR}
    mkdir ${COPYDIR}
fi

gfal-copy -p -f -t 4200 --verbose file://`pwd`/${OUTPUT} srm://bsrm-3.t2.ucsd.edu:8443/srm/v2/server?SFN=${COPYDIR}/${OUTPUT}

echo "[wrapper] cleaning up"
for FILE in `find . -not -name "*stderr" -not -name "*stdout"`; do rm -rf $FILE; done
echo "[wrapper] cleaned up"
ls

cd ..
rmdir $TEMP

