function ProofByInduction2()
    % Battery parameters from the paper
    V_cutoff = 4.22;       % Cutoff voltage (V)
    OCV = 3.35;            % Open-circuit voltage (V)
    R_eq = 0.068;          % Equivalent resistance (Ohm)
    C_eq = 11030;          % Equivalent capacitance (F)
    n_stages = 5;          % Number of charging stages
    Q0 = 2.6 * 3600;       % Nominal capacity (Coulombs)
    
    % Generate initial voltage vector from 3.35V to 4V
    V_initial = linspace(3.35, 4, 100);
    
    % Calculate parameters
    SoC = (V_initial - OCV) * C_eq ./ Q0;  % State of charge from V_initial
    
    % Calculate I_last for each V_initial
    I_last = (V_cutoff - V_initial) / R_eq - Q0 * (1 - SoC) ./ (R_eq * C_eq);
    
    % Calculate I_first for each V_initial
    I_first = nthroot(((V_cutoff - V_initial) / R_eq) .^ (n_stages - 1) .* I_last, n_stages);
    I_first_const = 2.6 * ones(size(V_initial));

    % Calculate q for each V_initial
    q = nthroot(I_last ./ I_first, 4);
    
    % Calculate charging time T and capacity Q
    T = (V_cutoff - V_initial) * C_eq ./ I_first + (4 ./ q - 5) * R_eq * C_eq;
    Q = ((V_cutoff - V_initial) * C_eq - I_last * C_eq * R_eq) + Q0 * SoC;
    
    % Plot Q vs. SoC for both cases
    figure(1);
    plot(SoC*100, Q/3.6, 'b-', 'LineWidth', 2); hold on;  % Q with I_first
    plot(SoC*100, Q/3.6, 'r--', 'LineWidth', 2);          % Q with I_first_const
    xlabel('Initial State of Charge SoC (%)');
    ylabel('Battery capacity after charging (mAh)');
    title('Comparison of charging capacity');
    legend('Charging capacity at 1C', 'Optimized charging capacity', 'Location', 'SouthEast');
    grid on;
    ylim([0, 3000]);
    
    % Display results
    fprintf('=== Calculation results ===\n');
    fprintf('Final current I_last: from %.4f A to %.4f A\n', min(I_last), max(I_last));
    fprintf('Coefficient q: from %.4f to %.4f\n', min(q), max(q));
    fprintf('Charging time: from %.2f s to %.2f s\n', min(T), max(T));
end
