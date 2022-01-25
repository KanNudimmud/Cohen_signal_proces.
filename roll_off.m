%% Filtering
% Quantifying roll-off characteristics
%% Create a windowed sinc filter
% Simulation parameters
srate = 1000;
time  = -4:1/srate:4;
pnts  = length(time);

% FFT parameters
nfft = 10000;
hz   = linspace(0,srate/2,floor(nfft/2)+1);

filtcut = 15;
sincfilt = sin(2*pi*filtcut*time) ./ time;

% Adjust NaN and normalize filter to unit-gain
sincfilt(~isfinite(sincfilt)) = max(sincfilt);
sincfilt = sincfilt./sum(sincfilt);

% Windowed sinc filter
hannw = .5 - cos(2*pi*linspace(0,1,pnts))./2;
sincfiltW = sincfilt .* hannw;

% Spectrum of filter
sincX = 10*log10(abs(fft(sincfiltW,nfft)).^2);
sincX = sincX(1:length(hz));

%% Create a Butterworth low-pass filter
% Generate filter coefficients (Butterworth)
[filtb,filta] = butter(5,filtcut/(srate/2),'low');

% Test impulse response function (IRF)
impulse  = [ zeros(1,500) 1 zeros(1,500) ];
fimpulse = filtfilt(filtb,filta,impulse);

% Spectrum of filter response
butterX = 10*log10(abs(fft(fimpulse,nfft)).^2);
butterX = butterX(1:length(hz));

%% Plot frequency responses
% Plot
figure(1), clf, hold on
plot(hz,sincX, hz,butterX, 'linew',2)
plotedge = dsearchn(hz',filtcut*3);
set(gca,'xlim',[0 filtcut*3],'ylim',[min([butterX(plotedge) sincX(plotedge)]) 5])

plot([1 1]*filtcut,get(gca,'ylim'),'k--','linew',2)

% Find -3 dB after filter edge
filtcut_idx = dsearchn(hz',filtcut);

sincX3db   = dsearchn(sincX',-3);
butterX3db = dsearchn(butterX',-3);

% Add to the plot
plot([1 1]*hz(sincX3db),get(gca,'ylim'),'b--')
plot([1 1]*hz(butterX3db),get(gca,'ylim'),'r--')

% Find double the frequency
sincXoct   = dsearchn(hz',hz(sincX3db)*2);
butterXoct = dsearchn(hz',hz(butterX3db)*2);

% Add to the plot
plot([1 1]*hz(sincXoct),get(gca,'ylim'),'b--')
plot([1 1]*hz(butterXoct),get(gca,'ylim'),'r--')

% Find attenuation from that point to double its frequency
sincXatten   = sincX(sincX3db*2);
butterXatten = butterX(butterX3db*2);

sincXrolloff   = (sincX(sincX3db)-sincX(sincXoct)) / (hz(sincXoct)-hz(sincX3db));
butterXrolloff = (butterX(butterX3db)-butterX(butterXoct)) / (hz(butterXoct)-hz(butterX3db));

% Report!
title([ 'Sinc: ' num2str(sincXrolloff) ', Butterworth: ' num2str(butterXrolloff) ])
legend({'Windowed sinc';'Butterworth'})
xlabel('Frequency (Hz)'), ylabel('Gain (dB)')

%% end.