%% Convolution with Planck taper (bandpass filter)
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

%% Create Planck spectral shape
% Frequencies
hz = linspace(0,srate,n);

% Edge decay, must be between 0 and .5
eta = .15;

% Spectral parameters
fwhm  = 13;
peakf = 20;

% Convert fwhm to indices
np = round( 2*fwhm*n/srate );
pt = 1:np;

% Find center point index
fidx = dsearchn(hz',peakf);

% Define left and right exponentials
Zl = eta*(np-1) * ( 1./pt + 1./(pt-eta*(np-1)) );
Zr = eta*(np-1) * ( 1./(np-1-pt) + 1./( (1-eta)*(np-1)-pt ) );

% Create the taper
bounds = [ floor(eta*(np-1))-mod(np,2) ceil((1-eta)*(np-~mod(np,2))) ];
plancktaper = [ 1./(exp(Zl(1:bounds(1)))+1) ...
                ones(1,diff(bounds)) ... 
                1./(exp(Zr(bounds(2):end-1))+1) ];

% Put the taper inside zeros
px = zeros( size(hz) );
pidx = max(1,fidx-floor(np/2)+1) : fidx+floor(np/2)-mod(np,2);
px(pidx) = plancktaper;

%% Now for convolution
% FFTs
dataX = fft(signal);

% IFFT
convres = 2*real( ifft( dataX.*px ));

% frequencies vector
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
plot(hz,px,'k','linew',2)
set(gca,'xlim',[0 peakf*2])
ylabel('Gain')
title('Frequency-domain Planck taper')

% Raw and filtered data spectra
subplot(5,1,[2:5]), hold on
plot(hz,abs(dataX).^2,'rs-','markerfacecolor','w','markersize',13,'linew',2)
plot(hz,abs(dataX.*px).^2,'bo-','linew',2,'markerfacecolor','w','markersize',8)

% Frills
xlabel('Frequency (Hz)'), ylabel('Power (a.u.)')
legend({'Signal';'Convolution result'})
title('Frequency domain')
set(gca,'xlim',[0 peakf*2])

%% end.