% Clearing the workspace and closing figures
clear;
clc;
close all;

% Define the spin system for phosphorus-doped silicon
% Electron spin S = 1/2, two nuclei (31P and 29Si) each with I = 1/2
Sys.S = 1/2;
Sys.Nucs = '31P,29Si';
Sys.g = 1.9985; % g-factor for phosphorus in silicon
Sys.A = [117.5,4]; % Hyperfine coupling constants in MHz for 31P and 29Si
Exp.CrystalSymmetry = 227

% Define experimental parameters for the EPR spectrum
Exp.mwFreq = 36.9; % Microwave frequency in GHz (Q-band)
Exp.Range = [1315, 1325]; % Magnetic field range in mT
Exp.nPoints = 10000; % Number of points for high resolution

% Simulate the EPR spectrum using the pepper function
[B, Spec] = pepper(Sys, Exp);

% Plot the simulated absorption spectrum with two resonances
figure;
plot(B, Spec, 'LineWidth', 1.5, 'Color', [0, 0.4470, 0.7410]); % Enhanced line style and color
ylabel('Absorption (a.u.)', 'FontSize', 12, 'FontWeight', 'bold');
xlabel('Magnetic Field [mT]', 'FontSize', 12, 'FontWeight', 'bold');
title('Simulated EPR Spectrum', 'FontSize', 14, 'FontWeight', 'bold');
grid on;
set(gca, 'FontSize', 10, 'LineWidth', 1, 'Box', 'on'); % Enhance axes for better clarity
xlim([Exp.Range(1) Exp.Range(2)]);
ylim auto;
% Save the plot as a high-resolution image for publications
saveas(gcf, 'EPR_Spectrum.png');
exportgraphics(gcf, 'EPR_Spectrum.tiff', 'Resolution', 300);

% Define magnetic field range for energy level plot
magfield = linspace(0, 10, 100); % Magnetic field range for the levels plot

% Plot the energy levels using the levelsplot function
figure;
levelsplot(Sys, 'z', magfield, Exp.mwFreq);
title('Energy Levels of 31P and 29Si in Silicon', 'FontSize', 14, 'FontWeight', 'bold');
ylabel('Energy [GHz]', 'FontSize', 12, 'FontWeight', 'bold');
xlabel('Magnetic Field [mT]', 'FontSize', 12, 'FontWeight', 'bold');
grid on;
set(gca, 'FontSize', 10, 'LineWidth', 1, 'Box', 'on'); % Enhance axes for better clarity
xlim([0 10]);
% Save the plot as a high-resolution image for publications
saveas(gcf, 'Energy_Levels.png');
exportgraphics(gcf, 'Energy_Levels.tiff', 'Resolution', 300);