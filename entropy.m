%% Entropy
%% "Discrete" entropy
% Generate data
N = 1000;
numbers = ceil( 8*rand(N,1).^2 );

% Get counts and probabilities
u = unique(numbers);
probs = zeros(length(u),1);

for ui=1:length(u)
    probs(ui) = sum(numbers==u(ui)) / N;
end

% Compute entropy
entropee = -sum( probs.*log2(probs+eps) );

% Plot
figure(1), clf
bar(u,probs)
title([ 'Entropy = ' num2str(entropee) ])
ylabel('Probability')

%% Same procedure for spike times
% Generate spike times series
[spikets1,spikets2] = deal( zeros(N,1) );

% Nonrandom
spikets1( rand(N,1)>.9 ) = 1;

% Equal probability
spikets2( rand(N,1)>.5 ) = 1;

% Probabilities
% (note: this was incorrect in the video; the entropy of the entire time
% series requires the probability of each event type. And the theoretical
% entropy of a random binary sequence is 1.)
probs1 = [ sum(spikets2==0) sum(spikets1==1) ] / N;
probs2 = [ sum(spikets2==0) sum(spikets2==1) ] / N;

% Compute entropy
entropee1 = -sum( probs1.*log2(probs1+eps) );
entropee2 = -sum( probs2.*log2(probs2+eps) );

% Bar
figure(2), clf
subplot(211)
plot(1:N,smooth(spikets1,10), 1:N,smooth(spikets2,10))
legend({'TS1';'TS2'})

subplot(212)
bar([ entropee1 entropee2 ])
set(gca,'xlim',[0 3],'XTickLabel',{'TS1';'TS2'})
ylabel('Entropy')

%% Extra step for analog time series
% Load data time series
load v1_laminar.mat

% Compute event-related potential (averaging)
erp = mean(csd,3);

% Crucial parameter -- number of bins!
nbins = 50;

% Initialize
entro = zeros(size(erp,1),1);

% Compute entropy for each channel
for chani=1:size(erp,1)
    % Find boundaries
    edges = linspace(min(erp(chani,:)),max(erp(chani,:)),nbins);
    
    % Bin the data
    [nPerBin,bins] = histc(erp(chani,:),edges);
    
    % Convert to probability
    probs = nPerBin ./ sum(nPerBin);
    
    % Compute entropy
    entro(chani) = -sum( probs.*log2(probs+eps) );
end

% Plot
figure(3), clf
plot(entro,1:16,'ks-','linew',5,'markerfacecolor','k','markersize',15)
set(gca,'xlim',[min(entro)*.9 min(entro)*1.2])
xlabel('Entropy'), ylabel('Channel')

%% Loop over bin count
% Variable number of bins!
nbins = 4:50;

% Initialize
entro = zeros(size(erp,1),length(nbins));

for bini=1:length(nbins)
    % Compute entropy as above
    for chani=1:size(erp,1)
        edges = linspace(min(erp(chani,:)),max(erp(chani,:)),nbins(bini));
        [nPerBin,bins] = histc(erp(chani,:),edges);
        probs = nPerBin ./ sum(nPerBin);
        entro(chani,bini) = -sum( probs.*log2(probs+eps) );
    end
end

% Image of entropy by channel and bin count
figure(4), clLayf
contourf(nbins,1:16,entro,40,'linecolor','none')
xlabel('Number of bins'), ylabel('Channel')
title('Entropy as a function of bin count and channel')
colorbar

% Plot of the same data
figure(5), clf
plot(entro,1:16,'s-','linew',3,'markerfacecolor','w')
xlabel('Entropy'), ylabel('Channel')

%% end.