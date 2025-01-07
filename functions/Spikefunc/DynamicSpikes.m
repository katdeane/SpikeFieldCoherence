function DynamicSpikes(homedir, Groups, Condition,type)
%% Dynamic CSD 

%   This script takes input from groups/ and data/. It calculates 
%   and stores continous spike and sorted spike data, the continuous
%   band-passed data (500 - 3000) and stim indexing channel for that data,
%   and basic information in a Data struct per subject 
%   (eg MWT01_SpikeData.mat) which is saved in datastructs/
%  
%   Data is from Neuronexus: Allego and Curate, should have *_Spike.xdat.json,
%   *_LFP_data.xdat, and *_LFP_timestamp.xdat per subject (eg AWT01_01).
%   After spike sorting, 5 more files with "kpi" and "spikes" files names.
% 
%   Condition should be a string matching a condition saved in the group
%   metadata file (eg AWT.m), such as 'NoiseBurst'
% 
%   calls homebrew functions: imakeIndexer, FileReaderSpikes, StimVariable, 
%   icutrasters, icutsingleraster, icutGAPrasters, irasterdata
% 
%   OUTPUT: Data struct per subject in /datastructs ; raster figure per
%   subject/condition/layer in /figures

%datachecks
if ~exist('Group','var')
    Groups = {'AWT','AKO'};
end
if ~exist('Condition', 'var')
    Condition = {'NoiseBurst','ClickTrain'};
end
if ~exist('type','var')
    type = 'Awake';
end

%% Load in

for iGro = 1:length(Groups)

    run([Groups{iGro} '.m']); % brings animals channels Cond Condition Layer
    Indexer = imakeIndexer(Condition,animals,Cond); %#ok<*USENS>

    for iSub = 1:length(animals)

        subname = animals{iSub};
        chanorder = str2num(channels{iSub});

        % initialize save data
        SpikeData = struct;

        for iStimType = 1:length(Condition)
            for iStimCount = 1:length(Cond.(Condition{iStimType}){iSub})
                if iStimCount == 1
                    CondIDX = Indexer(2).(Condition{iStimType});
                else
                    CondIDX = Indexer(2).(Condition{iStimType})+iStimCount-1;
                end

                measurement = Cond.(Condition{iStimType}){iSub}{iStimCount};

                %% Load the data from Videre/python and do things to it :D
                datafile = [subname '_' measurement '_Spikes'];
                % skip empty measurements
                if exist([datafile '_s0.mat'],'file')

                    disp(datafile)

                    % Layers
                    L.II = str2num(Layer.II{iSub});
                    L.IV = str2num(Layer.IV{iSub});
                    L.Va = str2num(Layer.Va{iSub});
                    L.Vb = str2num(Layer.Vb{iSub});
                    L.VI = str2num(Layer.VI{iSub});
                    Layers = fieldnames(L);

                    % labels - which neuron (not currently used)
                    % ntvldxs - which channel (0 - 31 == 1 - 32)
                    % timestamps - what time (s)
                    load([datafile '_s0.mat'],'ntvIdxs','timestamps')

                    % neuronexus data converter for matlab to get timing data
                    % we're also pulling the continuous data and
                    % downsampling it to fs = 1000 (matched with LFP).
                    % Note: Spikes are first detected at fs = 30k, this
                    % script can easily be altered to get that data out
                    % stimIn contains stimulus onset data at fs = 1000
                    % files needed here are:
                    % *_Spikes.xdat.json
                    % *_Spikes_data.xdat (the big one)
                    % *_Spikes_timestamp.xdat
                    [timerange,StimIn,DataIn] = FileReaderSpike(datafile,str2num(channels{iSub}));

                    % organize spikes into full length raster
                    [spikeMatrix] = irasterdata(timerange,timestamps,ntvIdxs,chanorder);

                    BL      = 399;
                    % The next part depends on the stimulus; pull the
                    % relevant variSubbles
                    [stimList, thisUnit, stimDur, stimITI, thisTag] = ...
                        StimVariable(Condition{iStimType},1,type);

                    % now single triSubl stack it
                    if matches(thisTag ,'spont') || matches(thisTag,'single')
                        sngtrlSpikes = icutsingleraster(StimIn, spikeMatrix, BL, stimDur, stimITI, thisTag);
                    elseif matches(thisTag,'gapASSRRate') 
                        sngtrlSpikes = icutGAPrasters(datafile,StimIn, spikeMatrix, stimList, BL, stimDur, stimITI, thisTag);
                    else
                        sngtrlSpikes = icutrasters(datafile,StimIn, spikeMatrix, stimList, BL, stimDur, stimITI, thisTag);
                    end

                    %% Plot it

                    cd (homedir); cd figures;
                    if exist(['Single_' Groups{iGro}],'dir') == 0
                        mkdir(['Single_' Groups{iGro}])
                    end
                    cd(['Single_' Groups{iGro}])

                    for iLay = 1:length(Layers)+1

                        PSTHfig = tiledlayout('flow');
                        if iLay == length(Layers)+1
                            title(PSTHfig,[subname ' ' Condition{iStimType} ' PSTH All Channels'])
                        else
                            title(PSTHfig,[subname ' ' Condition{iStimType} ' PSTH Layer ' Layers{iLay}])
                        end
                        xlabel(PSTHfig, 'time [ms]')
                        ylabel(PSTHfig, 'spike count / spike rate [s]')

                        for istim = 1:length(stimList)

                            % figure of psth's for all and layers per stim
                            trlsum   = sum(sngtrlSpikes{istim},3);

                            if iLay == length(Layers)+1
                                % raster summing all channels or layer channels
                                layersum  = sum(trlsum,1);
                            else
                                % raster summing all channels or layer channels
                                layersum  = sum(trlsum(L.(Layers{iLay}),:),1);
                            end

                            % get spiking rate per second
                            spikerate = sum(layersum) / ((length(layersum))/1000);
                            %adjust your raster by spiking rate
                            adjlaysum = layersum ./ spikerate;

                            % now add the tile
                            nexttile
                            bar(adjlaysum,30,'histc')
                            title([num2str(stimList(istim)) thisUnit])
                            xlim([0 length(layersum)])
                            xticks(0:200:length(layersum))
                            labellist = xticks;
                            xticklabels(labellist)

                        end

                        h = gcf;
                        if iLay == length(Layers)+1
                            savefig(h,[subname '_' Condition{iStimType} '_PSTH_AllChan'],'compact')
                        else
                            savefig(h,[subname '_' Condition{iStimType}  '_PSTH_Lay' Layers{iLay}],'compact')
                        end
                        close (h)
                    end

                    heatmapfig = tiledlayout('flow');
                    title(heatmapfig,[subname ' ' Condition{iStimType} ' Noiseburst Heatmap'])
                    xlabel(heatmapfig, 'time [ms]')
                    ylabel(heatmapfig, 'depth [channels]')

                    for istim = 1:length(stimList)
                        nexttile

                        imagesc((sum(sngtrlSpikes{istim},3)*-1))
                        title([num2str(stimList(istim)) thisUnit])
                        colormap('gray')

                        xlim([0 length(layersum)])
                        xticks(0:200:length(layersum))
                        labellist = xticks;
                        xticklabels(labellist)

                    end

                    colorbar

                    h = gcf;
                    savefig(h,[subname '_' Condition{iStimType} '_Heatmap' ],'compact')
                    close (h)

                    %% Save and Quit
                    % identifiers and basic info
                    SpikeData(CondIDX).measurement   = datafile;
                    SpikeData(CondIDX).Condition     = [Condition{iStimType} '_' num2str(iStimCount)];
                    SpikeData(CondIDX).BL            = BL;
                    SpikeData(CondIDX).stimDur       = stimDur;
                    SpikeData(CondIDX).StimList      = stimList;

                    % spike data
                    SpikeData(CondIDX).SortedSpikes  = sngtrlSpikes;
                    SpikeData(CondIDX).ContSpikes    = spikeMatrix;
                    SpikeData(CondIDX).ContStimChan  = StimIn; % should be the same as LFP data
                    SpikeData(CondIDX).ContBandPass  = DataIn; % bandpass filtered 500-3000
                end % check file exists
            end % stim count
        end % stim type

        if exist('SpikeData','var')
            cd(homedir);
            cd datastructs
            save([subname '_SpikeData'],'SpikeData');
            clear SpikeData
            cd(homedir)
        end

    end % subject
end % group
cd(homedir)


