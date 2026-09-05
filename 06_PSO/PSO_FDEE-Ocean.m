function PSO
clear all
clc

tic;  % === Bắt đầu đo thời gian ===

lb = 0.1 * ones(1, 5);
ub = 2.0 * ones(1, 5);
num_particles = 300;
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

    if ~((I_pattern(1) <= 2) && ...
         (I_pattern(1) > I_pattern(2)) && ...
         (I_pattern(2) > I_pattern(3)) && ...
         (I_pattern(3) > I_pattern(4)) && ...
         (I_pattern(4) > I_pattern(5)) && ...
         (I_pattern(5) > 0.1))
        cost = inf;
        return;
    end

    [time, capacity] = simulate_charge(I_pattern);
    
    CT = time / 60;  % đổi ra phút
    NCC = (capacity / 2000)*100; % Phần trăm dung lượng sạc được 
    
    % Kiểm tra điều kiện giới hạn của CT và NCC
    if (CT < 0 || CT > 90) || (NCC < 80 || NCC > 100)
        cost = inf;
        return;
    end

    % Tính fuzzy fitness
    fitness = fuzzy_fitness(CT, NCC);  % Hàm bạn sẽ xây dựng ở dưới

    cost = fitness;  % Vì PSO đang MINIMIZE cost
end



function [time,capacity]=simulate_charge(I_pattern)
    % ================= THÔNG SỐ BAN ĐẦU =================
    state = 1;
    U_cutoff = 4.2;
    Q0 = 2000 * 3.6;            % Dung lượng danh định (C)
    h = 0.01;
    t_max = 10000;
    %I_pattern=[2,1.5,1,0.6,0.2];

    % ================= KHỞI TẠO DỮ LIỆU =================
    N = t_max / h;
    Qk = 0;
    Qk_1 = 0.9*Q0;
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
    
    % Tính các thông số tương ứng
    OCVk = 2.896 + 9.563*SoCk - 57.92*SoCk^2 + 188.2*SoCk^3 ...
       - 340.7*SoCk^4 + 347.5*SoCk^5 - 184.2*SoCk^6 + 38.95*SoCk^7;
    
    R0k = 0.039 - 0.131*SoCk + 0.507*SoCk^2 - 1.129*SoCk^3 ...
     + 1.679*SoCk^4 - 1.764*SoCk^5 + 1.157*SoCk^6 - 0.331*SoCk^7;
    
    Rpk = 0.048 - 0.318*SoCk + 2.075*SoCk^2 - 9.171*SoCk^3 ...
     + 23.41*SoCk^4 - 31.96*SoCk^5 + 21.71*SoCk^6 - 5.78*SoCk^7;
    
    Cpk = 104.9 - 311.3*SoCk + 277.9*SoCk^2 - 2.435*SoCk^3 ...
     - 111.4*SoCk^4 + 44.86*SoCk^5 - 1.53*SoCk^6 + 0.108*SoCk^7;
    
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


