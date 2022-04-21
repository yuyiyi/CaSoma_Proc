function ind = kyoFindStim(Scenes,stimName,rep)
ind=0;
n=1;
while (n<=numel(Scenes)) && (ind==0)
    if (Scenes(n).rep==rep) && (strcmp(char(Scenes(n).stim),stimName))
        ind=n;
    end
    n=n+1;
end