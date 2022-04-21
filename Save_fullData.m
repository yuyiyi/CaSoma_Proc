function Save_fullData(handles, f_wait, TraceROIPara)
if nargin == 1
    f_wait = waitbar(0.2,'Saving');
end
moviedir = fullfile(handles.filepath, handles.filename);
im_norm = handles.im_norm;
if exist(fullfile(handles.savepath, handles.savename), 'file')==0
    save(fullfile(handles.savepath, handles.savename), 'im_norm', 'moviedir', '-v7.3')
else
    save(fullfile(handles.savepath, handles.savename), 'im_norm', 'moviedir', '-append')
end
if ~isempty(handles.Regfile)
    RegResult = handles.Regfile;
    save(fullfile(handles.savepath, handles.savename), 'RegResult', '-append')
end
Traces_full = handles.Traces_full;

grad = handles.movieinputgrad;
L = handles.imagelength;
fext = handles.fext;
if grad > 1 
    waitbar(0.5, f_wait, 'It is a long movie, saving in progress');
    currentframeID = handles.movieframeID;
    if ~isempty(handles.Traces_full) && ~isempty(handles.roi)
        region = handles.roi;
        N = size(Traces_full.tc,2);
        celltrace_full = zeros(L,N);
        
        tcraw_full = zeros(L,N);
        tc_full = zeros(L,N);
        tcraw_pca_full = zeros(L,N);
        tc_pcasub_full = zeros(L,N);
        tcraw_full(currentframeID,:) = Traces_full.tcraw;
        tc_full(currentframeID,:) = Traces_full.tc;
        tcraw_pca_full(currentframeID,:) = Traces_full.tcraw_pca;
        tc_pcasub_full(currentframeID,:) = Traces_full.tc_pcasub;
        
    end
    handles.mov = [];
    handles.movF = [];
    xi = 2;
    while xi<=grad
        mov = zeros([handles.size(1)*handles.size(2), length(xi:grad:L)], handles.WorkingPrecision);
        j1 = 1;
        for j = xi:grad:L
            if ~isempty(fext)
                I1 = imread(fullfile(handles.filepath, handles.filename), j);
            else
                I1 = imread(fullfile(handles.filepath, handles.filename, handles.imageinfo(j).name));
            end
            mov(:,j1) = I1(:);
            j1 = j1+1;
        end
        currentframeID = xi:grad:L;
            
        tic
        [tcraw, tc, tcraw_pca, tc_pcasub] = kyoGetTCs_sutract_pca_v2(mov, region, TraceROIPara.subtractPara);
        toc 
        tcraw_full(currentframeID,:) = tcraw;
        tc_full(currentframeID,:) = tc;
        tcraw_pca_full(currentframeID,:) = tcraw_pca;
        tc_pcasub_full(currentframeID,:) = tc_pcasub;

        waitbar(0.8, f_wait, 'It is a long movie, saving in progress');
        xi = xi+1;
    end
    Traces_full.tcraw = tcraw_full;
    Traces_full.tc = tc_full;
    Traces_full.tcraw_pca = tcraw_pca_full;
    Traces_full.tc_pcasub = tc_pcasub_full;
end

tc = Traces_full.tc_pcasub;
snr = [];
for n = 1:size(tc, 2)
    b = quantile(tc(:,n), 0.3);
    base_std = std(tc(tc(:,n)<=b,n));
    s = max(tc(:, n));
    snr(n) = s/base_std;
end
trace_SNR = snr;
save(fullfile(handles.savepath, handles.savename), 'Traces_full', 'trace_SNR', '-append');


waitbar(1, f_wait, 'Saving');
close(f_wait)
delete(f_wait)
