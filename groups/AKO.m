%%% Group AKO = Awake Male Knock Out (FMR1 C57 B6/J)
animals = {'AKO01','AKO02'}; %,'AKO03','AKO04','AKO05','AKO06','AKO07','AKO08','AKO09','AKO10','AKO11','AKO12'

% notes:


%% Channels and Layers
% full channel order: [17 16 18 15 19 14 20 13 21 12 22 11 23 10 24 9 25 8 26 7 27 6 28 5 29 4 30 3 31 2 32 1]

channels = {...
    '[18 15 19 14 20 13 21 12 22 11 23 10 24 9 25 8 26 7 27 6 28 5 29 4]',... %01
    '[17 16 18 15 19 14 20 13 21 12 22 11 23 10 24 9 25 8 26 7 27 6 28 5]',... %02
    };

%           01          02 
Layer.II = {'[1:3]',	'[1:4]'}; 

Layer.IV = {'[4:9]',	'[5:8]'};

Layer.Va = {'[10:12]',	'[9:13]'};

Layer.Vb = {'[13:16]',	'[14:17]'}; 

Layer.VI = {'[17:21]',	'[18:22]'}; 

% noiseburst contains date and time window of recording

%% Conditions
Cond.NoiseBurst = {...
    {'03'},... %AKO01 5.13.24 (9:00-10:00)        {allego 2}
    {'04'},... %AKO02 5.13.24 (10:10-11:15)       {allego 11}
    };

Cond.Spontaneous = {...
    {'04'},... %AKO01 - {allego 3}
    {'05'},... %AKO02 - {allego 12}
    };

