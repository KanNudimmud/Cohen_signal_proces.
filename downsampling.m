%% Downsampling 
%% Laplace distribution
% Parameters
srate  = 100;
tv     = -5:1/srate:5;
npnts  = length(tv);

% Signal components
laplace  = 1-exp(-abs(tv));
fastsine = .25*sin(2*pi*tv*15);

% Combine into one signal (no noise)
signal = laplace + fastsine;

% Power spectrum (O = original)
hzO = linspace(0,srate/2,floor(npnts/2)+1);
signalO_pow = abs(fft(signal)/npnts).^2;
signalO_pow = signalO_pow(1:length(hzO));

figure(1), clf
subplot(211)
plot(tv,signal,'ko-','linew',2,'markerfacecolor','w','markeredgecolor','k')
xlabel('Time (s)')

subplot(212)
plot(hzO,signalO_pow,'ko-','linew',2,'markerfacecolor','w','markeredgecolor','k')
set(gca,'xlim',[0 50],'ylim',[0 .05],'yscale','lo')
xlabel('Frequency (Hz)'), ylabel('Power')

%% Downsample by a factor
dnsampleFactor = 4;
newSrate = srate/dnsampleFactor;

% New time vector after upsampling
newTv = -5:1/newSrate:5;
newPnts = length(newTv);

%%% Downsample WITHOUT low-pass filtering (bad idea!!)
signal_dsB = signal(1:dnsampleFactor:end);

% Power spectrum (B = bad)
hz_ds = linspace(0,newSrate/2,floor(newPnts/2)+1);
signal_dsB_pow = abs(fft(signal_dsB)/newPnts).^2;
signal_dsB_pow = signal_dsB_pow(1:length(hz_ds));

%%% Low-pass filter at new Nyquist frequency! (good idea!!)
fkern = fir1(14*newSrate/2,(newSrate/2)/(srate/2));
fsignal = filtfilt(fkern,1,signal);

% Downsample
signal_dsG = fsignal(1:dnsampleFactor:end);

% Power spectrum (G = good)
signal_dsG_pow = abs(fft(signal_dsG)/newPnts).^2;
signal_dsG_pow = signal_dsG_pow(1:length(hz_ds));

fsignal_pow = abs(fft(fsignal)/npnts).^2;
fsignal_pow = fsignal_pow(1:length(hz_ds));

% Plot in the time domain
subplot(211), hold on
plot(newTv,.02+signal_dsB,'m^-','markersize',8,'markerfacecolor','m')
plot(newTv,.04+signal_dsG,'gs-','markersize',8,'markerfacecolor','g')
legend({'Original';'DS bad';'DS good'})

% Plot in the frequency domain
subplot(212), hold on
plot(hz_ds,signal_dsB_pow,'m^-','linew',1,'markerfacecolor','m','markeredgecolor','m')
plot(hz_ds,signal_dsG_pow,'gs-','linew',1,'markerfacecolor','g','markeredgecolor','g')
legend({'Original';'DS bad';'DS good'})

%% Using MATLAB's resample function (signal processing toolbox)
% Find p and q coefficients
[p,q] = rat( newSrate/srate );

% Use resample function (sigproc toolbox)
signal_dsM = resample(signal,p,q);

% Power spectrum (M = MATLAB)
signal_dsM_pow = abs(fft(signal_dsM)/newPnts).^2;
signal_dsM_pow = signal_dsM_pow(1:length(hz_ds));

% Plot it.
subplot(211)
plot(newTv,.06+signal_dsM,'rs-','markersize',8,'markerfacecolor','r')

subplot(212)
plot(hz_ds,signal_dsM_pow,'rs-','linew',1,'markerfacecolor','r','markeredgecolor','r')

%% end.