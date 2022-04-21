% make a Scenes variable from a stim frame vector variable

%% Set params

stimNames = {'ori0' 'ori45' 'ori90' 'ori135' 'ori180' 'ori225' 'ori270' 'ori315'};
numStim = numel(stimNames);
numReps = 6;

sfv = sfv_oriB;


%% Build list of scenes
% "Scenes" specifies the stimulus, isis, etc.
% It is used to for data analysis, and is used to make the Schedule which
% is used in data acquision

clear Scenes

% Convert the stim frame vector into a schedule of switches
a = diff(sfv);
a = abs(a);
switchlocs = double(a>0);

numScenes = 2 + (numStim * numReps * 2); % 1 ISI per stim, plus baseline

Scenes(1).stim = 'baseline';
Scenes(1).rep = 1;
Scenes(1).fStart = 1;

loc = find(switchlocs,1);
switchlocs(loc) = 0;
Scenes(1).fEnd = loc;

repCounterStim = 1;
repCounterISI = 1;
stimCounter = 1;


for i=2:2:numScenes-1
    Scenes(i).stim = stimNames(stimCounter);
    Scenes(i).rep = repCounterStim;
    Scenes(i).fStart = Scenes(i-1).fEnd + 1;
    loc = find(switchlocs,1);
    switchlocs(loc) = 0;
    Scenes(i).fEnd = loc;
    
    Scenes(i+1).stim = 'isi';
    Scenes(i+1).rep = repCounterISI;
    Scenes(i+1).fStart =  Scenes(i).fEnd + 1;
    loc = find(switchlocs,1);
    switchlocs(loc) = 0;
    Scenes(i+1).fEnd = loc;
    
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
Scenes(numScenes).fEnd = numel(sfv);

clear a numScenes i stimCounter repCounterStim repCounterISI
clear switchlocs loc