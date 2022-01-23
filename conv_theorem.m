%% The convolution theorem
%% Generate signal and kernel
% Signal
signal = zeros(1,20);
signal(8:15) = 1;

% Convolution kernel
kernel = [1 .8 .6 .4 .2];

% Convolution sizes
nSign = length(signal);
nKern = length(kernel);
nConv = nSign + nKern - 1;

%% Time-domain convolution
half_kern = floor(nKern/2);

% Flipped version of kernel
kflip = kernel(end:-1:1);

% Zero-padded data for convolution
dat4conv = [ zeros(1,half_kern) signal zeros(1,half_kern) ];

% Initialize convolution output
conv_res = zeros(1,nConv);

% Run convolution
for ti=half_kern+1:nConv-half_kern
    % Get a chunk of data
    tempdata = dat4conv(ti-half_kern:ti+half_kern);
    
    % Compute dot product (don't forget to flip the kernel backwards!)
    conv_res(ti) = sum( tempdata.*kflip );
end

% Cut off edges
conv_res = conv_res(half_kern+1:end-half_kern);

%% Convolution implemented in the frequency domain
% Spectra of signal and kernel
signalX = fft(signal,nConv);
kernelX = fft(kernel,nConv);

% Element-wise multiply
sigXkern = signalX .* kernelX;

% Inverse FFT to get back to the time domain
conv_resFFT = ifft( sigXkern );

% Cut off edges
conv_resFFT = conv_resFFT(half_kern+1:end-half_kern);

%% Plot for comparison
figure(1), clf, hold on
plot(conv_res,'o-','linew',2,'markerface','g','markersize',9)
plot(conv_resFFT,'o-','linew',2,'markerface','r','markersize',3)

legend({'Time domain';'Freq domain'})

%% end.