%% Convolution with wavelets
%% General simulation parameters
fs = 1024;
npnts = fs*5; % 5 seconds

% Centered time vector
timevec = (1:npnts)/fs;
timevec = timevec - mean(timevec); 

% For power spectrum
hz = linspace(0,fs/2,floor(npnts/2)+1);

%% Morlet wavelet
% Parameters
freq = 4; % peak frequency
csw  = cos(2*pi*freq*timevec); % cosine wave
fwhm = .5; % full-width at half-maximum in seconds
gaussian = exp( -(4*log(2)*timevec.^2) / fwhm^2 ); % Gaussian

% Morlet wavelet
MorletWavelet = csw .* gaussian;

%% Haar wavelet
HaarWavelet = zeros(npnts,1);
HaarWavelet(dsearchn(timevec',0):dsearchn(timevec',.5)) = 1;
HaarWavelet(dsearchn(timevec',.5):dsearchn(timevec',1-1/fs)) = -1;

%% Mexican hat wavelet
s = .4;
MexicanWavelet = (2/(sqrt(3*s)*pi^.25)) .* (1- (timevec.^2)/(s^2) ) .* exp( (-timevec.^2)./(2*s^2) );

%% Convolve with random signal
% Signal
signal = detrend(cumsum(randn(npnts,1)));

% Convolve signal with different wavelets
morewav = conv(signal,MorletWavelet,'same');
haarwav = conv(signal,HaarWavelet,'same');
mexiwav = conv(signal,MexicanWavelet,'same');

% Amplitude spectra
morewaveAmp = abs(fft(morewav)/npnts);
haarwaveAmp = abs(fft(haarwav)/npnts);
mexiwaveAmp = abs(fft(mexiwav)/npnts);

%% Plotting
figure(2), clf

% The signal
subplot(511)
plot(timevec,signal,'k')
title('Signal')
xlabel('Time (s)'), ylabel('Amplitude')

% The convolved signals
subplot(5,1,2:3), hold on
plot(timevec,morewav,'linew',2)
plot(timevec,haarwav,'linew',2)
plot(timevec,mexiwav,'linew',2)

xlabel('Time (sec.)'), ylabel('Amplitude')
legend({'Morlet';'Haar';'Mexican'})

% Spectra of convolved signals
subplot(5,1,4:5), hold on
plot(hz,morewaveAmp(1:length(hz)),'linew',2)
plot(hz,haarwaveAmp(1:length(hz)),'linew',2)
plot(hz,mexiwaveAmp(1:length(hz)),'linew',2)

set(gca,'xlim',[0 40],'yscale','lo')
xlabel('Frequency (Hz.)'), ylabel('Amplitude')

%% end.