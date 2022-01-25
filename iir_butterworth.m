%% Filtering
% IIR Butterworth filters
%%
srate   = 1024; % hz
nyquist = srate/2;
frange  = [20 45];

% Create filter coefficients
[fkernB,fkernA] = butter(4,frange/nyquist);

% Power spectrum of filter coefficients
filtpow = abs(fft(fkernB)).^2;
hz      = linspace(0,srate/2,floor(length(fkernB)/2)+1);

%%% Plotting
figure(1), clf
subplot(221), hold on
plot(fkernB*1e5,'ks-','linew',2,'markersize',10,'markerfacecolor','w')
plot(fkernA,'rs-','linew',2,'markersize',10,'markerfacecolor','w')
xlabel('Time points'), ylabel('Filter coeffs.')
title('Time-domain filter coefficients')
legend({'B';'A'})

subplot(222)
stem(hz,filtpow(1:length(hz)),'ks-','linew',2,'markersize',10,'markerfacecolor','w')
xlabel('Frequency (Hz)'), ylabel('Power')
title('Power spectrum of filter coeffs.')

%% How to evaluate an IIR filter: filter an impulse
% Generate the impulse
impres = [ zeros(1,500) 1 zeros(1,500) ];

% Apply the filter
fimp = filter(fkernB,fkernA,impres);

% Compute power spectrum
fimpX = abs(fft(fimp)).^2;
hz = linspace(0,nyquist,floor(length(impres)/2)+1);

%%% Plot
subplot(222), cla, hold on
plot(impres,'k','linew',2)
plot(fimp,'r','linew',2)
set(gca,'xlim',[1 length(impres)],'ylim',[-1 1]*.06)
legend({'Impulse';'Filtered'})
xlabel('Time points (a.u.)')
title('Filtering an impulse')

subplot(223), hold on
plot(hz,fimpX(1:length(hz)),'ks-','linew',2,'markerfacecolor','w','markersize',10)
plot([0 frange(1) frange frange(2) nyquist],[0 0 1 1 0 0],'r','linew',4)
set(gca,'xlim',[0 100])
xlabel('Frequency (Hz)'), ylabel('Attenuation')
title('Frequency response of filter (Butterworth)')

subplot(224)
plot(hz,10*log10(fimpX(1:length(hz))),'ks-','linew',2,'markerfacecolor','w','markersize',10)
set(gca,'xlim',[0 100])
xlabel('Frequency (Hz)'), ylabel('Attenuation (log)')
title('Frequency response of filter (Butterworth)')

%% Effects of order parameter
orders = 2:7;

fkernX = zeros(length(orders),1001);
hz = linspace(0,srate,1001);

figure(2), clf
for oi=1:length(orders)
    % Create filter kernel
    [fkernB,fkernA] = butter(orders(oi),frange/nyquist);
    n(oi) = length(fkernB);
    
    % Filter the impulse response and take its power
    fimp         = filter(fkernB,fkernA,impres);
    fkernX(oi,:) = abs(fft(fimp)).^2;
    
    % Show in plot
    subplot(221), hold on
    plot((1:n(oi))-n(oi)/2,zscore(fkernB)+oi,'linew',2)
    
    subplot(222), hold on
    plot((1:n(oi))-n(oi)/2,zscore(fkernA)+oi,'linew',2)
end

% Add plot labels
subplot(221)
xlabel('Time points')
title('Filter coefficients (B)')

subplot(222)
xlabel('Time points')
title('Filter coefficients (A)')

% Plot the spectra
subplot(223), hold on
plot(hz,fkernX,'linew',2)
plot([0 frange(1) frange frange(2) nyquist],[0 0 1 1 0 0],'r','linew',4)
set(gca,'xlim',[0 100])
xlabel('Frequency (Hz)'), ylabel('Attenuation')
title('Frequency response of filter (Butterworth)')

% In log space
subplot(224)
plot(hz,10*log10(fkernX),'linew',2)
set(gca,'xlim',[0 100],'ylim',[-80 2])
xlabel('Frequency (Hz)'), ylabel('Attenuation (log)')
title('Frequency response of filter (Butterworth)')

%% end.