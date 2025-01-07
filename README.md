# Spike Field Coherence Repository 

Run everything from *Pipeline_AwakeFmr1.m*
- generates all CSD structures 
- generates all spike structures
- pulls CSD and spike data together to begin working on that code for analysis

## curate output data  

This data was collected with Allego from Neuronexus and then run through Curate for further analysis. 

All curate data requires the *allegoXDatFileReaderR2019b.m* function for conversion to matlab. For that conversion, matlab needs 3 file extensions for each measurement (e.g. "AWT01_01"):
- .xdat.json
- _data.xdat
- _timestamp.xdat

### For LFP Data
Allego data in Curate is 
- low pass filterd at 300 Hz and then
- downsampled by 30 to **fs = 1000**

### For Spike Data
Allego data in Curate is 
- band pass filterd between 500 and 300 Hz
- left at 30 kHz sampling rate 

Videre is then used to detect multi-unit spikes. In order to read those spikes into matlab, all of the above file extensions are needed and the following:
- .kpi
- .kpi.json
- _s0.mat
- _s0.spikes
- _s0.spikes.json

## Datastructs
One each will be generated per subject for LFP/CSD data, and spike data (e.g. "AKO01_Data.mat" and "AKO01_SpikeData.mat")

### LFP Data Fields
- **measurement**: The curate file name associated with this data
- **Condition**: the type of measurement (e.g. "NoiseBurst")
- **BL**: Baseline sampling points (ms) - always 399 so that stim onset is 400 ms
- **stimDur**: sampling points (ms) of stim duration after onset
- **StimList**: list of stimuli for this condition (e.g. click train: [5 20 40 80 120] (Hz) or noise burst: [70] (dB)). A 1 here is used for Spontaneous data where there are no triggers
- **sngtrlCSD**: epoched CSD data in cells (e.g. for click trains with 5 stimuli presentations, there would be 1x5 cells). The data within the cells is channel (max 32) x timeaxes (ms) x trials.
- **sngtrlLFP**: formatted as above but for LFP data
- **sngtrlAvrec**: formated as above but for AVREC CSD data (except that data will just be timeaxis x trials as the avrec was performed over all channels)
- **sngtrlRelres**: formated as AVREC but for RELRES CSD data
- **continousLFP**: all data none-epoched nor transformed (channel x timeaxis (ms)) (low pass filtered (300 Hz) and downsampled (fs = 1000) from curate)
- **contStimChan**: all stim trigger data associated with this LFP data (look into *FileReaderLFP.m* on how to read triggers

### Spike Data Fields
- **measurement**: see above
- **Condition**: see above
- **BL**: see above
- **stimDur**: see above
- **StimList**: see above
- **SortedSpikes**: epoched detected spike data in cells (e.g. for click trains with 5 stimuli presentations, there would be 1x5 cells). The data within the cells is channel (max 32) x timeaxes (ms) x trials.
- **ContSpikes**: all detected spike data none-epoched
- **ContBandPass**: all data none-epoched nor transformed (channel x timeaxis (ms)) (bandpass filtered from curate (500-3000 Hz) and here downsampled (fs = 1000))
- **contStimChan**: see above (*FileReaderSpike.m* used to read triggers)

## Metadata; Description of Stimuli: 

### Spontaneous: 
2+ minutes of cortical activity, no stimuli
Truncated into 2 second epochs

### NoiseBurst: 
70 dB SPL, 100 ms duration, 2 s ITI

### Click Train: 
70 dB SPL, 2 s duration, 2 s ITI
Pseudorandomized presentation of 5, 10, 40, 80, 120 Hz

### Tonotopy: 
70 dB SPL, 200 ms duration, 1 s ITI
Pseudorandomized presentation of 2, 4, 8, 16, 24, 32 kHz pure tones

### Gap ASSR
this stimulus is alternating blocks of 250 ms noise and 250 ms gap-in-noise
gap-in-noise: 75% modulation depth, presented at 40 Hz
6 gap-in-noise blocks surrounded by noise = 3250 ms duration
~520 ms ITI
Pseudorandomized presentatino of 3, 5, 7, 9 ms gap widths