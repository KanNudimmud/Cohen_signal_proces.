%% Outlier detection
% Outlier time windows via sliding RMS
%%
% Generate signal with varying variability
n = 2000;
p = 15; % poles for random interpolation

% Amplitude modulator
signal = interp1(randn(p,1)*3,linspace(1,p,n),'pchip');
signal = signal + randn(1,n);

% Add some high-amplitude noise
signal(200:220)   = signal(200:220) + randn(1,21)*9;
signal(1500:1600) = signal(1500:1600) + randn(1,101)*9;

% Plot
figure(1), clf, hold on
plot(signal)

%% Detect bad segments using sliding RMS
% Window size as percent of total signal length
pct_win = 2; % in percent, not proportion!

% Convert to indices
k = round(n * pct_win/2/100);

% Initialize RMS time series vector
rms_ts = zeros(1,n);

for ti=1:n
    % Boundary points
    low_bnd = max(1,ti-k);
    upp_bnd = min(n,ti+k);
    
    % Signal segment (and mean-center!)
    tmpsig = signal(low_bnd:upp_bnd);
    tmpsig = tmpsig - mean(tmpsig);
    
    % Compute RMS in this window
    rms_ts(ti) = sqrt(sum( tmpsig.^2 ));
end

% Plot RMS
figure(2), clf, hold on
plot(rms_ts,'s-')

% Pick threshold manually based on visual inspection
thresh = 15;
plot(get(gca,'xlim'),[1 1]*thresh,'r')
legend({'Local RMS';'Threshold'})

% Mark bad regions in original time series
signalR = signal;
signalR( rms_ts>thresh ) = NaN;

figure(1), clf, hold on
plot(signal,'b')
plot(signalR,'r')
legend({'Original';'Thresholded'})

%% end.