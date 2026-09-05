function JA_Optimization

    % Cài đặt tham số
    lb = 0.1 * ones(1, 5);
    ub = 5.0 * ones(1, 5);
    num_jellyfish = 50;
    max_iter = 5000;
    dim = 5;

    % Khởi tạo quần thể
    pop = rand(num_jellyfish, dim) .* (ub - lb) + lb;
    fitness = zeros(num_jellyfish, 1);

    % Tính chi phí ban đầu
    for i = 1:num_jellyfish
        fitness(i) = objective(pop(i,:));
    end

    % Lưu cá thể tốt nhất
    [best_fitness, best_idx] = min(fitness);
    best_sol = pop(best_idx,:);

    cost_history = zeros(max_iter,1);

    % Vòng lặp tối ưu
    for iter = 1:max_iter
        alpha = 0.2 + (0.8 * iter / max_iter);  % Cân bằng exploration và exploitation

        for i = 1:num_jellyfish
            r = rand;
            if r < alpha  % Di chuyển theo dòng nước (exploration)
                rand_idx = randi([1 num_jellyfish]);
                drift = rand * (pop(rand_idx,:) - pop(i,:));
                new_pos = pop(i,:) + drift;
            else  % Di chuyển chủ động (exploitation)
                j = randi([1 num_jellyfish]);
                if fitness(j) < fitness(i)
                    direction = pop(j,:) - pop(i,:);
                else
                    direction = pop(i,:) - pop(j,:);
                end
                new_pos = pop(i,:) + rand * direction;
            end

            % Giới hạn biên
            new_pos = max(min(new_pos, ub), lb);

            % Tính chi phí
            new_fit = objective(new_pos);
            if new_fit < fitness(i)
                pop(i,:) = new_pos;
                fitness(i) = new_fit;

                if new_fit < best_fitness
                    best_fitness = new_fit;
                    best_sol = new_pos;
                end
            end
        end

        cost_history(iter) = best_fitness;
        fprintf('Iter %d - Best Cost: %.4f charge rates: %s\n', iter, best_fitness, mat2str(best_sol, 4));
    end

    fprintf('Optimized charge rates: %s\n', mat2str(best_sol, 4));
    fprintf('Total cost: %.4f\n', best_fitness);

    % Vẽ đồ thị hội tụ
    figure;
    plot(1:max_iter, cost_history, 'LineWidth', 2);
    xlabel('Generation');
    ylabel('Best Cost');
    title('JA Convergence Curve');
    grid on;
end


function cost = objective(I_pattern)

    CCCV_time = 3710;
    CCCV_capacity = 1800;
    alpha = 0.5;
    beta = 1 - alpha;

    if ~((I_pattern(1) <= 5) && ...
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
    state = 1;
    U_cutoff = 4.2;
    Q0 = 2000 * 3.6;
    h = 0.01;
    t_max = 10000;

    N = t_max / h;
    Qk = 0;
    Qk_1 = 0.5*Q0;
    Ucpk = 0;
    Ucpk_1 = 0;
    time = 0;
    capacity = 0;

    for k = 1:N
        tk = k * h;
        Ik = I_pattern(state);

        Qk = Qk_1 + Ik * h;
        SoCk = Qk / Q0;

        OCVk = 2.896 + 9.563*SoCk - 57.92*SoCk^2 + 188.2*SoCk^3 ...
             - 340.7*SoCk^4 + 347.5*SoCk^5 - 184.2*SoCk^6 + 38.95*SoCk^7;
        R0k = 0.039 - 0.131*SoCk + 0.507*SoCk^2 - 1.129*SoCk^3 ...
            + 1.679*SoCk^4 - 1.764*SoCk^5 + 1.157*SoCk^6 - 0.331*SoCk^7;
        Rpk = 0.048 - 0.318*SoCk + 2.075*SoCk^2 - 9.171*SoCk^3 ...
            + 23.41*SoCk^4 - 31.96*SoCk^5 + 21.71*SoCk^6 - 5.78*SoCk^7;
        Cpk = 104.9 - 311.3*SoCk + 277.9*SoCk^2 - 2.435*SoCk^3 ...
            - 111.4*SoCk^4 + 44.86*SoCk^5 - 1.53*SoCk^6 + 0.108*SoCk^7;

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
            capacity = Qk / 3.6;
            break;
        end
    end
end
