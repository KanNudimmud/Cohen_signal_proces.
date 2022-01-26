%% Resampling, interpolating, extrapolating
% Strategies for multirate signals
%% Create multichannel signal with multiple sampling rates
% Initialize signals, time vectors, and sampling rates
% note: hard-coded to three signals
[fs,timez,signals] = deal( cell(3,1) );

% Sampling rates in Hz
fs{1} = 10;
fs{2} = 40;
fs{3} = 83;

% Create signals
for si=1:3
    % Create signal
    signals{si} = cumsum( sign(randn(fs{si},1)) );
    
    % Create time vector
    timez{si} = (0:fs{si}-1)/fs{si};
end

% Plot all signals
figure(1), clf, hold on

color = 'kbr';
shape = 'os^';
for si=1:3
    plot(timez{si},signals{si},[ color(si) shape(si) '-' ],'linew',1,'markerfacecolor','w','markersize',6)
end
axlims = axis;
xlabel('Time (s)')

%% Upsample to fastest frequency
% In Hz
[newSrate,whichIsFastest] = max(cell2mat(fs));

% Need to round in case it's not exact
newNpnts = round( length(signals{whichIsFastest}) * (newSrate/fs{whichIsFastest}) );

% New time vector after upsampling
newTime = (0:newNpnts-1) / newSrate;

%% Continue on to interpolation
% Initialize (as matrix!)
newsignals = zeros(length(fs),length(newTime));

for si=1:length(fs)
    % Define interpolation object
    F = griddedInterpolant(timez{si},signals{si},'spline');
    
    % Query that object at requested time points
    newsignals(si,:) = F(newTime);
end

%% Plot for comparison
% Plot all signals
figure(2), clf, hold on

for si=1:3
    plot(newTime,newsignals(si,:),[ color(si) shape(si) '-' ],'linew',1,'markerfacecolor','w','markersize',6)
end

% Set axis limits to match figure 1
axis(axlims)

for si=1:3
    plot(newTime,newsignals(si,:),[ color(si) shape(si) '-' ],'linew',1,'markerfacecolor','w','markersize',6)
end

% Set axis limits to match figure 1
axis(axlims)

%% end.