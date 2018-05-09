// A skeleton cms4 looper - Dylan Gilbert - May 2018

#include "../interface/ScanChain.h"

using namespace std;
using namespace tas;

void CMS4Looper::ScanChain (TChain * tree, const char* outname) {
  TH1::SetDefaultSumw2(true);

  // Book histograms

  cms3.Init(tree); // Called cms3 for legacy reasons...
  const int nEvents = tree->GetEntries();
  const int event_max = nEvents;

  for (int event = 0; event < event_max; event++) {
    if ( (event+1) % 1000 == 0 ) cout << 100. * event / event_max << "%" << endl;
    tree->LoadTree(event);
    cms3.GetEntry(event);
    

  } // Event Loop

  cout << "Finished event loop." << endl;

  // Post-processing

  cout << "About to save histograms." << endl;

  TFile * OutFile_ = new TFile(Form("%s.root", outname), "RECREATE");
  OutFile_->cd();
  // Write histograms
  OutFile_->Close();
  
}

int main (int argc, char ** argv) {
  if (argc < 3) {
    cout << "USAGE: ./ScanChain.exe <tag> <filename>" << endl;
    return 1;
  }

  char * outfileid = argv[1]; 
  char * filename = argv[2]; 

  TChain *chain = new TChain("Events");
  chain->Add(filename);
  cout << "Added " << filename << " to TChain" << endl;

  CMS4Looper cms4l;
  cms4l.ScanChain(chain,outfileid);
  return 0;
}
