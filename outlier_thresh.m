%% Outlier detection
% Outliers via local threshold exceedance
%%
% Data downloaded from:
% http://www.histdata.com/download-free-forex-historical-data/?/ascii/1-minute-bar-quotes/eurusd/2017

% Import data
load forex.mat
N = length(forex);
time = (0:N-1)'/N;

% Plot it
figure(1), clf, hold on
plot(time,forex)
xlabel('Time (year)'), ylabel('EUR/USD')

% Add global thresholds
plot(get(gca,'xlim'),[1 1]*(mean(forex)+3*std(forex)),'r--')
plot(get(gca,'xlim'),[1 1]*(mean(forex)-3*std(forex)),'k--')
legend({'EUR/USD';'M+3std';'M-3std'})

%% Local threshold
% Window size as percent of total signal length
pct_win = 5; % in percent, not proportion!

% Convert to indices
k = round(length(forex) * pct_win/2/100);

% Initialize statistics time series to be the global stats
mean_ts = ones(size(time)) * mean(forex);
std3_ts = ones(size(time)) * std(forex);

for i=1:N    
    % Boundaries
    lo_bnd = max(1,i-k);
    hi_bnd = min(i+k,N);
    
    % Compute local mean and std
    mean_ts(i) =  mean( forex(lo_bnd:hi_bnd) );
    std3_ts(i) = 3*std( forex(lo_bnd:hi_bnd) );
end

% Plot the uncertainty
figure(2), clf, hold on
h = patch([time; time(end:-1:1)],[mean_ts+std3_ts; mean_ts(end:-1:1)-std3_ts(end:-1:1)],'m');

% Plot the data
plot(time,forex,'k','linew',2)

%%% Compute local outliers
outliers = forex > (mean_ts+std3_ts) | forex < (mean_ts-std3_ts);

% And plot those
plot(time(outliers),forex(outliers),'ro','markerfacecolor','r')

%%% Finishing touches on the plot
legend({'Mean +/- 3std';'EUR/USD';'Outliers'})
set(h,'linestyle','none','facealpha',.4)
xlabel('Time (year)'), ylabel('EUR/USD')
title([ 'Using a ' num2str(pct_win) '% window size' ])

%% end.