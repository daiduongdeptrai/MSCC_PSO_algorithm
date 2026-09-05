function PSO_multiple_SoC
clear all
clc

tic;  % Start timer

% Parameters
lb = 0.1 * ones(1, 5);
ub = 1.31 * ones(1, 5);
num_particles = 500;
max_iter = 200;

% Define range of initial SoC values (from 0.1 to 0.9 in steps of 0.1)
SoC_values = 0.2:0.1:0.9;
num_SoC = length(SoC_values);

% Preallocate results storage
results = struct('SoC_initial', num2cell(SoC_values), ...
                 'optimal_currents', cell(1,num_SoC), ...
                 'charging_time', zeros(1,num_SoC), ...
                 'capacity', zeros(1,num_SoC), ...
                 'cost', zeros(1,num_SoC));

% Main optimization loop for each SoC
for soc_idx = 1:num_SoC
    current_SoC = SoC_values(soc_idx);
    fprintf('\nOptimizing for initial SoC = %.1f...\n', current_SoC);
    
    % Initialize swarm
    swarm = rand(num_particles, 5) .* (ub - lb) + lb;
    velocity = zeros(num_particles, 5);
    
    pbest = swarm;
    pbest_cost = inf(num_particles, 1);
    gbest = zeros(1, 5);
    gbest_cost = inf;
    
    % PSO optimization
    for iter = 1:max_iter
        for i = 1:num_particles
            r1 = rand(1, 5);
            r2 = rand(1, 5);
            velocity(i,:) = velocity(i,:) ...
                + 2 * r1 .* (pbest(i,:) - swarm(i,:)) ...
                + 2 * r2 .* (gbest - swarm(i,:));
            
            swarm(i,:) = swarm(i,:) + velocity(i,:);
            swarm(i,:) = max(min(swarm(i,:), ub), lb);
            
            % Pass current SoC to objective function
            cost = objective(swarm(i,:), current_SoC);
            
            if cost < pbest_cost(i)
                pbest(i,:) = swarm(i,:);
                pbest_cost(i) = cost;
                if cost < gbest_cost
                    gbest = swarm(i,:);
                    gbest_cost = cost;
                end
            end
        end
        fprintf('Iteration %d - Best Cost: %.4f\n', iter, gbest_cost);
    end
    
    % Store results
    results(soc_idx).optimal_currents = gbest;
    [time, capacity] = simulate_charge(gbest, current_SoC);
    results(soc_idx).charging_time = time;
    results(soc_idx).capacity = capacity;
    results(soc_idx).cost = gbest_cost;
    
    % Display current result
    fprintf('Optimized for SoC = %.1f:\n', current_SoC);
    fprintf('Currents: %s\n', mat2str(gbest, 4));
    fprintf('Time: %.2f s, Capacity: %.2f mAh, Cost: %.4f\n\n', ...
            time, capacity, gbest_cost);
end

% Export results to Excel
export_results_to_excel(results);

elapsed_time = toc;
fprintf('Total execution time: %.2f seconds\n', elapsed_time);
end

% Modified objective function to accept SoC as parameter
function cost = objective(I_pattern, SoC_initial)
    CCCV_time = 3200;
    CCCV_capacity = 1310;
    alpha = 0.9;
    beta = 1 - alpha;

    % Check current pattern constraints
    if ~((I_pattern(1) <= 1.31) && ...
      (I_pattern(1) > I_pattern(2)) && ...
      (I_pattern(2) > I_pattern(3)) && ...
      (I_pattern(3) > I_pattern(4)) && ...
      (I_pattern(4) > I_pattern(5)) && ...
      (I_pattern(5) > 0.1))
        cost = inf;
        return;
    end

    [time, capacity] = simulate_charge(I_pattern, SoC_initial);

    if (capacity < CCCV_capacity)
        cost = inf;
        return;
    end

    cost = alpha * (time - CCCV_time) / CCCV_time ...
         + beta * (CCCV_capacity - capacity) / CCCV_capacity;
end

% Modified simulation function to accept SoC as parameter
function [time, capacity] = simulate_charge(I_pattern, SoC_initial)
    state = 1;
    U_cutoff = 4.2;
    Q0 = 1310 * 3.6;            % Nominal capacity (C)
    h = 0.01;
    t_max = 10000;

    N = t_max / h;
    Qk = 0;
    Qk_1 = SoC_initial*Q0;
    Ucpk = 0;
    Ucpk_1 = 0;
    time = 0;
    capacity = 0;

    for k=1:N
        tk = k*h;
        Ik = I_pattern(state);
        
        Qk = Qk_1 + Ik * h;   % Current integration over time
        
        SoCk = Qk / Q0;
        
    % ======= Tham số từ mô hình mới =======
    % OCV giữ nguyên
    OCVk = 49.6031746023540*SoCk^7 - 242.777777773998*SoCk^6 + 482.055555548292*SoCk^5 - 502.200854693335*SoCk^4 ...
         + 296.925106833103*SoCk^3 - 99.8582591282089*SoCk^2 + 18.1649483180672*SoCk + 2.28813333335377;

    % R0 mới (giữ nguyên)
    R0k = -26.2660619798791*SoCk^7 + 109.918871250115*SoCk^6 - 190.459259255377*SoCk^5 + 176.529168358619*SoCk^4 ...
        - 94.1353744381275*SoCk^3 + 28.7364437012291*SoCk^2 - 4.63111345741627*SoCk + 0.316849947080660;

    % Rp mới
    Rpk = -200.375779563424*SoCk^7 + 845.710133351627*SoCk^6 - 1498.43113893579*SoCk^5 + 1444.42363360624*SoCk^4 ...
        - 817.251138248603*SoCk^3 + 270.930470785998*SoCk^2 - 48.6443704325001*SoCk + 3.67438046376537;

    % Cp mới
    Cpk = 14029806.8139774*SoCk^7 - 59290766.0815755*SoCk^6 + 103717775.345970*SoCk^5 - 96939625.1087752*SoCk^4 ...
        + 52045639.6093783*SoCk^3 - 15987520.6386594*SoCk^2 + 2596199.68902636*SoCk - 169463.377880981;
    
        
        Ucpk = Ucpk_1 + h * (-Ucpk / (Rpk * Cpk) + Ik / Cpk);
        
        U_tk = OCVk + R0k * Ik + Ucpk; 
        
        Qk_1 = Qk;
        Ucpk_1 = Ucpk;
        
        if U_tk >= U_cutoff
            state = state + 1;
        end
       
        if state > 5
            Ik = 0;
            time = tk;
            capacity = Qk/3.6;
            break;
        end
    end
end

% Function to export results to Excel
function export_results_to_excel(results)
    filename = 'Optimized_Charging_Profiles.xlsx';
    
    % Prepare data for Excel
    SoC_initial = [results.SoC_initial]';
    I1 = cellfun(@(x) x(1), {results.optimal_currents}');
    I2 = cellfun(@(x) x(2), {results.optimal_currents}');
    I3 = cellfun(@(x) x(3), {results.optimal_currents}');
    I4 = cellfun(@(x) x(4), {results.optimal_currents}');
    I5 = cellfun(@(x) x(5), {results.optimal_currents}');
    charging_time = [results.charging_time]';
    capacity = [results.capacity]';
    cost = [results.cost]';
    
    % Create table
    T = table(SoC_initial, I1, I2, I3, I4, I5, charging_time, capacity, cost, ...
              'VariableNames', {'Initial_SoC', 'I1_A', 'I2_A', 'I3_A', 'I4_A', 'I5_A', ...
                                'Charging_Time_s', 'Capacity_mAh', 'Cost'});
    
    % Write to Excel
    writetable(T, filename);
    fprintf('Results exported to %s\n', filename);
    
    % Additional sheet with formatted results
    headers = {'Initial SoC', 'I1 (A)', 'I2 (A)', 'I3 (A)', 'I4 (A)', 'I5 (A)', ...
               'Charging Time (s)', 'Capacity (mAh)', 'Cost'};
    data = [SoC_initial, I1, I2, I3, I4, I5, charging_time, capacity, cost];
    
    % Write formatted sheet
    writecell(headers, filename, 'Sheet', 'Formatted Results', 'Range', 'A1');
    writematrix(data, filename, 'Sheet', 'Formatted Results', 'Range', 'A2');
end