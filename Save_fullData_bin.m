function Save_fullData_bin(handles, f_wait, TraceROIPara)
if nargin == 1
    f_wait = waitbar(0,'Saving');
end
binfilelist = handles.RegPara.savename;
Ly = handles.size(1);
Lx = handles.size(2);
handles.mov = [];
handles.movF = [];
region = handles.roi;
subtractPara = TraceROIPara.subtractPara;
tcraw_full = []; tc_full = []; tcraw_pca_full = []; tc_pcasub_full = [];
if max(region(:)) > 0
    for j = 1:length(binfilelist)
        moviedir{j} = fullfile(handles.filepath, binfilelist{j})
        clear mov; 
        fig = fopen(fullfile(handles.filepath, binfilelist{j}), 'r');
        mov = fread(fig, Ly*Lx*handles.imagelength(j), [handles.WorkingPrecision '=>' handles.WorkingPrecision]);
        mov = reshape(mov, Ly,Lx,handles.imagelength(j));
        fclose(fig);
        waitbar(j/length(binfilelist)*0.5, f_wait, 'It is a long movie, saving in progress');
        if ~isempty(mov)
            tic
            [tcraw, tc, tcraw_pca, tc_pcasub] =...
                kyoGetTCs_sutract_pca_v2(mov, region, subtractPara);
            toc 
            tcraw_full = cat(1, tcraw_full, tcraw);
            tc_full = cat(1, tc_full, tc);
            tcraw_pca_full = cat(1, tcraw_pca_full, tcraw_pca);
            tc_pcasub_full = cat(1, tc_pcasub_full, tc_pcasub);
        end
        waitbar(j/length(binfilelist), f_wait, 'It is a long movie, saving in progress');
    end
end
Traces_full.tcraw = tcraw_full;
Traces_full.tc = tc_full;
Traces_full.tcraw_pca = tcraw_pca_full;
Traces_full.tc_pcasub = tc_pcasub_full;


tc = Traces_full.tc_pcasub;
snr = [];
for n = 1:size(tc, 2)
    b = quantile(tc(:,n), 0.3);
    base_std = std(tc(tc(:,n)<=b,n));
    s = max(tc(:, n));
    snr(n) = s/base_std;
end
trace_SNR = snr;
im_norm = handles.im_norm;
if exist(fullfile(handles.savepath, handles.savename), 'file')==0
    save(fullfile(handles.savepath, handles.savename), ...
        'im_norm', 'moviedir', 'Traces_full', 'trace_SNR',  '-v7.3')
else
    save(fullfile(handles.savepath, handles.savename), ...
        'im_norm', 'moviedir', 'Traces_full', 'trace_SNR', '-append')
end
if ~isempty(handles.Regfile)
    RegResult = handles.Regfile;
    save(fullfile(handles.savepath, handles.savename), 'RegResult', '-append')
end
waitbar(1, f_wait, 'Saving');
close(f_wait)
delete(f_wait)
