function [ft_S, ft_T, ft_M, ft_N, ft_L, ft_H] = split_ft_by_condition(ft)
    cfg=[];
    cfg.trials = strcmp(ft.trialinfo.talker, "S");
    ft_S = ft_selectdata(cfg, ft);
    cfg.trials = strcmp(ft.trialinfo.talker, "T");
    ft_T = ft_selectdata(cfg, ft);
    cfg.trials = strcmp(ft.trialinfo.meaning, "M");
    ft_M = ft_selectdata(cfg, ft);
    cfg.trials = strcmp(ft.trialinfo.meaning, "N");
    ft_N = ft_selectdata(cfg, ft);
    cfg.trials = strcmp(ft.trialinfo.constraint, "L");
    ft_L = ft_selectdata(cfg, ft);
    cfg.trials = strcmp(ft.trialinfo.constraint, "H");
    ft_H = ft_selectdata(cfg, ft);
end