% Exponential decay plot for echo signal
clear; clc; close all;

% Define delay times and corresponding echo signal intensities
x_1 = [0.01, 0.05, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1, 2, 3, 4, 5, ...
       6, 7, 8, 9, 10, 30, 50, 70, 90, 100, 200, 300, 400, 500, 600, 700, 800, ...
       900, 1000, 10000];

y_1 = [0.969698, 0.969598, 0.969819, 0.97166, 0.970397, 0.971946, 0.971159, ...
       0.969233, 0.970906, 0.970939, 0.969472, 0.970606, 0.967997, 0.967522, ...
       0.960002, 0.941049, 0.92909, 0.922532, 0.914016, 0.897964, 0.891881, ...
       0.772145, 0.678452, 0.596128, 0.5251591, 0.501592, 0.247032, 0.127887, ...
       0.0673516, 0.0350706, 0.0182448, 0.00958029, 0.00464203, 0.00207072, ...
       0.000984187, 2.85e-17];  % Last value kept small but > 0

% Create the figure
figure('Color', 'w'); % White background

% Plot with markers
plot(x_1, y_1, '-o', ...
    'LineWidth', 2, ...
    'MarkerSize', 6, ...
    'MarkerFaceColor', [0 0.4470 0.7410], ...
    'Color', [0 0.4470 0.7410]);

% Set axis scales
set(gca, 'YScale', 'log');  % Logarithmic y-axis

% Axis labels and title
xlabel('Delay time (\mus)', 'FontSize', 14);
ylabel('Echo signal intensity (a.u.)', 'FontSize', 14);
title('Echo Decay for Zero Strain', 'FontSize', 16);

% Grid, box, font settings
grid on;
box on;
set(gca, 'FontSize', 12, 'LineWidth', 1.2);

% Axis limits
xlim([min(x_1)*0.9, 1000]);
ylim([10e-4, 1]);  % Adjusted for log scale

