%% Load imaging data (must be in correct data directory
fn = 'V1_sparseNoise';
numRuns = 5;

for n=1:numRuns
    [~,movSrc] = kyoLoadStackTIFF([fn sprintf('%03i',n) '.tif'],1);
    clear movR
    movAll(:,:,:,n)=double(movSrc);
end

% Stimulus info
sfv=0; % remember to paste the stim frame vector from Igor into this variable

stimNames = {num2str(1:1000)};
%stimNames = {'patch50'};
%stimNames = {'up' 'left' 'down' 'right' 'zoomIn' 'zoomOut' 'rotCCW' 'rotCW'};

%% Make Scenes
Scenes = kyoConvertSFVtoScenes(sfv,stimNames,numReps);

%% unfiltered (not usually that great)
movKurt = kurtosis(mov,0,3);
%% filtered
G = fspecial('gaussian',[4 4],2);
for f=1:size(mov,3)
    movF(:,:,f) = imfilter(mov(:,:,f),G,'same');
end
movKurt = kurtosis(movF,0,3);
%%
minArea = 10;
[rois]=kyoMakeROIsFromCCimage(movKurt,minArea,1,[10 10 -0.01]);
%% now go screen on kurtosis
kurtosisThresh = 20;
[tc,roisGood] = kyoGetTCs(mov,rois,kurtosisThresh);
%% Check ROIs by hand
kyoBrowseROIsGUI(roisGood,mov)
%% responses
bl = 40; % baseline
fw = 160; % full width
st = 77; % stim duration
responses = kyoResponses(tc(:,1),Scenes,bl,fw);
%% display response
kyoDisplayResponses(responses,bl,st,15)
%% inspect individual rois in more detail
kyoDisplaySingleResponse(responses,9,bl,st)
%% get tuning curves
tuningCurves = kyoTuningCurves(responses,bl,st,1);
%%
