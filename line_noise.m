%% Filtering
% Remove electrical line noise and its harmonics
%%
% Load data
load lineNoiseData.mat

% Time vector
pnts = length(data);
time = (0:pnts-1)/srate;

% Compute power spectrum and frequencies vector
pwr = abs(fft(data)/pnts).^2;
hz  = linspace(0,srate,pnts);

%%% Plotting
figure(1), clf
% Time-domain signal
subplot(211)
plot(time,data,'k')
xlabel('Time (s)'), ylabel('Amplitude')
title('Time domain')

% Plot power spectrum
subplot(212)
plot(hz,pwr,'k')
set(gca,'xlim',[0 400],'ylim',[0 2])
xlabel('Frequency (Hz)'), ylabel('Power')
title('Frequency domain')

%% Narrowband filter to remove line noise
frex2notch = [ 50 150 250 ];

% Initialize filtered signal
datafilt = data;

% Loop over frequencies
for fi=1:length(frex2notch)
    % Create filter kernel using fir1
    frange  = [frex2notch(fi)-.5 frex2notch(fi)+.5];
    order   = round( 150*srate/frange(1) );
    
    % Filter kernel
    filtkern = fir1( order,frange/(srate/2),'stop' );
    
    % Visualize the kernel and its spectral response
    figure(2)
    subplot(length(frex2notch),2,(fi-1)*2+1)
    xlabel('Time points'), ylabel('Filter amplitude')
    
    plot(filtkern)
    subplot(length(frex2notch),2,(fi-1)*2+2)
    plot(linspace(0,srate,10000),abs(fft(filtkern,10000)).^2)
    set(gca,'xlim',[frex2notch(fi)-30 frex2notch(fi)+30])
    xlabel('Frequency (Hz)'), ylabel('Filter gain')
    
    % Recursively apply to data
    datafilt = filtfilt(filtkern,1,datafilt);
end

%%% Plot the signal
figure(3), clf
subplot(211), hold on
plot(time,data,'k')
h = plot(time,datafilt);
set(h,'color',[1 .9 1]*.8)
xlabel('Time (s)')
legend({'Original';'Notched'})

% Compute the power spectrum of the filtered signal
pwrfilt = abs(fft(datafilt)/pnts).^2;

% Plot power spectrum
subplot(212), cla, hold on
plot(hz,pwr,'k')
h = plot(hz,pwrfilt);
set(h,'color',[1 .7 1]*.6)
set(gca,'xlim',[0 400],'ylim',[0 2])
xlabel('Frequency (Hz)'), ylabel('Power')
title('Frequency domain')

%% end.