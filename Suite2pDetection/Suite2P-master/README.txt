This code was written by Marius Pachitariu and members of the lab of Kenneth Harris and Matteo Carandini. It is provided here with no warranty. Please direct all questions and requests to marius10patgmaildotcom. 

I. Introduction 

This is a complete automated pipeline for processing two-photon Calcium imaging recordings. It is very simple, very fast and yields a large set of active ROIs. A GUI further provides point-and-click capabilities for refining the results in minutes. Included in this software release is an SfN2015 poster  which showcases the capabilities of the toolbox. The pipeline includes the following steps

1) X-Y subpixel registration --- using a version of the phase correlation algorithm and subpixel translation in the FFT domain. If a GPU is available, this completes in 20 minutes per 1h of recordings at 30Hz and 512x512 resolution.

2) SVD decomposition --- this provides the basis for a number of pixel-level visualization tools. 

3) Cell detection --- using clustering methods in a low-dimensional space of the fluorescence activity. The pixel clustering algorithm directly provides a binary mask for each ROI identified and stands in contrast to more complicated, less well-understood methods that have been previously proposed.

4) Manual curation --- the output of the cell detection algorithm can be visualized and further refined using a GUI available at https://github.com/marius10p/gui2P/. The GUI is designed to make cell sorting a fun and enjoyable experience. 

II. Getting started

The toolbox runs in Matlab (no mex files) and currently only supports tiff file inputs. To begin using the toolbox, you will need to make local copies (in a separate folder) of two included files: master_file and make_db. The make_db file assembles a database of experiments that you would like to be processed in batch. It also adds per-session specific information that the algorithm requires such as the number of imaged planes and channels. The master_file sets general processing options that are applied to all sessions included in make_db, UNLESS the option is over-ridden in the make_db file.  The global and session-specific options are described in detail below. 

III. Input-output file paths

RootStorage --- the root location where the raw tiff files are  stored.
CopyDataLocally --- whether to copy data to the local disk first (faster reads of tiffs).
TempStorage --- location on local disk where to copy data.
RegFileRoot --- location on local disk where to keep the registered movies in binary format. This will be loaded several times so it should ideally be an SSD drive. 
ResultsSavePath --- where to save the final results. 
DeleteBin --- deletes the binary file created to store the registered movies
DeleteRawOnline --- deletes local tiff files as soon as they are registered

Most of these filepaths are complemented with separate subfolders per animal and experiment, specified in the make_db file. The output is a struct called dat which is saved into a mat file in ResultsSavePath under a name formatted like F_M150329_MP009_2015-04-29_plane1_Nk650. It contains all the information collected throughout the processing, and contains the fluorescence traces in dat.F.Fcell and whether a given ROI is a cell or not in dat.F.iscell. dat.stat contains information about each ROI and can be used to recover the corresponding pixels for each ROI in dat.stat.ipix. The centroid of the ROI is specified in data.stat as well. 

IV. Options for registration

NimgFirstRegistration --- number of randomly sampled images to do the target computation from
NiterPrealign --- number of iterations for the target computation (iterative re-alignment of subset of frames)
useImRead --- whether to use the Matlab built-in tiff loading function (possinly slightly faster from local disks). 
PhaseCorrelation --- whether to use phase correlation (the alternative is normal cross-correlation).
SubPixel --- accuracy level of subpixel registration required. 2 is alignment by 0.5 pixel, Inf is the exact number from phase correlation. 
showTargetRegistration --- whether to show an image of the target frame immediately after it is computed. 
RegPrecision --- int16
RawPrecision --- int16

V. Options for cell detection

getROIs --- whether to run the ROI detection algorithm after registration
ShowCellMap --- whether to show the clustering results as an image every 10 iterations of the clustering
Nk0 --- starting the algorithm with this many clusters
Nk --- final annealed number of clusters (warning, due to the structure of the annealing process, one should have Nk0<3*Nk or else the code crashes; will improve this in the future). 
nSVDforROI --- how many SVD components to keep for clustering
niterclustering --- how many iterations of clustering
sig --- spatial smoothing constant: smooths out the SVDs spatially. Makes ROIs more cell-shaped, but tends to get slightly larger cell boundaries than visible on the mean image. Set to 0 to avoid this effect (should still work well for all but the dimmest cells in the FOV). This option will be replaced in the future with a different method to encourage localized clusters without the smoothing. 

VI. Options for SVD decomposition

getSVDcomps --- whether to obtain and save to disk SVD components of the registered movies. Useful for pixel-level analysis and for checking the quality of the registration (residual motion will show up as SVD components).
NavgFramesSVD --- for SVD data has to be temporally binned. This number specifies the final number of points to be obtained after binning. In other words, datasets with many timepoints are binned in higher windows while small dataset are binned less. 
nSVD --- how many SVD components to keep.

VII. Rules for post-clustering ROI classification

These options serve to compute candidate cell clusters, that can then be refined in the GUI. Clusters computed in the algorithm are split into connected regions and then classified as cell/non-cell based on the following

MaxNpix --- maximum number of pixels per ROI
MinNpix --- minimum number of pixels per ROI
Compact --- a compactness criterion for how close pixels are to the center of the ROI. 1 is the lowest possible value, achieved by perfect disks. 
parent --- these are criteria imposed on the parent cluster (before separating connected regions). 
parent.minPixRelVar --- significant regions need to have at least >1/10 the mean variance of all regions
parent.MaxRegions --- if there are more non-significant regions than this number, this parent ROI is probably very spread out over many small components and its connected regions are not good cells: it will be discarded. 

VIII. The following is a typical example of an entry in your local make_db file, which you can model after make_db_adaptation. The folder structure assumed is RootStorage/mouse_name/date/expts(k) for all entries in expts(k). 

i = i+1;
db(i).mouse_name    = 'M150329_MP009'; 
db(i).date          = '2015-04-27';
db(i).expts         = [5 6]; % which experiments to process together
db(i).nchannels     = 1; % number of channels recorded
db(i).gchannel      = 1;  % which of these channels do you want analyzed
db(i).nplanes       = 1;  % number of planes recorded
db(i).comments      = 'multi p file: block 0,5,6';

IX. About this software

Following six years of theoretical and computational neuroscience, a year ago I have started doing my own recordings and found the existing pipelines for Calcium processing to be lacking. This included a first disappointment with my own software that I had developed a few years ago for detecting donut-like ROIs from mean images. That method found donuts reliably and indeed found five times more cells than my colleagues in the lab were detecting, but most of the detected cells were very silent throughout the recordings, and several cells with large transients were not detected because... they did not show up at all in the mean images! An activity-based method was needed and I turned to ICA methods for several months until I realized the method was biasing my tuning curves and very often giving me negative responses. This was because ICA-like methods return continuous-valued masks that attempt to disentangle and orthogonalize potentially overlapping ROIs (cells, neuropil, dendrites). The model's assumptions thus biased the end result. While it is possible that other advanced methods might solve all problems, I thought there was a need and opportunity for simpler algorithms, like pixel-clustering methods. Combining such algorithms with a dimensionality-reduction pre-processing step, resulted in the very fast method implemented here. 
