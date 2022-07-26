ret = load('ret.dat');  % return of two assets

% --- use default DOF and ALPHA
% [h,pValue,stat,cValue] = mlbqtest(rtn,[3,6,10]);

% --- specifiy DOF
% [h,pValue,stat,cValue] = mlbqtest(rtn,[3,6,10],[20,24,34]);   

% --- use default DOF, and specified ALPHA
alpha = 0.01;
[h,pValue,stat,cValue] = mlbqtest(ret,[4,8],[],alpha);   % 5% significance level
