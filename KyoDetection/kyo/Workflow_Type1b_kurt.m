%% Load imaging data (must be in correct data directory
fn = '20-1V; 1e-6; GP B.tif';

mov = kyoLoadStackTIFF(fn);
mov = double(mov);

% Stimulus info
sfv=0; % remember to paste the stim frame vector from Igor into this variable

%stimNames = {'ori0' 'ori45' 'ori90' 'ori135' 'ori180' 'ori225' 'ori270' 'ori315'};
%stimNames = {'patch50'};
%stimNames = {'up' 'left' 'down' 'right' 'zoomIn' 'zoomOut' 'rotCCW' 'rotCW'};
%numReps = 6;
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
[rois regions]=kyoMakeROIsFromCCimage(movKurt,minArea,1,[20 20 -0.01]);
%% now go screen on kurtosis
kurtosisThresh = 5;
[tc,roisGood] = kyoGetTCs(mov,rois,kurtosisThresh);
%% Calculates kurtosis
clear kurt SortKurt Sort_tc;
for k=1:size(tc,2)
    kurt(k)= kurtosis(tc(:,k));
end
[SortKurt, I]=sort(kurt, 'descend');
for k=1:size(I,2)
    Sort_tc(:,k)=tc(:, I(k));
end
SortKurt(1:10)
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
%% Make Projection iamges based on 'keeps'
for i=1:size(tc, 2)
    [maxValueK(i),maxFrame(i)]= max(tc(:,i));
    MaxMov(:,:,i)= mov(:,:,maxFrame(i));
end
MaxImage = max(MaxMov, [], 3);
imshow(MaxImage, [0 20]);
