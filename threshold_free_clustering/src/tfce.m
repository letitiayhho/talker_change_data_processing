load 'threshold_free_clustering/data/eeg_data_ft.mat'
load 'threshold_free_clustering/data/GSN128_neighb.mat'

Nsubj       = 11;
design      = zeros(4, Nsubj*8);
design(1,:) = repmat(1:Nsubj, 1, 8);                % this is the uvar (unit-of-observation variable)
design(2,:) = [repmat(1, 1, 44), repmat(2, 1, 44)];  % this is the ivar (independent variable)
design(3,:) = repmat([repmat(1, 1, 22), repmat(2, 1, 22)], 1, 2); 
design(4,:) = repmat([repmat(1, 1, 11), repmat(2, 1, 11)], 1, 4);

%% Get channel locations
% channel neighbours are not really needed for the subsequent example, since we restrict the test to a single channel
% nevertheless, we will determine the channel neighbours here anyway

cfg          = [];
cfg.method   = 'template';
cfg.template = 'threshold_free_clustering/data/fieldtrip_demo/ctf151_neighb.mat';
nb = neighbours;

%% Conventional cluster-based permutation test
% cfg                  = [];
% cfg.design           = design;
% cfg.uvar             = 1;
% cfg.ivar             = 2;
% cfg.channel          = {'MLT12'};
% cfg.latency          = [0 1];
% cfg.method           = 'montecarlo';
% cfg.statistic        = 'depsamplesT';
% cfg.numrandomization = 'all';   % there are 10 subjects, so 2^10=1024 possible raondomizations
% cfg.tail             = 0;
% cfg.alpha            = 0.025;   % since we are testing two tails
% cfg.neighbours       = nb;      % this will not be used, since we selected only a single channel
% cfg.correctm         = 'cluster';
% cfg.clusterstatistic = 'maxsum';
% cfg.clusterthreshold = 'nonparametric_individual';
% cfg.clustertail      = 0;
% cfg.clusteralpha     = 0.01;
% stat01 = ft_timelockstatistics(cfg, allsubjFIC{:}, allsubjFC{:});
% 
% cfg.clusteralpha     = 0.05;
% stat05 = ft_timelockstatistics(cfg, allsubjFIC{:}, allsubjFC{:});
% 
% %% Cluster-based permutation test with TFCE method
% cfg                  = [];
% cfg.design           = design;
% cfg.uvar             = 1;
% cfg.ivar             = 2;
% cfg.channel          = {'MLT12'};
% cfg.latency          = [0 1];
% cfg.method           = 'montecarlo';
% cfg.statistic        = 'depsamplesT';
% cfg.numrandomization = 'all';   % there are 10 subjects, so 2^10=1024 possible raondomizations
% cfg.tail             = 0;
% cfg.alpha            = 0.025;   % since we are testing two tails
% cfg.neighbours       = nb;      % this will not be used, since we selected only a single channel
% cfg.correctm         = 'tfce';
% cfg.tfce_H           = 2;       % default setting
% cfg.tfce_E           = 0.5;     % default setting
% statA = ft_timelockstatistics(cfg, allsubjFIC{:}, allsubjFC{:});
% 
% cfg.tfce_H           = 2;
% cfg.tfce_E           = 0.25;
% statB = ft_timelockstatistics(cfg, allsubjFIC{:}, allsubjFC{:});
