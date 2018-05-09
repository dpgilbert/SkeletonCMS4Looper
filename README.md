Edit src/ScanChain.cc to add analysis code and write TH1s etc to output. Edit interface/ScanChain.h as necessary.

Test interactively with
```bash
./CMS4Looper.exe OUTPUT_NAME INPUT_FILE
```

In src/
```bash
make
./writeConfig.sh /Directory/containing/input/files/to/run/on TAG_FOR_RUN
condor_submit condor/condor_file_you_just_made.cmd
```
As a courtesy, try to submit only ~200 jobs at most at any one time in this way (there is 1 job created per input ntuple). Monitor with condor_q. Output will show up in your hadoop home inside LooperOutput.
