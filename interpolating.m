%% Interpolating
%% Low-sampling-rate data to upsample
% In Hz
srate = 10;

% Just some numbers...
data  = [1 4 3 6 2 19];

% Other parameters
npnts = length(data);
time  = (0:npnts-1)/srate;

% Plot the original data
figure(1), clf
subplot(221)
plot(time,data,'go','markersize',15,'markerfacecolor','m')

% Amplitude spectrum
figure(2), clf
plot(linspace(0,1,npnts),abs(fft(data/npnts)),'go-','markerfacecolor','m','linew',4,'markersize',8)
xlabel('Frequency (a.u.)')

%% Interpolation
% New time vector for interpolation
N = 47;
newTime = linspace(time(1),time(end),N);

% Different interpolation options
interpOptions = {'linear';'next';'nearest';'spline'};
interpColors  = 'brkm';
interpShapes  = 'sd^p';

for methodi=1:length(interpOptions)
    
    %% Using griddedInterpolant
    % Define interpolation object
    F = griddedInterpolant(time,data,interpOptions{methodi});
    
    % Query that object at requested time points
    newdata = F(newTime);
    
    %% Using interp1 (same as above)
    newdata = interp1(time,data,newTime,interpOptions{methodi});
    
    %% Plots
    figure(1)
    subplot(2,2,methodi), hold on
    plot(newTime,newdata,'ks-','markersize',10,'markerfacecolor','w')
    plot(time,data,'go','markersize',15,'markerfacecolor','m')
    
    % Make the axis a bit nicer
    set(gca,'xlim',[0 max(time(end),newTime(end))])
    title([ '''' interpOptions{methodi} '''' ]) % 4 single quotes here to get a single quote of text!
    axis square
    
    figure(2), hold on
    plot(linspace(0,1,N),abs(fft(newdata/N)),[ interpColors(methodi) interpShapes(methodi) '-' ],'markerfacecolor',interpColors(methodi))
    
end
 
% Adjust spectral plot
figure(2)
set(gca,'xlim',[0 .5])
legend(cat(1,'original',interpOptions))

%% end.