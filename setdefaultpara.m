function defaultPara = setdefaultpara
defaultPara.sig                    = 0.8;  % spatial smoothing length for clustering; encourages localized clusters
defaultPara.nSVDforROI             = 500; % Number of principal components to keep
defaultPara.NavgFramesSVD          = 4000; % how many (binned) timepoints to do the SVD based on
defaultPara.niterclustering        = 30;   % how many iterations of clustering
defaultPara.ShowCellMap            = 1;
defaultPara.Nk0                    = 800;  % how many clusters to start with
defaultPara.Nk                     = 100;  % how many clusters to end with
defaultPara.minarea = 20; % minimal cell size
defaultPara.maxarea = 400; % maximal cell size
defaultPara.subtractPara = [2,5];
defaultPara.KurtosisMapSegPara = [20 20 -0.015];
defaultPara.GaussKernel = [4,4,2];
defaultPara.lambdath = 0.02; % 0.002
defaultPara.corr_thresh = 0.25;