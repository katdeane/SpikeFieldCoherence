function [timerange,stimIn,data] = FileReaderSpike(file,channels)
% This converts the data from allego/curate and downsamples it to fs = 1000

% for spikes, the MINIMUM files needed here are 
% *_Spikes.xdat.json
% *_Spikes_data.xdat (the big one)
% *_Spikes_timestamp.xdat

% initalized NeuroNexus conversion function
reader = allegoXDatFileReaderR2019b;

timerange = reader.getAllegoXDatTimeRange(file);
signalStruct = reader.getAllegoXDatAllSigs(file, timerange);
% stimulus timing data
stimIn = downsample(signalStruct.signals(33,:),30); % microvolts

% data channels:
if exist('channels','var')
    % take the channels input variable
    data = downsample(signalStruct.signals(channels,:),30);
else % or
    % allow the user to change how many channels are analyzed
    prompt   = {'First Chan:','Last Chan:'};
    dlgtitle = 'Channels';
    dims     = [1 35];
    definput = {'1','32'};
    channels = inputdlg(prompt,dlgtitle,dims,definput);
    data = downsample(signalStruct.signals(str2double(channels{1}):str2double(channels{2}),:),30);
end