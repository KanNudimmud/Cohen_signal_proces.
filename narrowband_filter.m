%% Wavelet convolution for narrowband filtering
%%
% Simulation parameters
srate = 4352; % hz
npnts = 8425;
time  = (0:npnts-1)/srate;
hz    = linspace(0,srate/2,floor(npnts/2)+1);

% Pure noise signal
signal = exp( .5*randn(1,npnts) );

% Let's see what it looks like
figure(1), clf
subplot(211)
plot(time,signal,'k')
xlabel('Time (s)'), ylabel('Amplitude')

% In the frequency domain
signalX = 2*abs(fft(signal));
subplot(212)
plot(hz,signalX(1:length(hz)),'k')
set(gca,'xlim',[1 srate/6])
xlabel('Frequency (Hz)'), ylabel('Amplitude')

%% Create and inspect the Morlet wavelet
% Wavelet parameters
ffreq = 34; % filter frequency in Hz
fwhm  = .12; % full-width at half-maximum in seconds
wavtime = -3:1/srate:3; % wavelet time vector (same sampling rate as signal!)

% Create the wavelet
morwav = cos(2*pi*ffreq*wavtime) .* exp( -(4*log(2)*wavtime.^2) / fwhm.^2 );

% Amplitude spectrum of wavelet
% (note that the wavelet needs its own hz because different length)
wavehz = linspace(0,srate/2,floor(length(wavtime)/2)+1);
morwavX = 2*abs(fft(morwav));

% Plot it!
figure(2), clf
subplot(211)
plot(wavtime,morwav,'k')
xlabel('Time (sec.)')

subplot(212)
plot(wavehz,morwavX(1:length(wavehz)),'k')
set(gca,'xlim',[0 ffreq*2])
xlabel('Frequency (Hz)')

%% Now for convolution
convres = conv(signal,morwav,'same');

% Show in the time domain
figure(1)
subplot(211), hold on
plot(time,convres,'r')

% And in the frequency domain
subplot(212), hold on
convresX = 2*abs(fft(convres));
plot(hz,convresX(1:length(hz)),'r')

%%% Time-domain wavelet normalization is... annoying and difficult.
%%% Let's do it in the frequency domain

%% "Manual" convolution
nConv = npnts + length(wavtime) - 1;
halfw = floor(length(wavtime)/2)+1;

% Spectrum of wavelet
morwavX = fft(morwav,nConv);

% Now normalize in the frequency domain
morwavX = morwavX ./ max(morwavX);
% also equivalent:
% morwavX = (abs(morwavX)./max(abs(morwavX))) .* exp(1i*angle(morwavX));

% Now for the rest of convolution
convres = ifft( morwavX .* fft(signal,nConv) );
convres = real( convres(halfw:end-halfw+1) );

%%
figure(1), subplot(211)
plot(time,convres,'b')
legend({'Original','Filtered, no norm','Filtered, norm.'})

subplot(212)
convresX = 2*abs(fft(convres));
plot(hz,convresX(1:length(hz)),'b','linew',3)
set(gca,'ylim',[0 300])

%% To preserve DC offset, compute and add back
convres = convres + mean(signal);
figure(1), subplot(211)
plot(time,convres,'m','linew',3)

%% end.