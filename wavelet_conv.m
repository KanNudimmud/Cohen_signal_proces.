%% Feature detection
% Wavelet convolution for feature extraction
%% Simulate data 
% Total number of time points
N = 10000;

% Create event (derivative of Gaussian)
k = 100; % duration of event in time points
event = diff(exp( -linspace(-2,2,k+1).^2 ));
event = event./max(event); % normalize to max=1

% Event onset times
Nevents = 30;
onsettimes = randperm(N/10-k);
onsettimes = onsettimes(1:Nevents)*10;

% Put event into data
data = zeros(1,N);
for ei=1:Nevents
    data(onsettimes(ei):onsettimes(ei)+k-1) = event;
end

% Add noise
data = data + 3*randn(size(data));

% Plot data
figure(1), clf
subplot(211), hold on
plot(data)
plot(onsettimes,data(onsettimes),'ro')

%% Convolve with event (as template)
% Convolution
convres = conv(data,event,'same');

% Plot the convolution result and ground-truth event onsets
subplot(212), hold on
plot(convres)
plot(onsettimes,convres(onsettimes),'o')

%% Find a threshold
% Histogram of all data values
figure(2), clf
hist(convres,N/20)

% Pick a threshold based on histogram and visual inspection
thresh = -35;

% Plot the threshold
figure(1)
subplot(212)
plot(get(gca,'xlim'),[1 1]*thresh,'k--')

% Find local minima
thresh_ts = convres;
thresh_ts(thresh_ts>thresh) = 0;

% Let's see what it looks like...
figure(2), clf
plot(thresh_ts,'s-')

% Find local minima
localmin = find(diff(sign(diff( thresh_ts )))>0)+1;

% Plot local minima on top of the plot
figure(1)
% Original data
subplot(211), plot(localmin,data(localmin),'ks','markerfacecolor','m')

% Convolution result
subplot(212), plot(localmin,convres(localmin),'ks','markerfacecolor','m')

%% Extract time series for windowing
% Remove local minima that are too close to the edges
localmin(localmin<round(k/2)) = [];
localmin(localmin>N-round(k/2)) = [];

% Initialize data matrix
datamatrix = zeros(length(localmin),k);

% Enter data snippets into matrix
for ei=1:length(localmin)
    datamatrix(ei,:) = data(localmin(ei)-round(k/2):localmin(ei)+round(k/2)-1);
end

% Show all snippets
figure(3), clf
subplot(4,1,1:3)
imagesc(datamatrix)
xlabel('Time'), ylabel('Event number')
title('All events')

% Snippet average against ground truth
subplot(414)
plot(1:k,mean(datamatrix), 1:k,event,'linew',3)
xlabel('Time'), ylabel('Amplitude')
legend({'Averaged';'Ground-truth'})
title('Average events')

%% end.