function DynamicCSD(homedir, Condition, Groups, cbar, type)

%% Dynamic CSD 

%   This script takes input from groups/ and data/. It calculates 
%   and stores LFP, CSD, AVREC, Relres, and basic information in a 
%   Data struct per subject (eg MWT01_Data.mat) which is saved in 
%   datastructs/
%  
%   cbar variable sets caxis, flexible for different species
%
%   Data is from Neuronexus: Allego and Curate, should have *_LFP.xdat.json,
%   *_LFP_data.xdat, and *_LFP_timestamp.xdat per subject (eg MWT01_01). 
% 
%   Condition should be a string matching a condition saved in the group
%   metadata file (eg MWT.m), such as 'NoiseBurst'
% 
%   calls homebrew functions: imakeIndexer, FileReaderLFP, StimVariable, 
%   icutdata, icutsinglestimdata, icutGAPdata, SingleTrialCSD, sink_dura
% 
%   OUTPUT: Data struct per subject in /datastructs ; CSD figure per
%   subject/condition in /figures

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
cd(homedir)

for iGro = 1:length(Groups)    
    
    run([Groups{iGro} '.m']); % brings in animals, channels, Layer, and Cond
    
    %% Display conditions to verify correct list
    disp(Condition)
    
    %% Condition and Indexer
    Data = struct;
    BL   = 399; % always a 400ms baseline pre-event 
       
    Indexer = imakeIndexer(Condition,animals,Cond); %#ok<*USENS>
    %%
    
    for iA = 1:length(animals)
        
        name = animals{iA}; %#ok<*IDISVAR>
        
        for iStimType = 1:length(Condition)
            for iStimCount = 1:length(Cond.(Condition{iStimType}){iA})
                if iStimCount == 1
                    CondIDX = Indexer(2).(Condition{iStimType});
                else
                    CondIDX = Indexer(2).(Condition{iStimType})+iStimCount-1;
                end
                
                measurement = Cond.(Condition{iStimType}){iA}{iStimCount};
                % all of the above is to indicate which animal and
                % condition is being analyzed
                
                if exist([name(1:5) '_' measurement '_LFP.xdat.json'],'file')
                    file = [name(1:5) '_' measurement '_LFP'];
                    disp(['Analyzing animal: ' file])
                    tic
                    [StimIn, DataIn] = FileReaderLFP(file,str2num(channels{iA}),type);

                    % The next part depends on the stimulus; pull the
                    % relevant variables
                    [stimList, thisUnit, stimDur, stimITI, thisTag] = ...
                        StimVariable(Condition{iStimType},1,type);

                    % and slice the data
                    if matches(thisTag,'single') || matches(thisTag,'spont')
                        sngtrlLFP = icutsinglestimdata(StimIn, DataIn, BL, ...
                            stimDur, stimITI, thisTag);
                    elseif matches(thisTag,'gapASSRRate') 
                        sngtrlLFP = icutGAPdata(file, StimIn, DataIn, stimList, ...
                            BL, stimDur, stimITI, thisTag);
                    else
                        sngtrlLFP = icutdata(file, StimIn, DataIn, stimList, ...
                            BL, stimDur, stimITI, thisTag);
                    end

                    % clear DataIn StimIn
                    
                    %% All the data from the LFP now (sngtrl = single trial)
                    [sngtrlCSD, ~, sngtrlAvrecCSD, ~,...
                        singtrlRelResCSD] = SingleTrialCSD(sngtrlLFP,BL);

                    %% Plots 
                    disp('Plotting CSD with sink detections')
                    
                    cd (homedir); cd figures;
                    if ~exist(['Single_' Groups{iGro}],'dir')
                        mkdir(['Single_' Groups{iGro}]);
                    end
                    cd (['Single_' Groups{iGro}])

                    % layer assignments
                    L.II = str2num(Layer.II{iA}); 
                    L.IV = str2num(Layer.IV{iA}); 
                    L.Va = str2num(Layer.Va{iA}); 
                    L.Vb = str2num(Layer.Vb{iA}); 
                    L.VI = str2num(Layer.VI{iA});  

                    CSDfig = tiledlayout('flow');
                    title(CSDfig,[name ' ' Condition{iStimType}...
                        ' ' num2str(iStimCount) ' CSD'])
                    xlabel(CSDfig, 'time [ms]')
                    ylabel(CSDfig, 'depth [channels]')
                    
                    for istim = 1:length(stimList)
                        nexttile
                        imagesc(nanmean(sngtrlCSD{istim},3))
                        title([num2str(stimList(istim)) thisUnit])
                        colormap jet                       
                        clim(cbar)
                        xline(BL+1,'LineWidth',2) % onset
                        xline(BL+stimDur+1,'LineWidth',2) % offset
                        yline(L.II(end)); yline(L.IV(end)); 
                        yline(L.Va(end)); yline(L.Vb(end));
                        if L.VI(end) > size(sngtrlCSD,1)
                            yline(L.VI(end));
                        end
                    end
                    
                    colorbar
                    h = gcf;
                    savefig(h,[name '_' measurement '_CSD' ],'compact')
                    % saveas(h,[name '_' measurement '_CSD.png' ])
                    close (h)

                    %% Save and Quit
                    % identifiers and basic info
                    Data(CondIDX).measurement   = file;
                    Data(CondIDX).Condition     = [Condition{iStimType} '_' num2str(iStimCount)];
                    Data(CondIDX).BL            = BL;
                    Data(CondIDX).stimDur       = stimDur;
                    Data(CondIDX).StimList      = stimList;

                    % CSD data
                    Data(CondIDX).sngtrlLFP     = sngtrlLFP;
                    Data(CondIDX).sngtrlCSD     = sngtrlCSD;
                    Data(CondIDX).sngtrlAvrec   = sngtrlAvrecCSD;
                    Data(CondIDX).singtrlRelRes = singtrlRelResCSD;
                    Data(CondIDX).continuousLFP = DataIn;
                    Data(CondIDX).contStimChan  = StimIn;
                                        
                    toc
                end
            end
        end

        if exist('Data','var')
            cd(homedir);
            cd datastructs
            save([name '_Data'],'Data');
            clear Data
            cd(homedir)
        end
    end

end
cd(homedir)
