% Parameters common to all dopants
Exp.Range = [1300 1500]; % in mT
Exp.mwFreq = 36.9;       % GHz (X-band EPR)
Exp.Temperature = 4.5;   % Kelvin (use 298 K as default)
Exp.Harmonic = 0;        % 0 for first derivative (default)
Exp.nPoints = 10000;     % Number of data points for high resolution

nSi = 0:5; % Number of 29Si nuclei

% Marker styles and colors for each dopant (using ColorBrewer's "Set1" color scheme)
markerStyles = {'o', 's', 'd', '^'}; % Circle, Square, Diamond, Triangle
colors = {[0.0, 0.4470, 0.7410], ...  % Blue
          [0.8500, 0.3250, 0.0980], ... % Red
          [0.4660, 0.6740, 0.1880], ... % Green
          [0.9290, 0.6940, 0.1250]};    % Yellow

% Dopant data with hyperfine and quadrupole coupling
dopants = {
    struct('name', '31P', 'hyperfine', [117.53], 'quadrupole', 0),       % No quadrupole for 31P (I = 1/2)
    struct('name', '209Bi', 'hyperfine', [1475], 'quadrupole', 0.50),    % Quadrupole for 209Bi in MHz
    struct('name', '75As', 'hyperfine', [198.35], 'quadrupole', 0.15),   % Quadrupole for 75As in MHz
    struct('name', '121Sb', 'hyperfine', [186.8], 'quadrupole', 0.25)    % Quadrupole for 121Sb in MHz
};

peakAbsorptionResults = zeros(length(dopants), length(nSi));  % To store the peak absorption

% Loop over each dopant
for d = 1:length(dopants)
    dopant = dopants{d};
    fprintf('Simulating for %s \n', dopant.name);
    
    for n = nSi
        % Define spin system
        Sys = struct();
        Sys.S = 1/2;          % Electron spin
        Sys.g = 1.9985;       % g-value for the dopant nucleus (assumed isotropic)
        
        % System with dopant nucleus and 29Si nuclei
        if n == 0
            Sys.Nucs = dopant.name; % Only the dopant nucleus, e.g., '31P'
            Sys.A = dopant.hyperfine; % Dopant hyperfine coupling
        else
            Sys.Nucs = [sprintf('%s,', dopant.name), repmat('29Si,', 1, n)];
            Sys.Nucs = Sys.Nucs(1:end-1); % Remove trailing comma
            Sys.A = [dopant.hyperfine, repmat(4, 1, n)]; % Dopant and 29Si hyperfine coupling (default 4 MHz for 29Si)
        end
        
        % Add quadrupole coupling if applicable
        if dopant.quadrupole > 0
            Sys.Q = [dopant.quadrupole, repmat(0, 1, n)]; % Quadrupole coupling constant in MHz
        end
        
        % Simulate spectrum
        try
            [B, spc] = pepper(Sys, Exp);  % Simulate the EPR spectrum
            if isempty(B) || isempty(spc)
                error('pepper failed for n = %d', n);
            end
            
            % Extract the peak value of the spectrum (maximum value)
            peakAbsorption = max(spc);  % Take the maximum value of the spectrum
            
            % Store the peak absorption result
            peakAbsorptionResults(d, n+1) = peakAbsorption;
            
        catch ME
            fprintf('Error for %s with n=%d: %s\n', dopant.name, n, ME.message);
            peakAbsorptionResults(d, n+1) = NaN; % Handle the error gracefully if simulation fails
        end
    end
end

% Plot peak absorption vs number of 29Si nuclei for each dopant
figure;
hold on;

for d = 1:length(dopants)
    % Plot peak absorption with different markers
    plot(nSi, peakAbsorptionResults(d, :), markerStyles{d}, 'Color', colors{d}, 'DisplayName', dopants{d}.name, 'MarkerSize', 8, 'LineWidth', 1.5);
    
    % Fit a higher-order polynomial (degree 5 for a better fit)
    p = polyfit(nSi, peakAbsorptionResults(d, :), 5);   % 5th-degree polynomial fit
    yfit = polyval(p, nSi);  % Evaluate the fitted values
    
    % Plot the curve of best fit with a thinner line
    plot(nSi, yfit, 'Color', colors{d}, 'LineWidth', 2, 'LineStyle', '--', 'DisplayName', [dopants{d}.name, ' Fit']);
end

% Add labels, title, and legend
legend('Location', 'northeast', 'FontSize', 12, 'FontWeight', 'bold');
title('Peak Absorption vs Number of 29Si Nuclei', 'FontSize', 14, 'FontWeight', 'bold');
xlabel('Number of 29Si', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Peak Absorption (a.u.)', 'FontSize', 12, 'FontWeight', 'bold');
grid on;

% Enhance axis properties for publication
set(gca, 'FontSize', 12, 'FontWeight', 'bold', 'LineWidth', 1.5, 'Box', 'on');

% Save the figure in high resolution
saveas(gcf, 'Peak_Absorption_vs_29Si.png');
exportgraphics(gcf, 'Peak_Absorption_vs_29Si.tiff', 'Resolution', 300);
