% Clear workspace and command window
clear; clc; close all;

%% Define Spin System
Sys.S = 1/2;
Sys.Nucs = '31P,29Si,28Si';
Sys.g = 1.9985;
Sys.T1 = 700000;  % µs
Sys.T2 = 300;     % µs

%% Experimental Parameters
Exp.Field = 1070;          % mT
Exp.mwFreq = 30;           % GHz
Exp.DetFreq = Exp.mwFreq;
Exp.Temperature = 2;       % K

%% Define Pulses
EchoPulse90 = struct('Type', 'rectangular', 'tp', 0.00080, 'Flip', pi/2);
EchoPulse180 = struct('Type', 'rectangular', 'tp', 0.0006, 'Flip', pi);

tau = 4000; % ns
Exp.Sequence = {EchoPulse90, tau, EchoPulse180, tau};

if ~iscell(Exp.Sequence)
    error('Exp.Sequence must be a cell array.');
end

%% Detection Window
Exp.DetWindow = [0, 3];  % µs

%% Simulation Options
Opt.SimFreq = 15;
Opt.Relaxation = true;

%% Hyperfine Scaling Factors
k_values = [1, 1.5, 2];
colors = {[0 0.4470 0.7410], [0.8500 0.3250 0.0980], [0.9290 0.6940 0.1250]};
T2_fit = nan(1, length(k_values));

% Create large figure for subplots
figure('Units', 'normalized', 'Position', [0.1, 0.1, 0.5, 0.75]);

%% Loop Over k Values
for i = 1:length(k_values)
    k = k_values(i);
    
    % Scale Hyperfine Couplings
    Sys.A = [max(1, k * 117.5), max(1, k * 4), 0];

    disp('Running spidyan with parameters:');
    disp(Sys); disp(Exp); disp(Opt);

    try
        [time, signal] = spidyan(Sys, Exp, Opt);
        if isempty(time) || isempty(signal)
            error('spidyan returned empty data.');
        end
    catch ME
        warning('spidyan failed for k=%.1f: %s', k, ME.message);
        continue;
    end

    y = real(signal);
    sortedY = sort(y, 'descend');
    avgTop40 = mean(sortedY(1:8000));
    fprintf('Average of top 8000 values: %.4f\n', avgTop40);

    % Plot in subplot
    subplot(length(k_values), 1, i);
    plot(time, signal * 1e8, 'Color', colors{i}, 'LineWidth', 2);
    title(sprintf('EPR Signal for k = %.1f', k));
    xlabel('Time (µs)');
    ylabel('Signal (a.u.)');
    grid on;
    xlim([8000, 8000.7]);

    % T2 Fitting
    fitFunc = @(p, t) p(1) * exp(-t / p(2));
    p0 = [max(y), Sys.T2];
    options = optimset('Display','off');

    try
        p_opt = lsqcurvefit(fitFunc, p0, time, y, [], [], options);
        T2_fit(i) = p_opt(2);
    catch ME
        warning('Curve fitting failed for k=%.1f: %s', k, ME.message);
    end
end

%% Display Fitted T2 Values
disp('--- T2 Fit Results ---');
for i = 1:length(k_values)
    if ~isnan(T2_fit(i))
        fprintf('Estimated T2 for k=%.1f: %.2f µs\n', k_values(i), T2_fit(i));
    else
        fprintf('T2 estimation failed for k=%.1f.\n', k_values(i));
    end
end
