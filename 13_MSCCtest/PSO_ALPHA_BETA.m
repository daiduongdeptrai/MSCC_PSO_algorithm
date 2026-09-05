function PSO
clear all
clc

tic;  % === Bắt đầu đo thời gian ===

lb = 0.1 * ones(1, 5);
ub = 1.31 * ones(1, 5);
num_particles = 500;
max_iter = 100;

% Khởi tạo swarm
swarm = rand(num_particles, 5) .* (ub - lb) + lb;
velocity = zeros(num_particles, 5);

pbest = swarm;
pbest_cost = inf(num_particles, 1);
gbest = zeros(1, 5);
gbest_cost = inf;

cost_history = zeros(max_iter, 1);

% Vòng lặp tối ưu
for iter = 1:max_iter
    for i = 1:num_particles
        r1 = rand(1, 5);
        r2 = rand(1, 5);
        velocity(i,:) = velocity(i,:) ...
            + 2 * r1 .* (pbest(i,:) - swarm(i,:)) ...
            + 2 * r2 .* (gbest - swarm(i,:));
        
        swarm(i,:) = swarm(i,:) + velocity(i,:);
        swarm(i,:) = max(min(swarm(i,:), ub), lb);

        cost = objective(swarm(i,:));
        if cost < pbest_cost(i)
            pbest(i,:) = swarm(i,:);
            pbest_cost(i) = cost;
            if cost < gbest_cost
                gbest = swarm(i,:);
                gbest_cost = cost;
            end
        end
    end
    fprintf('Iteration %d - Best Cost: %.4f charge rates: %s\n', iter, gbest_cost, mat2str(gbest, 4));
    cost_history(iter) = gbest_cost;
end

best_solution = gbest;
best_cost = gbest_cost;
[time, capacity] = simulate_charge(best_solution);

fprintf('Optimized charge rates: %s\n', mat2str(best_solution, 4));
fprintf('Total cost: %.4f\n', best_cost);
fprintf('Thời gian sạc kết thúc: %.2f giây\n', time);
fprintf('Dung lượng sạc được: %.2f mAh\n', capacity);

% Vẽ đồ thị hội tụ
figure(1);
plot(1:max_iter, cost_history, 'LineWidth', 2);
xlabel('Generation');
ylabel('Best Cost');
title('PSO Convergence Curve');
grid on;

% Xuất dữ liệu hội tụ ra Excel
filename = 'PSO_Convergence_Curve.xlsx';
iterations = (1:max_iter)';

T = table(iterations, cost_history, ...
          'VariableNames', {'Iteration', 'BestCost'});

writetable(T, filename);
fprintf('Convergence curve data exported to %s\n', filename);

elapsed_time = toc;  % === Kết thúc đo thời gian ===
fprintf('Thời gian thực hiện toàn bộ chương trình: %.2f giây\n', elapsed_time);

end




function cost = objective(I_pattern)
    CCCV_time = 3200;
    CCCV_capacity = 1048;
    alpha = 0.9;
    beta = 1 - alpha;

    if ~((I_pattern(1) <= 1.31) && ...
         (I_pattern(1) > I_pattern(2)) && ...
         (I_pattern(2) > I_pattern(3)) && ...
         (I_pattern(3) > I_pattern(4)) && ...
         (I_pattern(4) > I_pattern(5)) && ...
         (I_pattern(5) > 0.1))
        cost = inf;
        return;
    end

    [time, capacity] = simulate_charge(I_pattern);
    

    if (capacity < CCCV_capacity)
        cost = inf;
        return;
    end

    cost = alpha * (time - CCCV_time) / CCCV_time ...
         + beta * (CCCV_capacity - capacity) / CCCV_capacity;
end



function [time,capacity]=simulate_charge(I_pattern)
    % ================= THÔNG SỐ BAN ĐẦU =================
    state = 1;
    U_cutoff = 4.2;
    Q0 = 1310 * 3.6;            % Dung lượng danh định (C)
    h = 0.01;
    t_max = 10000;
    %I_pattern=[2,1.5,1,0.6,0.2];

    % ================= KHỞI TẠO DỮ LIỆU =================
    N = t_max / h;
    Qk = 0;
    Qk_1 = 0.85 *Q0;
    Ucpk = 0;
    Ucpk_1 = 0;
    time = 0;
    capacity = 0;

for k=1:N
    tk = k*h;
    Ik = I_pattern(state);
    
    % Tính Qk (Coulomb)
    Qk = Qk_1 + Ik * h;   % Tích phân dòng theo thời gian
    
    % Tính SoC
    SoCk = Qk / Q0;
    
        % OCV giữ nguyên
    OCVk = 49.6031746023540*SoCk^7 - 242.777777773998*SoCk^6 + 482.055555548292*SoCk^5 - 502.200854693335*SoCk^4 ...
         + 296.925106833103*SoCk^3 - 99.8582591282089*SoCk^2 + 18.1649483180672*SoCk + 2.28813333335377;

    % R0 mới
    R0k = -26.2660619798791*SoCk^7 + 109.918871250115*SoCk^6 - 190.459259255377*SoCk^5 + 176.529168358619*SoCk^4 ...
        - 94.1353744381275*SoCk^3 + 28.7364437012291*SoCk^2 - 4.63111345741627*SoCk + 0.316849947080660;

    % Rp mới
    Rpk = -200.375779563424*SoCk^7 + 845.710133351627*SoCk^6 - 1498.43113893579*SoCk^5 + 1444.42363360624*SoCk^4 ...
        - 817.251138248603*SoCk^3 + 270.930470785998*SoCk^2 - 48.6443704325001*SoCk + 3.67438046376537;

    % Cp mới
    Cpk = 14029806.8139774*SoCk^7 - 59290766.0815755*SoCk^6 + 103717775.345970*SoCk^5 - 96939625.1087752*SoCk^4 ...
        + 52045639.6093783*SoCk^3 - 15987520.6386594*SoCk^2 + 2596199.68902636*SoCk - 169463.377880981;
    
    % RC song song
    Ucpk = Ucpk_1 + h * (-Ucpk / (Rpk * Cpk) + Ik / Cpk);
    
    % Điện áp pin
    U_tk = OCVk + R0k * Ik + Ucpk; 
    
    % Cập nhật giá trị
    Qk_1 = Qk;
    Ucpk_1=Ucpk;
    
    % MSCC logic
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


function F = fuzzy_fitness(CT, NCC)
    fis = readfis('FDFE_SOC.fis');
    inputs = [CT NCC];   
    F = evalfis(fis, inputs);  % Đã đổi thứ tự tham số
end


