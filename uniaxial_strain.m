clear; clc; close all;

% === System Parameters ===
Sys.S = 1/2;
Sys.Nucs = '209Bi,28Si,29Si,30Si';
Sys.g = [1.9985, 1.9985, 1.9985];
Sys.lwpp = 0.16;

% === Experimental Setup ===
Exp.Field = 1000; % mT
Exp.mwRange = [10 45]; % GHz
Exp.nPoints = 10000;

% Poisson ratio for silicon
nu = 0.28;

% Stretch and contract axes
k_x_values = 0.8:0.02:1;
k_zy_values = 1 - nu * (k_x_values - 1);
peak_freq_values = zeros(size(k_x_values));

% Reference A (MHz)
A0 = 1475.4;

% Define peak search window in GHz
search_window = [10 45];

% Create figure
figure;
set(gcf, 'Position', [100, 100, 1600, 500]);
hold on;

% === Loop through strain values ===
for i = 1:length(k_x_values)
    k_x = k_x_values(i);
    k_zy = k_zy_values(i);

    % Hyperfine interaction
    A_x = A0 * k_x;
    A_zy = A0 * k_zy;

    Sys.A = [A_x A_zy A_zy;
             0   0    0;
             4 3.5 3.2;
             0   0    0];

    % Simulation
    Opt = struct('Method', 'perturb');
    [B, spec] = pepper(Sys, Exp, Opt);

    % Continue if no valid spectrum
    if isempty(B) || isempty(spec)
        peak_freq_values(i) = NaN;
        continue;
    end

    % Plot full spectrum
    plot(B, spec, 'DisplayName', sprintf('k_x=%.2f', k_x));

    % === Focused Peak Detection ===
    idx_window = B >= search_window(1) & B <= search_window(2);
    B_window = B(idx_window);
    spec_window = spec(idx_window);

    % Smoothing
    spec_window_smooth = smoothdata(spec_window, 'gaussian', 15);

    % Find peak
    [pks, locs] = findpeaks(spec_window_smooth, B_window, 'MinPeakProminence', 0.01);

    if ~isempty(pks)
        peak_freq_values(i) = max(locs);  % Rightmost peak in range
    else
        peak_freq_values(i) = NaN;
    end
end

% Finalize spectrum plot
xlabel('Microwave Frequency (GHz)');
ylabel('EPR Intensity (a.u.)');
xlim([20 37])
title('Simulated EPR Spectra under Varying Strain (k_x)');
grid on;
box on;
legend('show', 'Location', 'eastoutside');
hold off;

% === Post-Processing ===

valid_idx = ~isnan(peak_freq_values);
k_x_values = k_x_values(valid_idx);
peak_freq_values = peak_freq_values(valid_idx);
k_zy_values = k_zy_values(valid_idx);

strain_percent = (100/19.1) * (k_x_values - 1);
reference_freq = peak_freq_values(1);
freq_shifts = (peak_freq_values - reference_freq) * 1e3; % MHz

% === Frequency Shift Plot ===
figure;
hold on;
set(gcf, 'Position', [100, 100, 800, 600]);

% Use a single color for all data points (e.g., blue)
scatter_color = [1,0,0];  % red

scatter_color = [1, 0, 0];  % red
h_data_points = scatter(strain_percent, freq_shifts, 75, scatter_color, ...
    'Marker', 'x', 'LineWidth', 2, 'DisplayName', 'Transition Frequency');

% Fit linear model only if sufficient points
if length(strain_percent) > 2
    p_fit = polyfit(strain_percent, freq_shifts, 1);
    freq_fit = polyval(p_fit, strain_percent);

    h_fit = plot(strain_percent, freq_fit, '--k', 'LineWidth', 1.5, ...
        'DisplayName', sprintf('Linear Fit (slope = %.2f MHz/%%)', p_fit(1)));
    legend([h_data_points, h_fit], 'Location', 'best');
else
    legend(h_data_points, 'Location', 'best');
end

xlabel('Strain (%)');
ylabel('Peak Transition Frequency Shift (MHz)');
title('Peak Transition Frequency Shift vs. Uniaxial Strain');
grid on;
box on;

% Fix the legend to include only the data points and the linear fit
legend([h_data_points, h_fit], 'Location', 'best');

hold off;