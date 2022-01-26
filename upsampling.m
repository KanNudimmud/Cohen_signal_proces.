%% Upsampling
%% Low-sampling-rate data to upsample
% In Hz
srate = 10;

% Just some numbers...
data  = [1 4 3 6 2 19];

% Other parameters
npnts = length(data);
time  = (0:npnts-1)/srate;

% Plot the original signal
figure(1), clf, hold on
plot(time,data,'ko-','markersize',15,'markerfacecolor','k','linew',3)

%% Option 1: upsample by a factor
upsampleFactor = 4;
newNpnts = npnts*upsampleFactor;

% New time vector after upsampling
newTime = (0:newNpnts-1)/(upsampleFactor*srate);

%% Option 2: upsample to desired frequency, then cut off points if necessary
% In Hz
newSrate = 37;

% Need to round in case it's not exact
newNpnts = round( npnts * (newSrate/srate) );

% New time vector after upsampling
newTime = (0:newNpnts-1) / newSrate;

%% Continue on to interpolation
% Cut out extra time points
newTime(newTime>time(end)) = [];

% The new sampling rate actually implemented
newSrateActual = 1/mean(diff(newTime))

% Define interpolation object
F = griddedInterpolant(time,data,'spline');

% Query that object at requested time points
updataI = F(newTime);

% Plot the upsampled signal
plot(newTime,updataI,'rs-','markersize',14,'markerfacecolor','r')
set(gca,'xlim',[0 max(time(end),newTime(end))])

%% Using MATLAB's resample function (signal processing toolbox)
% New sampling rate in Hz
newSrate = 42;

% Find p and q coefficients
[p,q] = rat( newSrate/srate);

% Use resample function (sigproc toolbox)
updataR = resample(data,p,q);
 
% New time vector
newTime = (0:length(updataR)-1)/newSrate;

% Cut out extra time points
updataR(newTime>time(end)) = [];
newTime(newTime>time(end)) = [];

% Plot it
plot(newTime,updataR,'b^-','markersize',14,'markerfacecolor','b')
legend({'Original';'Interpolated';'resample'})

%% end.