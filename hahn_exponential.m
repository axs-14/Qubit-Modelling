%exponential decay plot
clear; clc; close all;
% Define x and y values
x_1 = [0.01, 0.05, 0.1,0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 30, 50, 70, 90, 100,200, 300, 400, 500, 600, 700, 800, 900 1000, 10000];
y_1 = [0.969698, 0.969598, 0.969819, 0.97166, 0.970397, 0.971946, 0.971159, 0.969233, 0.970906, 0.970939, 0.969472, 0.970606, 0.967997, 0.967522, 0.960002, 0.941049, 0.92909, 0.922532, 0.914016, 0.897964, 0.891881, 0.772145, 0.678452, 0.596128, 0.5251591, 0.501592, 0.247032, 0.127887, 0.0673516, 0.0350706, 0.0182448, 0.00958029, 0.00464203, 0.00207072, 0.000984187, 0.0000000000000000285];
% Create the plot for k=1
figure('Color', 'w'); % White background

% Plot with cleaner markers and modern color
plot(x_1, y_1, '-o', ...
    'LineWidth', 2, ...
    'MarkerSize', 6, ...
    'MarkerFaceColor', [0 0.4470 0.7410], ...
    'Color', [0 0.4470 0.7410]);

% Set logarithmic scale for x-axis
set(gca, 'XScale', 'log');

% Improve axis labels with LaTeX interpreter and larger font
xlabel('Delay time (\mus)', 'FontSize', 14);
ylabel('Echo signal intensity (a.u.)', 'FontSize', 14);
title('Echo Decay for Zero Strain', 'FontSize', 16);

% Customize grid and axis appearance
grid on;
box on;
set(gca, 'FontSize', 12, 'LineWidth', 1.2);

% Optionally set tighter axis limits
xlim([min(x_1)*0.9, max(x_1)*1.1]);
ylim([min(y_1)*0.9, max(y_1)*1.1]);

% Optional: add title
% title('Spin Echo Decay for k = 1', 'Interpreter', 'latex', 'FontSize', 14);
