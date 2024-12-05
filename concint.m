% Parameters common to all dopants
Exp.Range = [1300 1500]; % in mT
Exp.mwFreq = 36.9;       % GHz (X-band EPR)
Exp.Temperature = 4.5;   % Kelvin (use 298 K as default)
Exp.Harmonic = 0;
Exp.nPoints = 10000;

nSi = 0:5; % Number of 29Si nuclei

% Marker styles and colors for each dopant
markerStyles = {'o', 's', 'd', '^'}; % Circle, Square, Diamond, Triangle
colors = {'b', 'r', 'g', 'm'};       % Blue, Red, Green, Magenta

% Dopant data with hyperfine and quadrupole coupling
dopants = {
    struct('name', '31P', 'hyperfine', [117.53], 'quadrupole', 0),       % No quadrupole for 31P (I = 1/2)
    struct('name', '209Bi', 'hyperfine', [1475], 'quadrupole', 0.50),    % Quadrupole for 209Bi in MHz
    struct('name', '75As', 'hyperfine', [198.35], 'quadrupole', 0.15),   % Quadrupole for 75As in MHz
    struct('name', '121Sb', 'hyperfine', [186.8], 'quadrupole', 0.25)    % Quadrupole for 121Sb in MHz
};

% Initialize arrays to store peak areas for each dopant and nSi
peakAreas = zeros(length(dopants), length(nSi));  % Array to store peak areas

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
            
            % Manual peak detection (local maxima)
            peakThreshold = 0.05;  % Minimum peak height (adjust as needed)
            peakLocations = [];
            peakValues = [];
            
            % Iterate over the spectrum to find peaks
            for i = 2:length(spc)-1  % Start from 2 and go until the second last point
                if spc(i-1) < spc(i) && spc(i) > spc(i+1) && spc(i) > peakThreshold
                    % Check if current point is higher than its neighbors and above threshold
                    peakLocations = [peakLocations, i];  % Store index of peak
                    peakValues = [peakValues, spc(i)];   % Store the peak value
                end
            end
            
            % Print detected peaks for each dopant and nSi
            fprintf('Detected peaks for %s with n = %d Si nuclei:\n', dopant.name, n);
            for p = 1:length(peakLocations)
                fprintf('Peak at mT = %.4f, Value = %.4f\n', B(peakLocations(p)), peakValues(p));
            end
            
            % Numerically integrate the entire spectrum using the trapezoidal rule
            totalArea = trapz(B, spc);  % Compute the area under the curve using trapezoidal integration
            
            % Print the total area for the current dopant and nSi
            fprintf('Total Area for %s with n = %d Si nuclei: %.2f\n\n', dopant.name, n, totalArea);
            
            % Store the total area under the spectrum
            peakAreas(d, n+1) = totalArea;
            
        catch ME
            fprintf('Error for %s with n=%d: %s\n', dopant.name, n, ME.message);
            peakAreas(d, n+1) = NaN; % Handle the error gracefully if simulation fails
        end
    end
end

% Plot total area under the spectrum vs number of 29Si nuclei for each dopant
figure;
hold on;

for d = 1:length(dopants)
    % Plot the total area with different markers
    h = plot(nSi, peakAreas(d, :), markerStyles{d}, 'Color', colors{d}, 'DisplayName', dopants{d}.name, 'MarkerSize', 8);
    
    % Fit a higher-order polynomial (degree 5 for a better fit)
    p = polyfit(nSi, peakAreas(d, :), 5);   % 5th-degree polynomial fit
    yfit = polyval(p, nSi);  % Evaluate the fitted values
    
    % Plot the curve of best fit with a thinner line
    plot(nSi, yfit, 'Color', colors{d}, 'LineWidth', 1, 'LineStyle', '-', 'DisplayName', [dopants{d}.name, ' Fit']);
    
    % Annotate the total area on the plot (near the last data point of the curve)
    totalArea = peakAreas(d, end);  % Get the total area for the last nSi value
    text(nSi(end), totalArea, sprintf('Total Area: %.2f', totalArea), ...
        'Color', colors{d}, 'FontSize', 10, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
end

% Add labels, title, and legend
legend('Location', 'northeast', 'FontSize', 12, 'FontWeight', 'bold');
title('Integration of EPR Spectrum vs Number of 29Si Nuclei', 'FontSize', 14, 'FontWeight', 'bold');
xlabel('Number of 29Si', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Total Area (Arbitrary Units)', 'FontSize', 12, 'FontWeight', 'bold');
grid on;

% Enhance axis properties for publication
set(gca, 'FontSize', 12, 'FontWeight', 'bold', 'LineWidth', 1.5, 'Box', 'on');

% Save the figure with a new title and name
saveas(gcf, 'EPR_Spectrum_Area_vs_29Si.png');
exportgraphics(gcf, 'EPR_Spectrum_Area_vs_29Si.tiff', 'Resolution', 300);
