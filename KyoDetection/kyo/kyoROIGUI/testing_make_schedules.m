%% Set params

% Aquisition parameters
imAqFramesPerSec = 1.0;

% Stimulus parameters
stimNames = {'ori0' 'ori45' 'ori90' 'ori135' 'ori180' 'ori225' 'ori270' 'ori315'};
numStim = numel(stimNames);
numReps = 6;

% Schedule parameters
tBaseline = 10; % Duration of baseline (start and end), in seconds
tStim = 5;      % Duration of each stimulus, in seconds
tISI = 5;       % Duration of interstimulus interval, in seconds

% Internal conversions
fBaseline = tBaseline * imAqFramesPerSec;   % Convert to number of frames
fStim = tStim * imAqFramesPerSec;           % Convert to number of frames
fISI = tISI * imAqFramesPerSec;             % Convert to number of frames

%% Build list of scenes
% "Scenes" specifies the stimulus, isis, etc.
% It is used to for data analysis, and is used to make the Schedule which
% is used in data acquision

numScenes = 2 + (numStim * numReps * 2); % 1 ISI per stim, plus baseline

Scenes(1).stim = 'baseline';
Scenes(1).rep = 1;
Scenes(1).fStart = 1;
Scenes(1).fEnd = Scenes(1).fStart + fBaseline - 1;

repCounterStim = 1;
repCounterISI = 1;
stimCounter = 1;


for i=2:2:numScenes-1
    Scenes(i).stim = stimNames(stimCounter);
    Scenes(i).rep = repCounterStim;
    Scenes(i).fStart = Scenes(i-1).fEnd + 1;
    Scenes(i).fEnd = Scenes(i).fStart + fStim - 1;
    
    Scenes(i+1).stim = 'isi';
    Scenes(i+1).rep = repCounterISI;
    Scenes(i+1).fStart = Scenes(i).fEnd + 1;
    Scenes(i+1).fEnd = Scenes(i+1).fStart + fISI - 1;
    
    stimCounter = stimCounter + 1;
    repCounterISI = repCounterISI + 1;
    if stimCounter > numStim
        stimCounter = 1;
        repCounterStim = repCounterStim + 1;
    end
end
Scenes(numScenes).stim = 'baseline';
Scenes(numScenes).rep = 2;
Scenes(numScenes).fStart = Scenes(numScenes-1).fEnd + 1;
Scenes(numScenes).fEnd = Scenes(numScenes).fStart + fBaseline - 1;

%% Make a schedule from the scenes

% There are two scene types: loop movie scenes, and fixed frame scenes
%
% Loop movie scenes: Gratings, etc. Loop movie at stim speed until next
% scene. For each imaging frame, a loop stack is referenced.
%
% Fixed frame scenes: RF mapping. Leave one image on the screen until the
% next scene. For each imaging frame, a static frame from specified stack
% is referenced.
%
% Schedule(n).Stack = stimulus stack, 0 = grey screen
% Schedule(n).Frame = stimulus frame in that stack, 0 = loop

%Schedule = zeros(1,Scenes(end).fEnd);
for i = 1:numel(Scenes)
    if strcmp(Scenes(i).stim,'baseline')
        for n=Scenes(i).fStart:Scenes(i).fEnd
            Schedule(n).Stack='baseline';
            Schedule(n).Frame=0;
        end
    end
    
    if strcmp(Scenes(i).stim,'isi')
        for n=Scenes(i).fStart:Scenes(i).fEnd
            Schedule(n).Stack='isi';
            Schedule(n).Frame=0;
        end
    end
       
    if sum(strcmp(Scenes(i).stim,stimNames))
        for n=Scenes(i).fStart:Scenes(i).fEnd
            Schedule(n).Stack=Scenes(i).stim;
            Schedule(n).Frame=0;
        end
    end
end


