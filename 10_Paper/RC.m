function Chungminhbangcapsonhan2()
    % Battery parameters from the paper
    V_cutoff = 4.22;       % Cutoff voltage (V)
    OCV = 3.35;
    R_eq = 0.068;          % Equivalent resistance (Ohm)
    C_eq = 11030;          % Equivalent capacitance (F)
    n_stages = 5;          % Number of charging stages
    I = 2.6;               % 1C current
    Q0 = I * 3600;
    
    % Generate initial voltage vector from 3.35V to 4.1V
    V_initial = linspace(3.35, 4.1, 100);

    % Compute SoC from V_initial
    SoC = (V_initial - OCV) * C_eq ./ Q0;
    
    % Compute I_last for each V_initial
    I_last = (V_cutoff - V_initial) / R_eq - Q0 * (1 - SoC) ./ (R_eq * C_eq);
    
    % Compute I_first for each V_initial
    I_first = nthroot(((V_cutoff - V_initial) / R_eq) .^ (n_stages - 1) .* I_last, n_stages);
    I_first_const = I * ones(size(V_initial));

    % Compute q
    q = nthroot(I_last ./ I_first, 4);
    q_const = nthroot(I_last ./ I_first_const, 4);
    
    % Compute charging time
    T1 = (V_cutoff - V_initial) * C_eq ./ I_first_const + (4 ./ q_const - 5) * R_eq * C_eq;
    T2 = (V_cutoff - V_initial) * C_eq ./ I_first + (4 ./ q - 5) * R_eq * C_eq;
    Q = ((V_cutoff - V_initial) * C_eq - I_last * C_eq * R_eq);

    % Create wide figure (landscape)
    figure('Position', [100, 100, 1200, 400]); 
    
    % Subplot 1: Charging time
    subplot(1, 2, 1);
    plot(SoC*100, T1, 'b-', 'LineWidth', 2, 'DisplayName', 'Charging time at 1C');
    hold on;
    plot(SoC*100, T2, 'r--', 'LineWidth', 2, 'DisplayName', 'Optimal charging time');
    xlabel('Initial SoC (%)');
    ylabel('Charging time (s)');
    title('Comparison of Charging Time', 'FontWeight', 'bold');
    grid on;
    legend('show', 'Location', 'northwest');
    ylim([min([T1(:); T2(:)])*0.95, max([T1(:); T2(:)])*1.05]);
    hold off;
    
    % Subplot 2: Charging current
    subplot(1, 2, 2);
    plot(SoC*100, I_first_const, 'b-', 'LineWidth', 2, 'DisplayName', 'Constant 1C current (2.6A)');
    hold on;
    plot(SoC*100, I_first, 'r--', 'LineWidth', 2, 'DisplayName', 'Optimal current');
    xlabel('Initial SoC (%)');
    ylabel('Charging current (A)');
    title('Comparison of Charging Current', 'FontWeight', 'bold');
    grid on;
    legend('show', 'Location', 'northwest');
    ylim([min([I_first(:); I_first_const(:)])*0.95, max([I_first(:); I_first_const(:)])*1.05]);
    hold off;

    % Display results in Command Window
    fprintf('=== Calculation Results ===\n');
    fprintf('Charging time at 1C (T1): from %.2f s to %.2f s\n', min(T1), max(T1));
    fprintf('Optimal charging time (T2): from %.2f s to %.2f s\n', min(T2), max(T2));
    fprintf('Optimal charging current: from %.2f A to %.2f A\n', min(I_first), max(I_first));
    fprintf('Average time difference: %.2f s\n', mean(T1 - T2));
    fprintf('Charging time (T1 array): %.2f s\n', T1);
    fprintf('Required capacity: %.2f mAh\n', Q/3.6);
end
