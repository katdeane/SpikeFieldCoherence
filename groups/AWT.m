%%% Group AWT = Awake Wild Type (C57 B6/J) males
animals = {'AWT01','AWT02'}; %,'AWT03','AWT06','AWT07','AWT08','AWT10','AWT11','AWT12','AWT13','AWT14','AWT15'

% notes:

%% Channels and Layers
% full channel order: [17 16 18 15 19 14 20 13 21 12 22 11 23 10 24 9 25 8 26 7 27 6 28 5 29 4 30 3 31 2 32 1]

channels = {...
    '[12 22 11 23 10 24 9 25 8 26 7 27 6 28 5 29 4 30 3 31 2 32 1]',... %01
    '[20 13 21 12 22 11 23 10 24 9 25 8 26 7 27 6 28 5 29 4 30]',... %02
    };

%           01          02     
Layer.II = {'[1:3]',	'[1:3]'}; 
         
Layer.IV = {'[4:11]',	'[4:11]'};
     
Layer.Va = {'[12:14]',	'[12:15]'};
   
Layer.Vb = {'[15:19]',	'[16:19]'};
    
Layer.VI = {'[21:23]',	'[20:21]'}; 

% first noiseburst contains date and time window of recording

%% Conditions
Cond.NoiseBurst = {...
    {'03'},... %AWT01 5.30.24 (14:30-15:30) {allego 2}
    {'02'},... %AWT02 5.31.24 (10:44-11:45) {allego 1}
    };

Cond.Spontaneous = {...
    {'04'},... %AWT01 - {allego 3}
    {'03'},... %AWT02 - {allego 2}
    };
