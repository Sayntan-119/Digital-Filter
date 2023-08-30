close all;
clear;

filename = 'samplefile.wav';
[x, fs_orig] = audioread(filename);
x = x(:,1);                 % Take one channel only (if stereo)
            
%% Define filter specifications
fs = fs_orig;      % Sampling frequency in Hz
N = 300;         % Filter order
notch_freq = 5000; % Notch frequency in Hz
stop_atten = 40; % Stopband attenuation in dB

% Design filter coefficients using fir1 with a Hamming window
b = fir1(N, [notch_freq-200 notch_freq+200]/(fs/2), 'stop');

% Choose window length equal to the length of filter coefficients
win_len = N+1;

% Apply window function to filter coefficients
win = hamming(win_len)';
b_win = b .* win;

%% Plot filter frequency response
figure;
freqz(b);

%% Compute power spectral density
window = hann(1024); % Choose window function
noverlap = 512; % Choose overlap between windows
nfft = 2048; % Choose FFT size


%% Generate sinusoidal noise
f = 5000; % Frequency of sinusoidal noise (Hz)
A = 0.1; % Amplitude of sinusoidal noise
t = (0:length(x)-1)/fs_orig;
noise = A*sin(2*pi*f*t);

%% Add noise to signal
x = x + noise';
[Pxx, fx] = pwelch(x, window, noverlap, nfft, fs_orig);

%% Apply filter to sample file
y = filter(b, 1, x);

% Plot original and filtered signals
figure;
subplot(2,1,1);
semilogx(fx, 10*log10(Pxx));
xlabel('Frequency (Hz)');
ylabel('Power Spectral Density (dB/Hz)');
title('Power Spectral Density of Sample WAV File');


[Pyy, fy] = pwelch(y, window, noverlap, nfft, fs_orig);
subplot(2,1,2);
semilogx(fy, 10*log10(Pyy));
xlabel('Frequency (Hz)');
ylabel('Power Spectral Density (dB/Hz)');
title('Power Spectral Density of Filtered WAV File');
audio_gui(x,y,fs_orig);

function audio_gui(x,y,fs_orig)
% Create GUI
fig = uifigure('Name', 'Audio Player', 'Position', [100 100 400 200]);
file1_button = uibutton(fig, 'Position', [50 150 100 25], 'Text', 'Select File 1', 'ButtonPushedFcn', @select_file1);
file2_button = uibutton(fig, 'Position', [250 150 100 25], 'Text', 'Select File 2', 'ButtonPushedFcn', @select_file2);
play_button = uibutton(fig, 'Position', [100 100 50 50], 'Text', 'Play 2', 'ButtonPushedFcn', @play_audio);
pause_button = uibutton(fig, 'Position', [200 100 50 50], 'Text', 'Play 1', 'ButtonPushedFcn', @pause_audio);
status_label = uilabel(fig, 'Position', [150 50 100 25], 'Text', '');

% Initialize audio player objects
player1 = [];
player2 = [];

player1 = audioplayer(x, fs_orig);
            
            set(file1_button, 'Text', '1. Original with noise');
player2 = audioplayer(y, fs_orig);
            
            set(file2_button, 'Text', '2. Filtered audio');


% Callback function for play button
    function play_audio(~,~)
        if ~isempty(player1) && ~isempty(player2)
            play(player2);
            pause(player1);
            set(status_label, 'Text', 'Playing 2');
        end
    end

% Callback function for pause button
    function pause_audio(~,~)
        if ~isempty(player1) && ~isempty(player2)
            play(player1);
            pause(player2);
            set(status_label, 'Text', 'Playing 1');
        end
    end

end

