% Simulate EPR spectra of 31P and Si isotopes with varying k
clear; clc;

% Spin system definition
Sys.S = 1/2;
Sys.Nucs = '31P,28Si,29Si,30Si';
Sys.g = [1.9985, 1.9985, 1.9985];
Sys.AFrame = zeros(4, 3);

% Experiment setup
Exp.Field = 1325;  % mT
Exp.mwRange = [36.95 37.15];  % GHz

% Range of scaling factors for hyperfine
k_values = 0.8:0.02:1.2;
A0 = 117.5;  % MHz
peak_freq_values = zeros(size(k_values));
strain_percent = zeros(size(k_values));

% Publication-friendly color palette
pub_colors = [
    0.3010 0.7450 0.9330;  % blue
    0.8500 0.3250 0.0980;  % red
    0.4660 0.6740 0.1880;  % green
    0.4940 0.1840 0.5560;  % purple
    0.9290 0.6940 0.1250;  % orange
    0.3 0.3 0.3            % soft dark gray
];
n_colors = size(pub_colors, 1);

% --- Figure 1: EPR Spectra ---
figure;
set(gcf, 'Position', [100, 100, 1600, 500]);
hold on;
legend_entries = strings(1, length(k_values));

for i = 1:length(k_values)
    k = k_values(i);
    A_k = A0 * k;
    strain_percent(i) = (100/79.2) * (A_k - A0) / A0;

    Sys.A = [A_k A_k A_k;
             0 0 0;
             4 3.5 3.2;
             0 0 0];

    Opt = struct('Method', 'perturb');
    [freq, spec] = pepper(Sys, Exp, Opt);

    if isempty(freq) || isempty(spec)
        fprintf('Warning: No spectrum for k = %.2f\n', k);
        peak_freq_values(i) = NaN;
        continue;
    end

    % Assign a soft publication color
    color = pub_colors(mod(i-1, n_colors) + 1, :);

    % Plot spectrum
    plot(freq, spec, 'Color', color, 'LineWidth', 1);
    legend_entries(i) = sprintf('k = %.2f', k);

    % Rightmost peak detection
    [pks, locs] = findpeaks(spec, freq);
    if ~isempty(pks)
        peak_freq_values(i) = max(locs);
    else
        peak_freq_values(i) = NaN;
    end
end

xlabel('Microwave Frequency (GHz)');
ylabel('EPR Intensity (a.u.)');
title('Simulated EPR Spectra for Different Hyperfine Scaling Factors (k)');
legend(legend_entries, 'Location', 'eastoutside');
grid on;
box on;
hold off;

% === Post-Processing ===

valid_idx = ~isnan(peak_freq_values);
k_values = k_values(valid_idx);
peak_freq_values = peak_freq_values(valid_idx);
strain_percent = strain_percent(valid_idx);

% Calculate reference frequency for k = 1
k_ref = 1.00;
[~, ref_idx] = min(abs(k_values - k_ref));
reference_freq = peak_freq_values(ref_idx);  % in GHz
freq_shifts = (peak_freq_values - reference_freq) * 1e3; % in MHz

% === Frequency Shift Plot ===
figure;
hold on;
set(gcf, 'Position', [100, 100, 800, 600]);

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
title('Peak Transition Frequency vs. Hyperfine Strain');
grid on;
box on;
hold off;
