function LFP_Spike(homedir,Groups,Condition)

%% 

% this script is currently just for opening and assigning the spike and lfp
% data to begin working with them.
cd(homedir)
for iGro = 1:length(Groups)

    run([Groups{iGro} '.m']); % brings animals, channels, Cond, Layer
    clear channels Layer

    for iSub = 1:length(animals)

        % load LFP data
        load([animals{iSub} '_Data.mat'],'Data')
        % load spike data
        load([animals{iSub} '_SpikeData.mat'],'SpikeData')


        for iCond = 1:length(Condition)

            % both data structures should match condition lists
            index = StimIndex({Data.Condition},Cond,iSub,Condition);

            % for this subject under this condition: 
            % here's your data for detected spikes and csds
            % both are channel x time(ms) x trial 
            SpikeMatrix = SpikeData(index).SortedSpikes;
            CSDMatrix   = Data(index).sngtrlCSD;

            keyboard

        end % condition (noisebust / spontaneous)
    end % subject
end % group