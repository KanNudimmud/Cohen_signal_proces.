%% Resample irregularly sampled data
%%
% Simulation parameters
srate    = 1324;    % Hz
peakfreq =    7;    % Hz
fwhm     =    5;    % Hz
npnts    = srate*2; % time points
timevec  = (0:npnts-1)/srate; % seconds

% Frequencies
hz = linspace(0,srate,npnts);
s  = fwhm*(2*pi-1)/(4*pi); % normalized width
x  = hz-peakfreq;          % shifted frequencies
fg = exp(-.5*(x/s).^2);    % gaussian

% Fourier coefficients of random spectrum
fc = rand(1,npnts) .* exp(1i*2*pi*rand(1,npnts));

% Taper with Gaussian
fc = fc .* fg;

% Go back to time domain to get signal
signal = 2*real( ifft(fc) )*npnts;

%%% Plot 
figure(1), clf, hold on
plot(timevec,signal,'k','linew',3)
xlabel('Time (s)')

%% Now randomly sample from this "continuous" time series
% Initialize to empty
sampSig = [];

% Random sampling intervals
sampintervals = cumsum([ 1; ceil( exp(4*rand(npnts,1)) ) ]);
sampintervals(sampintervals>npnts) = []; % remove points beyond the data

% Loop through sampling points and "measure" data
for i=1:length(sampintervals)
    % "real world" measurement
    nextdat = [signal(sampintervals(i)); timevec(sampintervals(i))];
    
    % Put in data matrix
    sampSig = cat(2,sampSig,nextdat);
end

% More plotting
plot(sampSig(2,:),sampSig(1,:),'ro','markerfacecolor','r','markersize',12)

%% Upsample to original sampling rate
% Define interpolation object
F = griddedInterpolant(sampSig(2,:),sampSig(1,:),'spline');

% Query that object at requested time points
newsignal = F(timevec);

% Plot
plot(timevec,newsignal,'ms','markersize',10,'markerfacecolor','m')
legend({'"Analog"';'Measured';'Upsampled'})

%% end.