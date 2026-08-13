% Takes ROIs from ImageJ [.zip] 
% and calculates an average fluorescence trace for each ROI
% ---place ROIs in same folder as imaging data---
% Palmer Lab
% 01 August 2026

clear all
clc
savefn = 'All';

[f, p] = uigetfile('*.tif','Click any file.');
cd(p)
[pathstr, name, ext] = fileparts([p f]);
d = dir(fullfile(pathstr, ['/*' ext]));
str = {d.name};
str = sortrows({d.name}');

[s,v] = listdlg('PromptString','Select files to analyze:', 'OKString',...
    'OK', 'SelectionMode','multiple',...
    'ListString', str, 'Name', 'Select a File');

names = str(s);
numTraces = size(names, 1);

[rois] = ReadImageJROI('RoiSet.zip');
numROIs = size(rois,2);

for file_counter = 1:numTraces
    
    disp([names{file_counter} ' Extracting ROI Info'])
    filetoRead = names{file_counter};
    
    tiftag = imfinfo( filetoRead); 
    nFrames=numel(tiftag);
    
    if file_counter==1
        [X,Y] = meshgrid(1:tiftag(1).Width,1:tiftag(1).Height);
        for rr=1:numROIs
            mask(:,:,rr)=inpolygon(X,Y,rois{rr}.mnCoordinates(:,1), ...
                rois{rr}.mnCoordinates(:,2));
        end
    end
    
    roimeans{file_counter}=zeros(numROIs,nFrames);

    for ii = 1:nFrames
        g = imread([pathstr filesep filetoRead], ii);
        
        for rr=1:numROIs
            roimeans{file_counter}(rr,ii)=mean(g(mask(:,:,rr)));
        end
    end
end

save([savefn '_Facrosstrials'],'roimeans')