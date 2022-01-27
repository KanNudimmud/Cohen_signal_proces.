%% Signal-to-noise ratio (SNR)
%%
pnts = 1000;
time = linspace(0,5*pi,pnts);

% One signal
signal1 = 3+sin(time);
signal1 = signal1 + randn(1,pnts);

% Another signal
signal2 = 5 + randn(1,pnts) .* (2+sin(time));

% Compute SNR in sliding windows
k = round(pnts*.05); % one-sided window is 5% of signal length

% Initialize
[snr_ts1,snr_ts2] = deal( zeros(1,pnts) );

% Loop over time points
for i=1:pnts
    % Time boundaries
    bndL = max(1,i-k);
    bndU = min(pnts,i+k);
    
    % Extract parts of signals
    sigpart1 = signal1(bndL:bndU);
    sigpart2 = signal2(bndL:bndU);
    
    % Compute windowed SNR
    snr_ts1(i) = mean(sigpart1) / std(sigpart1);
    snr_ts2(i) = mean(sigpart2) / std(sigpart2);
end

%%% Some plotting
% Plot the signals
figure(1), clf
subplot(211), hold on
plot(time,signal1+10,'linew',3)
plot(time,signal2,'linew',3)
set(gca,'ytick',[])
xlabel('Time (rad.)')
legend({'Signal 1';'Signal 2'})

% Plot SNRs
subplot(212), hold on
plot(time,snr_ts1,'linew',3)
plot(time,snr_ts2,'linew',3)
legend({'SNR 1';'SNR 2'})
xlabel('Time (rad.)')

% Plot SNRs
figure(2), clf
subplot(211), hold on
plot(time,snr_ts1,'linew',3)
plot(time,snr_ts2,'linew',3)
legend({'SNR 1';'SNR 2'})
ylabel('"Raw" SNR units')
xlabel('Time (rad.)')

subplot(212), hold on
plot(time,10*log10(snr_ts1),'linew',3)
plot(time,10*log10(snr_ts2),'linew',3)
legend({'SNR 1';'SNR 2'})
ylabel('dB SNR units')
xlabel('Time (rad.)')

%% Try in a voltage time series
% Import data
load SNRdata.mat

% Plot mean and std data time series
figure(3), clf
subplot(211)
plot(timevec,mean(eegdata,3),'linew',3)
xlabel('Time (ms)'), ylabel('Voltage (\muV)')
legend({'Chan_1';'Chan_2'})
title('Average time series')

subplot(212)
plot(timevec,std(eegdata,[],3),'linew',3)
xlabel('Time (ms)'), ylabel('Voltage (std.)')
legend({'Chan_1';'Chan_2'})
title('Standard deviation time series')

%% SNR
% Compute SNR
snr = mean(eegdata,3) ./ std(eegdata,[],3);

% Plot
figure(4), clf
plot(timevec,10*log10(snr),'linew',3)
xlabel('Time (ms)'), ylabel('SNR 10log_{10}(mean/var)')
legend({'Chan_1';'Chan_2'})
title('SNR time series')

%% Alternative: SNR at a point
% Pick time point
timepoint = 375;
basetime  = [-500 0];

% Average over repetitions
erp = mean(eegdata,3);

% SNR components
snr_num = erp(:,dsearchn(timevec',timepoint));
snr_den = std( erp(:,dsearchn(timevec',basetime(1)):dsearchn(timevec',basetime(2))) ,[],2);

% Display SNR in the command window
for i=1:2
    disp([ 'SNR at ' num2str(timepoint) 'ms in channel ' num2str(i) ' = ' num2str(snr_num(i)./snr_den(i)) ])
end

%% end.