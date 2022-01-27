%% Welch's method
%%
% Load data
load EEGrestingState.mat
N = length(eegdata);

% Time vector
timevec = (0:N-1)/srate;

% Plot the data
figure(1), clf
plot(timevec,eegdata,'k')
xlabel('Time (seconds)'), ylabel('Voltage (\muV)')

%% One big FFT (not Welch's method)
% "Static" FFT over entire period, for comparison with Welch
eegpow = abs( fft(eegdata)/N ).^2;
hz = linspace(0,srate/2,floor(N/2)+1);

%% "Manual" Welch's method
% Window length in seconds*srate
winlength = 1*srate;

% Number of points of overlap
nOverlap = round(srate/2);

% Window onset times
winonsets = 1:winlength-nOverlap:N-winlength;

% Note: different-length signal needs a different-length Hz vector
hzW = linspace(0,srate/2,floor(winlength/2)+1);

% Hann window
hannw = .5 - cos(2*pi*linspace(0,1,winlength))./2;

% Initialize the power matrix (windows x frequencies)
eegpowW = zeros(1,length(hzW));

% Loop over frequencies
for wi=1:length(winonsets)
    % Get a chunk of data from this time window
    datachunk = eegdata(winonsets(wi):winonsets(wi)+winlength-1);
    
    % Apply Hann taper to data
    datachunk = datachunk .* hannw;
    
    % Compute its power
    tmppow = abs(fft(datachunk)/winlength).^2;
    
    % Enter into matrix
    eegpowW = eegpowW  + tmppow(1:length(hzW));
end

% Divide by N
eegpowW = eegpowW / length(winonsets);

%%% Plotting
figure(2), clf, hold on

plot(hz,eegpow(1:length(hz)),'k','linew',2)
plot(hzW,eegpowW/10,'r','linew',2)
set(gca,'xlim',[0 40])
xlabel('Frequency (Hz)')
legend({'"Static FFT';'Welch''s method'})

%% MATLAB pwelch
figure(3), clf

% Create Hann window
winsize = 2*srate; % 2-second window
hannw = .5 - cos(2*pi*linspace(0,1,winsize))./2;

% Number of FFT points (frequency resolution)
nfft = srate*100;

pwelch(eegdata,hannw,round(winsize/4),nfft,srate);
set(gca,'xlim',[0 40])

%% end.