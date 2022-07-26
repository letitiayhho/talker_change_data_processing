function [h,pValue,stat,cValue] = mlbqtest(x,lags,varargin)
% MLBQTEST(X,LAGS) performs multivariate Portmanteau test.
%
% h = mlbqtest(X,LAGS) returns returns a logical value (h) for LAGS with the
%   rejection decision from conducting a multivariate Portmanteau test for
%   joint cross-correlation in a mutlivariate series X (Txk).
% h = mlbqtest(X,LAGS,DOF) specifies the degree of freedom (default=k^2*lags).
% h = mlbqtest(X,LAGS,DOF,ALPHA) or h = mlbqtest(X,LAGS,[],ALPHA specifies
%   the signficance level (default=0.05).
% [h,pValue] = mlbqtest(~) returns the rejection decision and p-value for
%   the hypothesis test.
% [h,pValue,stat,cValue] = mlbqtest(~) additionally returns the test
%   statistic (stat) and critical value (cValue) for the hypothesis test. 
%
% Input argument 
%   X: a multivariate time-series (T x k) with k assets and T
%       times.
%   LAGS: specifies the lags (non-negative integer scalar or list)
%   DOF: if input value is [], then default value is taken (k^2*lags). If
%       specified, its length must match the length of LAGS
%   ALPHA: signficane level for h and cValue calculations. If [], the
%       default value 0.05 is used.
%
% See also LBQTEST, MYCROSSCORR
%
% Reference:
% 1. R.S. Tsay, Analysis of Financial Time Series. Wiley, 3rd edition, 2010
% 2. J.R.M. Hosking, The multivariate portmanteau statistic. Journal of the
%   American Statistical Association 75: 602–608 (1980)
% 3. J.R.M. Hosking, Lagrange-multiplier tests of multivariate time series
%   models. Journal of the Royal Statistical Society Series B 43: 219–230
%   (1981)
% 4. W.K. Li and A.I. McLeod,Distribution of the residual autocorrelations
%   in multivariate ARMA time series models. Journal of the Royal
%   Statistical Society Series B 43: 231–239 (1981)
% 
% By Newport Quantitative
% https://newportquant.com
% Revision 1.0.2 $2019/02/22$

if nargin ~=2 && nargin~=3 &&  nargin~=4
    error('Invalid input argument');
end

nlags = max(lags);
lag_list = 1:nlags; 
T = size(x,1);    % total number of observations
k = size(x,2);    % number of assets

% --- determine dof and alpha 
if nargin == 2
    dof     = [];
    alpha   = [];    
elseif nargin == 3
    dof     = varargin{1};
    alpha   = [];
elseif nargin == 4
    dof     = varargin{1};
    alpha   = varargin{2};
end
% --- set default values
if isempty(alpha)
    alpha = 0.05;  
end
if isempty(dof)
    dof = k^2*lag_list;    % degree of freedom
else
    dof_lags = dof;
    dof =  k^2*lag_list;
    dof(lags) = dof_lags;   % use default lags for other lags.
end


% --- get cross-correlations
D = diag(std(x));     % diagonal matrix (kxk) of standard deviations of each asset
xcf = mycrosscorr(x,nlags);     % cross-correlation coefficient matrix
gamma = cellfun(@(x)D*x*D,xcf,'UniformOutput',false);   % cross-covraince coefficient matrix

% --- LBQ test

Q_mat = nan(1,nlags);
for ilag=1:nlags
    Q_mat(ilag) = trace(transpose(gamma{ilag+1})*pinv(gamma{1})*gamma{ilag+1}*pinv(gamma{1})) / (T-ilag);
end
Q = T^2*cumsum(Q_mat);
pValue =  chi2cdf(Q,dof,'upper');
cValue = chi2inv(1-alpha,dof);
h = Q>cValue;

% --- collect result
h = h(lags);
pValue = pValue(lags);
stat = Q(lags);
cValue = cValue(lags);