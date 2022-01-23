%% Convolution with frequency-domain Gaussian (narrowband filter)
%% Create the signal
% Create signal
srate = 1000; % Hz
time  = 0:1/srate:3;
n     = length(time);
p     = 15; % poles for random interpolation

% Noise level, measured in standard deviations
noiseamp = 5; 

% Amplitude modulator and noise level
ampl   = interp1(rand(p,1)*30,linspace(1,p,n));
noise  = noiseamp * randn(size(time));
signal = ampl + noise;

% Subtract mean to eliminate DC
signal = signal - mean(signal);

%% Create Gaussian spectral shape
% Specify Gaussian parameters
peakf = 11;
fwhm  = 5.2;

% Vector of frequencies
hz = linspace(0,srate,n);

% Frequency-domain Gaussian
s  = fwhm*(2*pi-1)/(4*pi); % normalized width
x  = hz-peakf;             % shifted frequencies
fx = exp(-.5*(x/s).^2);    % gaussian

%% Now for convolution
% FFTs
dataX = fft(signal);

% IFFT
convres = 2*real( ifft( dataX.*fx ));

% Frequencies vector
hz = linspace(0,srate,n);

%% Plots
%%% Time-domain plot
figure(1), clf, hold on

% Lines
plot(time,signal,'r')
plot(time,convres,'k','linew',2)

% Frills
xlabel('Time (s)'), ylabel('amp. (a.u.)')
legend({'Signal';'Smoothed'})
title('Narrowband filter')

%%% Frequency-domain plot
figure(2), clf

% Plot Gaussian kernel
subplot(511)
plot(hz,fx,'k','linew',2)
set(gca,'xlim',[0 30])
ylabel('Gain')
title('Frequency-domain Gaussian')

% Raw and filtered data spectra
subplot(5,1,[2:5]), hold on
plot(hz,abs(dataX).^2,'rs-','markerfacecolor','w','markersize',13,'linew',2)
plot(hz,abs(dataX.*fx).^2,'bo-','linew',2,'markerfacecolor','w','markersize',8)

% Frills
xlabel('Frequency (Hz)'), ylabel('Power (a.u.)')
legend({'Signal';'Convolution result'})
title('Frequency domain')
set(gca,'xlim',[0 25])

%% end.