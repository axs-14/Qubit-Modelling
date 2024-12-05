% Clearing the workspace and closing figures
clear;
clc;
close all;

% Define the experiment parameters
Exp.mwFreq = 0.01; % Microwave frequency in GHz (Q-band)
Exp.Range = [0, 5]; % Magnetic field range in mT
Exp.nPoints = 2048
Exp.CrystalSymmetry = 227

% Define the magnetic field range for energy level plots
magfield = linspace(Exp.Range(1), Exp.Range(2), 100); % 100 points in the range

% Define spin systems with quadrupole coupling added
% Phosphorus in Silicon
Sys_P.S = 1/2;
Sys_P.Nucs = '31P, 29Si';
Sys_P.g = 1.9985; % g-factor
Sys_P.A = [117.53, 4]; % Hyperfine coupling in MHz
Sys_P.Q = [0, 0]; % No quadrupole coupling for 31P and 29Si

% Antimony in Silicon
Sys_Sb.S = 1/2;
Sys_Sb.Nucs = '121Sb, 29Si';
Sys_Sb.g = 1.9985;
Sys_Sb.A = [186.8, 4];
Sys_Sb.Q = [0.72, 0]; % Quadrupole coupling for 121Sb in MHz

% Bismuth in Silicon
Sys_Bi.S = 1/2;
Sys_Bi.Nucs = '209Bi, 29Si';
Sys_Bi.g = 1.9985;
Sys_Bi.A = [1475.4, 4];
Sys_Bi.Q = [3.45, 0]; % Quadrupole coupling for 209Bi in MHz

% Arsenic in Silicon
Sys_As.S = 1/2;
Sys_As.Nucs = '75As, 29Si';
Sys_As.g = 1.9985;
Sys_As.A = [198.35, 4];
Sys_As.Q = [0.6, 0]; % Quadrupole coupling for 75As in MHz

% Simulate the EPR spectra for each dopant
[B_P, Spec_P] = pepper(Sys_P, Exp);
[B_Sb, Spec_Sb] = pepper(Sys_Sb, Exp);
[B_Bi, Spec_Bi] = pepper(Sys_Bi, Exp);
[B_As, Spec_As] = pepper(Sys_As, Exp);

% Compute derivative spectra
dSpec_P = diff(Spec_P) ./ diff(B_P);
dSpec_Sb = diff(Spec_Sb) ./ diff(B_Sb);
dSpec_Bi = diff(Spec_Bi) ./ diff(B_Bi);
dSpec_As = diff(Spec_As) ./ diff(B_As);

% Magnetic field values for derivative spectra
B_P_deriv = B_P(1:end-1);
B_Sb_deriv = B_Sb(1:end-1);
B_Bi_deriv = B_Bi(1:end-1);
B_As_deriv = B_As(1:end-1);

% Plotting EPR Absorption Spectra for all dopants
figure('Position', [100, 100, 1600, 400]);
hold on;
plot(B_P, Spec_P, 'LineWidth', 1.5, 'DisplayName', 'Phosphorus');
plot(B_Sb, Spec_Sb, 'LineWidth', 1.5, 'DisplayName', 'Antimony');
plot(B_Bi, Spec_Bi, 'LineWidth', 1.5, 'DisplayName', 'Bismuth');
plot(B_As, Spec_As, 'LineWidth', 1.5, 'DisplayName', 'Arsenic');
ylabel('Absorption', 'FontSize', 14, 'FontWeight', 'bold');
xlabel('Magnetic field [mT]', 'FontSize', 14, 'FontWeight', 'bold');
title('Absorption Spectra for Different Dopants in Silicon', 'FontSize', 16, 'FontWeight', 'bold');
legend;
grid on;
hold off;
saveas(gcf, 'EPR_Absorption_Spectra.png');
exportgraphics(gcf, 'EPR_Absorption_Spectra.tiff', 'Resolution', 300);

% Plotting EPR Derivative Spectra for all dopants
figure('Position', [100, 100, 1600, 400]);
hold on;
plot(B_P_deriv, dSpec_P, 'LineWidth', 1.5, 'DisplayName', 'Phosphorus');
plot(B_Sb_deriv, dSpec_Sb, 'LineWidth', 1.5, 'DisplayName', 'Antimony');
plot(B_Bi_deriv, dSpec_Bi, 'LineWidth', 1.5, 'DisplayName', 'Bismuth');
plot(B_As_deriv, dSpec_As, 'LineWidth', 1.5, 'DisplayName', 'Arsenic');
ylabel('Derivative Absorption', 'FontSize', 14, 'FontWeight', 'bold');
xlabel('Magnetic field [mT]', 'FontSize', 14, 'FontWeight', 'bold');
title('Derivative Spectra for Different Dopants in Silicon', 'FontSize', 16, 'FontWeight', 'bold');
legend;
grid on;
hold off;
saveas(gcf, 'EPR_Derivative_Spectra.png');
exportgraphics(gcf, 'EPR_Derivative_Spectra.tiff', 'Resolution', 300);

% Plot the energy levels for Phosphorus in Silicon
figure;
levelsplot(Sys_P, 'z', magfield, Exp.mwFreq);
title('Energy Eigenvalues of the Spin Hamiltonian for Phosphorus in Silicon');
ylabel('Energy [MHz]');
xlabel('Magnetic field [mT]');
grid on;
saveas(gcf, 'Phosphorus_Energy_Levels.png');
exportgraphics(gcf, 'Phosphorus_Energy_Levels.tiff', 'Resolution', 300);

% Repeat for Antimony, Bismuth, and Arsenic, with split energy axes
dopants = {'Antimony', 'Bismuth', 'Arsenic'};
systems = {Sys_Sb, Sys_Bi, Sys_As};
ylims_lower = {[0.15, 0.32], [3.2, 3.4], [0.05, 0.25]};
ylims_higher = {[-.4, -0.25], [-4.15, -3.95], [-0.3, -0.22]};

for i = 1:length(dopants)
    figure('Position', [100, 100, 800, 600]);
    % Lower energy levels
    subplot(2, 1, 1);
    levelsplot(systems{i}, 'z', magfield, Exp.mwFreq);
    title(['Energy Eigenvalues of the Spin Hamiltonian for ', dopants{i}, ' in Silicon']);
    ylabel('Energy [GHz]');
    xlabel('Magnetic field [mT]');
    ylim(ylims_lower{i});
    grid on;

    % Higher energy levels
    subplot(2, 1, 2);
    levelsplot(systems{i}, 'z', magfield, Exp.mwFreq);
    ylabel('Energy [GHz]');
    xlabel('Magnetic field [mT]');
    ylim(ylims_higher{i});
    grid on;

    % Save the figure
    saveas(gcf, [dopants{i}, '_Energy_Levels.png']);
    exportgraphics(gcf, [dopants{i}, '_Energy_Levels.tiff'], 'Resolution', 300);
end
