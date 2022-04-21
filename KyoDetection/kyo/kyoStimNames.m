function [stimNames,numReps] = kyoStimNames(Scenes)

i=1;
n=1;
done=0;
while (n<=numel(Scenes)) && (done==0)
    if (~strcmp(Scenes(n).stim,'isi')) && (~strcmp(Scenes(n).stim,'baseline'))
        if i==1
            stimNames{i}=char(Scenes(n).stim);
            i=i+1;
        elseif (sum(cell2mat(strfind(stimNames,char(Scenes(n).stim)))))==0
            stimNames{i}=char(Scenes(n).stim);
            i=i+1;
        else
            done=1;
        end
    end
    n=n+1;
end

numReps=1;
for n=1:numel(Scenes)
    if (~strcmp(Scenes(n).stim,'isi')) && (~strcmp(Scenes(n).stim,'baseline'))
        if Scenes(n).rep>numReps;
            numReps=Scenes(n).rep;
        end
    end
end