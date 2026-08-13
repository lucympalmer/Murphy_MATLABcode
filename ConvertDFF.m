%% Calculate DF/F for calcium imaging data from ReadROIs.m
% Palmer Lab
% 01 August 2026

% Load data roimeans, generated from ReadROIs.m
% Set values; Default 0
freqAcq = 0;    %% input values for imaging parameters                    
preStim = 0;    %% input values for imaging parameters
      
stimOn = round(freqAcq * preStim);    
nRois = size(roimeans{1,1},1); 
nTrials = size(roimeans,2);
dffmat = cell(nTrials,nRois);
 
for i = 1:nTrials
    Roistrace = cell2mat(roimeans(i));
    for j = 1:nRois
        ftrace = (Roistrace(j,:));   
        fo = median(ftrace(1:10));  
        df = ftrace - fo;
        dff = (df./fo); 
        dffmat{i,j} = dff; 
    end   
end
nFrames = size(ftrace,2);

%% plot traces 
for l = 1:nRois
    figure(l);
    hold on;
    for k = 1:nTrials
        plot(dffmat{k,l},'k','LineWidth',1.5);
    end
    hold off;
end
