# Datastructs
One each will be generated per subject for LFP/CSD data, and spike data (e.g. "AKO01_Data.mat" and "AKO01_SpikeData.mat")

# LFP Data Fields
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

# Spike Data Fields
- **measurement**: see above
- **Condition**: see above
- **BL**: see above
- **stimDur**: see above
- **StimList**: see above
- **SortedSpikes**: epoched detected spike data in cells (e.g. for click trains with 5 stimuli presentations, there would be 1x5 cells). The data within the cells is channel (max 32) x timeaxes (ms) x trials.
- **ContSpikes**: all detected spike data none-epoched
- **ContBandPass**: all data none-epoched nor transformed (channel x timeaxis (ms)) (bandpass filtered from curate (500-3000 Hz) and here downsampled (fs = 1000))
- **contStimChan**: see above (*FileReaderSpike.m* used to read triggers)
