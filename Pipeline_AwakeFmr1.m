% Pipeline - Awake Fmr1 Comparison Study ~( °٢° )~

% This is the master script for the awake FMR1 KO and WT study, run by Katrina
% Deane at University of California, Riverside in Khaleel Razak's lab in
% the Psychology Department and Frank Ohl at the Leibniz Institute for
% Neurobiology in the Systems Physiology of Learning Department.

% The overall goal of this study is to characterize A1 laminar differences
% between groups - specifically via spike field coherence. 
% Fmr1 KOs have auditory hypersensitivity and under anesthesia, we found
% lower spiking and population activity levels and higher variability
% compared to WTs

%% Get started

clear; clc;

% set working directory; change for your station
if exist('D:\SpikeFieldCoherence','dir')
    cd('D:\SpikeFieldCoherence'); 
elseif exist('mydirectory','dir')
    cd('mydirectory'); 
else
    error('add your local repository as shown above')
end
homedir = pwd;
addpath(genpath(homedir));
cd(homedir)
set(0, 'DefaultFigureRenderer', 'painters');

% set consistently needed variables
Groups = {'AWT' 'AKO'}; 
% Short list
Condition = {'NoiseBurst' 'Spontaneous'};

%% CSD Data generation per subject 

% per subject CSD Script
% this takes in the curate data files (.xdat, etc.) and the metadata group
% file (e.g. AWT.m) to epoch all continuous data, stacking trials. The
% output is a data structure along with all single subject CSD figures
DynamicCSD(homedir, Condition, Groups, [-0.2 0.2],'Awake')

% LFP single subject figures
% singleLFPfig(homedir, Groups, Condition,[-50 50],'Awake')

%% Spike Data generation per subject

% per subject spike Script
% this takes in the curate data files (.xdat, etc.) and the metadata group
% file (e.g. AWT.m) to epoch all continuous data, stacking trials. The
% output is a data structure along with all single subject spike figures
DynamicSpikes(homedir, Groups, Condition,'Awake')

%% Open Both Together to analyze
LFP_Spike(homedir,Groups,Condition)
