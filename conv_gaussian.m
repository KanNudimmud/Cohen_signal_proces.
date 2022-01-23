%% Convolution with time-domain Gaussian (smoothing filter)
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

%% Create Gaussian kernel
% Full-width half-maximum: the key Gaussian parameter
fwhm = 25; % in ms

% Normalized time vector in ms
k = 100;
gtime = 1000*(-k:k)/srate;

% Create Gaussian window
gauswin = exp( -(4*log(2)*gtime.^2) / fwhm^2 );

% Then normalize Gaussian to unit energy
gauswin = gauswin / sum(gauswin);

%% Filter as time-domain convolution
% Initialize filtered signal vector
filtsigG = signal;

% Implement the running mean filter
for i=k+1:n-k-1
    % each point is the weighted average of k surrounding points
    filtsigG(i) = sum( signal(i-k:i+k).*gauswin );
end

%% Repeat in the frequency domain
% Compute N's
nConv = n + 2*k+1 - 1;

% FFTs
dataX = fft(signal,nConv);
gausX = fft(gauswin,nConv);

% IFFT
convres = ifft( dataX.*gausX );

% Cut wings
convres = convres(k+1:end-k);

% Frequencies vector
hz = linspace(0,srate,nConv);

%% Plots
%%% Time-domain plot
figure(1), clf, hold on

% Lines
plot(time,signal,'r')
plot(time,filtsigG,'k*-')
plot(time,convres,'bo')

% Frills
xlabel('Time (s)'), ylabel('amp. (a.u.)')
legend({'Signal';'Time-domain';'Spectral multiplication'})
title('Gaussian smoothing filter')

%%% Frequency-domain plot
figure(2), clf

% Plot Gaussian kernel
subplot(511)
plot(hz,abs(gausX).^2,'k','linew',2)
set(gca,'xlim',[0 30])
ylabel('Gain')
title('Power spectrum of Gaussian')

% Raw and filtered data spectra
subplot(5,1,[2:5]), hold on
plot(hz,abs(dataX).^2,'rs-','markerfacecolor','w','markersize',13,'linew',2)
plot(hz,abs(dataX.*gausX).^2,'bo-','linew',2,'markerfacecolor','w','markersize',8)

% Frills
xlabel('Frequency (Hz)'), ylabel('Power (a.u.)')
legend({'Signal';'Convolution result'})
title('Frequency domain')
set(gca,'xlim',[0 25])

%% end.