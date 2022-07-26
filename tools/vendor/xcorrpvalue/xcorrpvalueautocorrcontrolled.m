function [pvaluepermuting1,pvaluepermuting2]=xcorrpvalueautocorrcontrolled(series1,series2,maxi,numtests,PLOT)
%xcorrpvalueautocorrcontrolled Yields p value of the max absolute value of a cross correlation
% SERIES1 and SERIES2 are the two series cross-correlated, and MAXI is the
% max of their crosscorrelogram
% NUMTESTS (optional, default 100) is the # of tests to use
% PLOT is 1 to plot autocorrelation of each series and randomized series, 0 by default
% This function approximately preserves the autocorrelation of each series
% Copyright Alex Backer May 2020

if nargin<4,
    numtests=100;
end
if nargin<5,
    PLOT=0;
end

l1=length(series1);l2=length(series2);
count1=0;count2=0;randomizedseries1=[];randomizedseries2=[];
for i=1:numtests,
    [autocorrelation,lags]=xcorr(series1);
    
    if PLOT,
        figure(1);
        stem(lags,autocorrelation);
        title('Series 1 autocorrelation')
    end
    
    autocorrelation=abs(autocorrelation);
    for j=1:l1,
        sample=[];
        while isempty(sample) | j+sample<1 | j+sample>l1
            sample=datasample(lags,1,'Weights',autocorrelation); %,'Replace',false);
        end
        randomizedseries1(j)=series1(j+sample);
    end
    [xc,lags]=xcorr(randomizedseries1,series2);
  %   [xc,lags]=xcorr(smooth(series1(randperm(l1))),series2);
     maxc=max(abs(xc));
     if maxc>maxi,
         count1=count1+1;
     end
  
      [autocorrelation,lags]=xcorr(randomizedseries1);
      if PLOT,
          figure(2);
          stem(lags,autocorrelation);
        title('Randomized series 1 autocorrelation')
      end
      
    [autocorrelation,lags]=xcorr(series2);
    if PLOT,
        figure(3);
        stem(lags,autocorrelation);
        title('Series 2 autocorrelation')
    end
    
    autocorrelation=abs(autocorrelation);
%    randomizedseries2=series2+datasample(lags,l2,'Weights',autocorrelation,'Replace',false);
    for j=1:l2,
        sample=[];
        while isempty(sample) | j+sample<1 | j+sample>l2
            sample=datasample(lags,1,'Weights',autocorrelation); %,'Replace',false);
        end
         randomizedseries2(j)=series2(j+sample);
   end
     [xc,lags]=xcorr(series1,randomizedseries2);
  %   [xc,lags]=xcorr(smooth(series1(randperm(l1))),series2);
     maxc=max(abs(xc));
     if maxc>maxi,
         count2=count2+1;
     end
      [autocorrelation,lags]=xcorr(randomizedseries2);
      
      if PLOT,
          figure(4);
          stem(lags,autocorrelation);
        title('Randomized series 2 autocorrelation')
        pause
      end

end
pvaluepermuting1=count1/numtests;
pvaluepermuting2=count2/numtests;
