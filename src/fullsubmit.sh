#!/bin/bash

condor_submit condor/condor_DY.cmd
condor_submit condor/condor_TTSL_fromT.cmd
condor_submit condor/condor_TTSL_fromTbar.cmd
condor_submit condor/condor_TTDL.cmd
condor_submit condor/condor_WJets.cmd

# Output will show up in /hadoop/cms/store/user/${USERNAME}/LooperOutput/