%% Filtered Glass Dance
% Load the file
load glassDance.mat
% this is a clip of Philip Glass, Dance VII (https://www.youtube.com/watch?v=LpewOlR-z_4)

% Play the music!
soundsc(glassclip,srate)

% Some variables for convenience
pnts = length(glassclip);
timevec = (0:pnts-1)/srate;

% Draw the time-domain signals
figure(1), clf
subplot(511)
plot(timevec,glassclip)
xlabel('Time (s)')

%% Static power spectrum and pick a frequency range
% Inspect the power spectrum
hz = linspace(0,srate/2,floor(length(glassclip)/2)+1);
powr = abs(fft(glassclip(:,1))/pnts);

subplot(512), cla
plot(hz,powr(1:length(hz)))
set(gca,'xlim',[100 2000],'ylim',[0 max(powr)])
xlabel('Frequency (Hz)'), ylabel('Amplitude')

% Pick frequencies to filter
frange = [  300  460 ];
frange = [ 1000 1100 ];
% frange = [ 1200 1450 ];

% Design an FIR1 filter
fkern = fir1(2001,frange/(srate/2),'bandpass');

% Apply the filter to the signal
filtglass(:,1) = filtfilt(fkern,1,glassclip(:,1));
filtglass(:,2) = filtfilt(fkern,1,glassclip(:,2));

% Plot the filtered signal power spectrum
hold on
powr = abs(fft(filtglass(:,1))/pnts);
plot(hz,powr(1:length(hz)),'r')

% Plot the time-frequency response
subplot(5,1,3:5)
spectrogram(glassclip(:,1),hann(round(srate/10)),[],[],srate,'yaxis');
hold on
plot(timevec([1 1; end end]),frange([1 2; 1 2])/1000,'k:','linew',2)

set(gca,'ylim',[0 2])

%% Play the sound
soundsc(filtglass,srate)

%% end.