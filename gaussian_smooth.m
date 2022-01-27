%% Gaussian-smooth a time series
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

%% Create Gaussian kernel
% Full-width half-maximum: the key Gaussian parameter
fwhm = 25.5484; % in ms

% Normalized time vector in ms
k = 40;
gtime = 1000*(-k:k)/srate;

% Create Gaussian window
gauswin = exp( -(4*log(2)*gtime.^2) / fwhm^2 );

% Compute empirical FWHM
pstPeakHalf = k+dsearchn(gauswin(k+1:end)',.5);
prePeakHalf = dsearchn(gauswin(1:k)',.5);

empFWHM = gtime(pstPeakHalf) - gtime(prePeakHalf);

% Show the Gaussian
figure(1), clf, hold on
plot(gtime,gauswin,'ko-','markerfacecolor','w','linew',2)
plot(gtime([prePeakHalf pstPeakHalf]),gauswin([prePeakHalf pstPeakHalf]),'m','linew',3)

% Then normalize Gaussian to unit energy
gauswin = gauswin / sum(gauswin);
title([ 'Gaussian kernel with requeted FWHM ' num2str(fwhm) ' ms (' num2str(empFWHM) ' ms achieved)' ])
xlabel('Time (ms)'), ylabel('Gain')

%% Implement the filter
% Initialize filtered signal vector
filtsigG = signal;

% Implement the running mean filter
for i=k+1:n-k-1
    % Each point is the weighted average of k surrounding points
    filtsigG(i) = sum( signal(i-k:i+k).*gauswin );
end

% Plot
figure(2), clf, hold on
plot(time,signal,'r')
plot(time,filtsigG,'k','linew',3)

xlabel('Time (s)'), ylabel('amp. (a.u.)')
legend({'Original signal';'Gaussian-filtered'})
title('Gaussian smoothing filter')

%% For comparison, plot mean smoothing filter
% Initialize filtered signal vector
filtsigMean = zeros(size(signal));

% Implement the running mean filter
k = 20; % filter window is actually k*2+1
for i=k+1:n-k-1
    % each point is the average of k surrounding points
    filtsigMean(i) = mean(signal(i-k:i+k));
end

plot(time,filtsigMean,'b','linew',2)
legend({'Original signal';'Gaussian-filtered';'Running mean'})
zoom on

%% end.