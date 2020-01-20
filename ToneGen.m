% Generates tone and noise for binding-cue integration experiment
% Usage: [noise, tone_low, tone_im, tone_high, filename] = NoiseToneGen
function tone = ToneGen

% filename=[subject, 'Threshold.mat'];
% load(filename);

% % for pure tone
fs = 44100; % sampling rate
d = 100e-3; %length in seconds
f = 1000; % frequency
t = (0:floor(fs*d))'/fs; %length adjusted to sampling rate
x = sin(2*pi*f*t); %amplitude of tones

% setting up the properties of noise
% length=10; %10 sec
% d = floor(length*fs); % duration
r = 5e-3; % 5 ms ramp to avoid clicks
nr = floor(r*fs);

% x_noise = .98*(rand(d, 1)*2-1); % amplitude
% x_noise(1:nr) = linspace(0, 1, nr)'.* x(1:nr);
% x_noise(end-nr+1:end) = linspace(1, 0, nr)' .* x(end-nr+1:end);

% filtering noise amplitude so as to have the same characteristics as the tone
% [b, a] = butter(4, [f/2, f*2]*2/fs);

% y = filtfilt(b, a, x_noise);
% y(1:nr) = linspace(0, 1, nr)'.* y(1:nr); %ramping up to avoid click
% y(end-nr+1:end) = linspace(1, 0, nr)' .* y(end-nr+1:end);

% noise = audioplayer(.5*y, fs);


% ramps at the onset and offset to avoid clicks.
x(1:nr) = linspace(0, 1, nr)'.* x(1:nr);
x(end-nr+1:end) = linspace(1, 0, nr)' .* x(end-nr+1:end);

tone = audioplayer(x, fs);

% Level difference
% levelDiff = 20*log10(RMS(.5*y)/RMS(.1*x));


% pause(70e-3);
% stop(playernoise);

% % plotting the beep
% Z = abs(fft(z));
% f = (0:length(z)-1)/(length(z)-1)*fs;
% plot(f(f<fs/2), 20*log10(Z(f<fs/2)));
