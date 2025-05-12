% ===============================
% EPR Simulation using EasySpin
% Time-domain + Frequency-domain
% With FFT Peak Detection (Memory Safe)
% ===============================
clear; clc; close all;
% === Spin System ===
Sys.S = 1/2;
Sys.Nucs = '31P,29Si,28Si';
Sys.g = 1.9985;
Sys.T1 = 700000; % µs
Sys.T2 = 300; % µs
% === Experimental Parameters ===
Exp.Field = 1070; % mT
Exp.mwFreq = 30; % GHz
Exp.DetOperator = '+1';
Exp.DetFreq = Exp.mwFreq; % GHz
Exp.Temperature = 2; % K
% === Pulses ===
EchoPulse90.Type = 'rectangular';
EchoPulse90.tp = 0.0008;
EchoPulse90.Flip = pi/2;
EchoPulse180.Type = 'rectangular';
EchoPulse180.tp = 0.0006;
EchoPulse180.Flip = pi;
tau = 4000; % Delay time (ns or µs based on EasySpin version)
Exp.Sequence = {EchoPulse90, tau, EchoPulse180, tau};
Exp.DetWindow = [0, 3]; % µs
% === Simulation Options ===
Opt.SimFreq = 15; % MHz
% === Values of k to simulate ===
k_values = [2];
colors = {'b'};
% === Loop over k values ===
for i = 1:length(k_values)
k = k_values(i);
Sys.A = [max(1, k * 117.5), max(1, k * 4), 0];
fprintf('\n>>> Simulating for k = %.2f\n', k);
disp(Sys); disp(Exp); disp(Opt);
% Clear memory of previous variables
clear time signal signal_ds signal_windowed;
try
[time, signal] = spidyan(Sys, Exp, Opt);
if isempty(time) || isempty(signal)
error('spidyan returned empty output.');
end
catch ME
warning('spidyan failed: %s', ME.message);
continue;
end
% === Plot Time-Domain Signal ===
figure(1); hold on;
plot(time, real(signal) * 1e8, 'Color', colors{i}, 'LineWidth', 2);
xlabel('Time (\mus)');
ylabel('EPR Signal Intensity (a.u.)');
title('Time-Domain EPR Signal');
legend(sprintf('k = %.2f', k), 'Location', 'best');
grid on;
xlim([8000, 8000.7]);
% === FFT + Peak Detection ===
% Step 1: Report signal size
fprintf('Signal length: %d samples\n', length(signal));
% Step 2: Downsample aggressively
maxFFTPoints = 2^13; % Safe cap = 8192
idx = round(linspace(1, length(signal), maxFFTPoints));
time_ds = time(idx);
signal_ds = real(signal(idx)); % Use real part only
dt = time_ds(2) - time_ds(1);
Fs = 1 / dt; % MHz
N = length(signal_ds);
% Step 3: Apply Hamming window
window = hamming(N).';
signal_windowed = signal_ds .* window;
% Step 4: Compute FFT
S_fft = abs(fft(signal_windowed));
f = (0:N-1)*(Fs/N);
halfN = floor(N/2);
f = f(1:halfN);
S_fft = S_fft(1:halfN);
% Step 5: Detect peaks
threshold = max(S_fft) * 0.05; % 5% cutoff
[peaks, locs] = findpeaks(S_fft, f, 'MinPeakProminence', threshold);
% Step 6: Plot FFT
figure('Units', 'inches', 'Position', [1, 1, 12, 4]);
semilogy(f, S_fft, 'LineWidth', 1.5);
xlabel('Frequency (MHz)');
ylabel('FFT Amplitude Log Scale (a.u.)');
%title(sprintf('ESEEM Frequency Spectrum (k = %.2f)', k));
grid on;
xlim([0 1357]); % Adjust as needed
% Step 7: Annotate peaks
hold on;
%for j = 1:length(locs)
%text(locs(j), peaks(j), sprintf('%.1f MHz', locs(j)), ...
%'VerticalAlignment', 'bottom', ...
%'HorizontalAlignment', 'right', ...
%'FontSize', 8, 'Color', 'red');
%end
% Step 8: Print peak frequencies% ===============================
% EPR Simulation using EasySpin
% Frequency-domain only (FFT)
% Cleaned-up version with k = 1, 1.5, 2
% ===============================
clear; clc; close all;

% === Spin System ===
Sys.S = 1/2;
Sys.Nucs = '31P,29Si,28Si';
Sys.g = 1.9985;
Sys.T1 = 700000; % µs
Sys.T2 = 300; % µs

% === Experimental Parameters ===
Exp.Field = 1070;       % mT
Exp.mwFreq = 30;        % GHz
Exp.DetOperator = '+1';
Exp.DetFreq = Exp.mwFreq;
Exp.Temperature = 2;    % K

% === Pulses ===
EchoPulse90.Type = 'rectangular';
EchoPulse90.tp = 0.0008;
EchoPulse90.Flip = pi/2;

EchoPulse180.Type = 'rectangular';
EchoPulse180.tp = 0.0006;
EchoPulse180.Flip = pi;

tau = 4000;  % ns or µs (depending on EasySpin version)
Exp.Sequence = {EchoPulse90, tau, EchoPulse180, tau};
Exp.DetWindow = [0, 3]; % µs

% === Simulation Options ===
Opt.SimFreq = 15; % MHz

% === Values of k to simulate ===
k_values = [1, 1.5, 2];
colors = {'r', 'g', 'b'};

figure('Units', 'inches', 'Position', [1, 1, 12, 8]);

for i = 1:length(k_values)
    k = k_values(i);
    Sys.A = [max(1, k * 117.5), max(1, k * 4), 0]; % MHz
    
    fprintf('\n>>> Simulating for k = %.2f\n', k);
    
    % Clear previous signal data
    clear time signal signal_ds signal_windowed;

    try
        [time, signal] = spidyan(Sys, Exp, Opt);
        if isempty(time) || isempty(signal)
            error('spidyan returned empty output.');
        end
    catch ME
        warning('spidyan failed: %s', ME.message);
        continue;
    end

    % === FFT Processing ===
    fprintf('Signal length: %d samples\n', length(signal));
    maxFFTPoints = 2^13; % 8192 points
    idx = round(linspace(1, length(signal), maxFFTPoints));
    time_ds = time(idx);
    signal_ds = real(signal(idx));
    
    dt = time_ds(2) - time_ds(1);
    Fs = 1 / dt; % Sampling frequency in MHz
    N = length(signal_ds);
    
    % Hamming window
    window = hamming(N).';
    signal_windowed = signal_ds .* window;
    
    % FFT
    S_fft = abs(fft(signal_windowed));
    f = (0:N-1) * (Fs/N);
    halfN = floor(N/2);
    f = f(1:halfN);
    S_fft = S_fft(1:halfN);
    
    % Peak Detection
    threshold = max(S_fft) * 0.05;
    [peaks, locs] = findpeaks(S_fft, f, 'MinPeakProminence', threshold);
    
    % === Plot ===
    subplot(3, 1, i);
    semilogy(f, S_fft, 'Color', colors{i}, 'LineWidth', 1.5);
    xlabel('Frequency (MHz)');
    ylabel('FFT Amplitude (a.u.)');
    title(sprintf('FFT Spectrum for k = %.2f', k));
    grid on;
    xlim([0 1357]);

    % Annotate peaks (optional)
    % hold on;
    % for j = 1:length(locs)
    %     text(locs(j), peaks(j), sprintf('%.1f MHz', locs(j)), ...
    %         'VerticalAlignment', 'bottom', ...
    %         'HorizontalAlignment', 'right', ...
    %         'FontSize', 8, 'Color', 'red');
    % end
    
    % Display peak frequencies
    fprintf('--- FFT Peaks (k = %.2f) ---\n', k);
    disp(locs);
end

fprintf('\n--- FFT Peaks (k = %.2f) ---\n', k);
disp(locs);
end