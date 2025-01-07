# curate output data  

This data was collected with Allego from Neuronexus and then run through Curate for further analysis. 

All curate data requires the *allegoXDatFileReaderR2019b.m* function for conversion to matlab. For that conversion, matlab needs 3 file extensions for each measurement (e.g. "AWT01_01"):
- .xdat.json
- _data.xdat
- _timestamp.xdat

## For LFP Data
Allego data in Curate is 
- low pass filterd at 300 Hz and then
- downsampled by 30 to **fs = 1000**

## For Spike Data
Allego data in Curate is 
- band pass filterd between 500 and 300 Hz
- left at 30 kHz sampling rate 

Videre is then used to detect multi-unit spikes. In order to read those spikes into matlab, all of the above file extensions are needed and the following:
- .kpi
- .kpi.json
- _s0.mat
- _s0.spikes
- _s0.spikes.json


