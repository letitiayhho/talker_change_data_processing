function prepare_neighbors_egi()
    elec       = ft_read_sens('threshold_free_clustering/data/GSN-HydeoCel-128.sfp');

    cfg               = [];
    cfg.method        = 'distance';
    cfg.neighbourdist = 3;
    cfg.feedback      = 'yes';
    nb                = ft_prepare_neighbours(cfg,elec);
    nb(1:3)           = [];
    
    save('threshold_free_clustering/data/GSN128_neighb.mat', 'nb')
end
