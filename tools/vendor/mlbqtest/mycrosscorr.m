function [xcf,b,bounds,xcf_signficant] = mycrosscorr(x,nlags,varargin)
% MYCROSSCORR(X,NLAGS) Calculates cross correlation of multiple securities.
%
% XCF = MYCROSSCORR(X,NLAGS) returns the cross correlations (a cell of
%   dimension 1x(nlags+1) corresponding to lag=0,1,...,nlags
% XCF = MYCROSSCORR(X,NLAGS,NSTD) specifiy number (a non-negative) of
%   standard error for computing confidence levels. Default: 2
% [XCF,B] = MYCROSSCORR(~) returns corresponding lags
% [XCF,B,BOUNDS] = MYCROSSCORR(~) returns approximate upper (1st cell) and
%   lower (2nd cell condience bounds.
% [XCF,B,BOUNDS,XCF_SIGNIFICANCE] = MYCROSSCORR(~) returns flags to
%   indicate signficance cross correlations coefficients. 0 for
%   non-signficant, 1 for sigificant possitive correlations, -1 for
%   signficant negative correlations. 
%
% Input argument X: a multivariate time-series (T x k) with k assets and T
%   times.
%
% Output argument XCF: a 1 x (nlags+1) cell corresponding to the cross
%   correlation for lag=0,1,2,...,nlags. For each lag, the cross
%   correlation matrix contains k x k coefficients with diagonal
%   corresponding to the autocorrelation of each asset (self-correlation).
%   Off-diagnoal elements are cross-correlations. Elements in the upper
%   triangle (i.e. above the diagonal line) are correlations with column
%   asset lagged; elements in the lower triangle (i.e. below the diagonal
%   line) are correlations with row asset lagged. For example, the (i,j)
%   element (the ith row and the jth column) is the correlation coefficient
%   of the ith asset and lagged jth asset.  
%
% See also CROSSCORR.

% NPQ $2019/02/15$

if nargin ~=2 && nargin~=3
    error('Invalid input argument');
end
if nargin == 2
    nstd = 2;   % default number of std
else
    nstd = varargin{1};
end

% --- calculate cross correlation for each pair
k = size(x,2);  % number of securites
xcf_cell = cell(k,k);
bounds_cell = cell(k,k);
for ii=1:k
    for jj=1:k
        [xcf_tmp,b,bounds_tmp] = crosscorr(x(:,jj),x(:,ii),'NumLags',nlags,'NumSTD',nstd);  % the seond input is the lagged one
        xcf_cell{ii,jj} = xcf_tmp(nlags+1:end);
        bounds_cell{ii,jj} = bounds_tmp;
    end
end

% --- collect corrrelation coefficients 
xcf = cell(1,nlags);
for ilag=0:nlags
    xcf{ilag+1} = cellfun(@(x)x(ilag+1),xcf_cell);
end
bounds = cell(1,2);
bounds{1} = cellfun(@(x)x(1),bounds_cell);   % bounds are identical for a given lag since it only depends on number of observaions
bounds{2} = cellfun(@(x)x(2),bounds_cell);
b = b(nlags+1:end);

xcf_signficant = cell(1,nlags);
for ilag = 0:nlags
    xcf_signficant{ilag+1} = double(xcf{ilag+1} > bounds{1}) - double(xcf{ilag+1}<bounds{2});
end
