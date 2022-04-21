function add_red_channel(ops, mimgR)


for i = 1:length(ops.planesToProcess)
    iplane  = ops.planesToProcess(i);
    fname = sprintf('%s/F_%s_%s_plane%d_Nk%d.mat', ops.ResultsSavePath, ops.mouse_name, ops.date, iplane, ops.Nk);
    dd = load(fname);
    
    dd.ops.mimgRED = mimgR(:,:,iplane);    
    save(fname, '-struct', 'dd')
end