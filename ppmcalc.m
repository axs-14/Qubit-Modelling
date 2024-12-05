function concentration_ppm = calculate_29Si_concentration(nSi_in_Bohr)
    % Constants
    a0 = 2.087e-9;  % Bohr radius in meters (m)
    Si_density_cm3 = 5e22; % Silicon number density in atoms/cm^3
    Si_density_m3 = Si_density_cm3 * 1e6; % Convert to atoms/m^3
    
    % Volume of the Bohr radius (sphere)
    V_Bohr = (4/3) * pi * a0^3;  % Volume in cubic meters (m^3)
    
    % Total number of Si atoms in the volume of Bohr radius
    total_atoms_in_Bohr = Si_density_m3 * V_Bohr;
    
    % Calculate the concentration in ppm (parts per million)
    concentration_ppm = (nSi_in_Bohr / total_atoms_in_Bohr) * 1e6;
    
    % Output the concentration
    fprintf('Concentration of 29Si in the Bohr radius: %.4e ppm\n', concentration_ppm);
end

nSi_in_Bohr = 1;  
concentration_ppm = calculate_29Si_concentration(nSi_in_Bohr);

%compare 1 29Si results to data in research papers
%fit broadening from the same paper, then after that apply the broadening
%to other concentrations of silicon 29 and then see the absorption vs
%concentration (integrate under fitted curve) 
%anti-crossing
%use quadrupole coupling