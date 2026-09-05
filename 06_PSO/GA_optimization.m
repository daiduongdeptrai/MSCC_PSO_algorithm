function [time, capacity, fitness_history] = GA_optimization()
    clearvars -except time capacity fitness_history
    clc
    tic;

    % Problem parameters
    lb = 0.1 * ones(1, 5);
    ub = 2.0 * ones(1, 5);

    % GA parameters
    population_size = 20;
    max_generations = 60;
    crossover_prob = 0.8;
    mutation_prob = 0.1;
    elite_count = 2;

    population = rand(population_size, 5) .* (ub - lb) + lb;

    fitness = zeros(population_size, 1);
    for i = 1:population_size
        fitness(i) = objective(population(i,:));
    end

    [best_fitness, best_idx] = min(fitness);
    best_individual = population(best_idx,:);
    fitness_history = zeros(max_generations, 1);

    for gen = 1:max_generations
        parents = tournament_selection(population, fitness, population_size);
        offspring = [];

        for i = 1:2:population_size-1
            if rand() < crossover_prob
                child1 = blend_crossover(parents(i,:), parents(i+1,:), lb, ub);
                child2 = blend_crossover(parents(i+1,:), parents(i,:), lb, ub);
                offspring = [offspring; child1; child2];
            else
                offspring = [offspring; parents(i,:); parents(i+1,:)];
            end
        end

        for i = 1:size(offspring,1)
            if rand() < mutation_prob
                offspring(i,:) = gaussian_mutation(offspring(i,:), lb, ub, gen, max_generations);
            end
        end

        [sorted_fitness, sort_idx] = sort(fitness);
        elite = population(sort_idx(1:elite_count),:);
        population = [elite; offspring(1:population_size-elite_count,:)];

        for i = 1:population_size
            fitness(i) = objective(population(i,:));
        end

        [current_best_fitness, current_best_idx] = min(fitness);
        if current_best_fitness < best_fitness
            best_fitness = current_best_fitness;
            best_individual = population(current_best_idx,:);
        end

        fitness_history(gen) = best_fitness;
        fprintf('Generation %d - Best Cost: %.4f charge rates: %s\n', gen, best_fitness, mat2str(best_individual, 4));
    end

    [time, capacity] = simulate_charge(best_individual);
    fprintf('\nOptimized charge rates: %s\n', mat2str(best_individual, 4));
    fprintf('Total cost: %.4f\n', best_fitness);
    fprintf('Charging time: %.2f seconds\n', time);
    fprintf('Charged capacity: %.2f mAh\n', capacity);

    elapsed_time = toc;
    fprintf('Thời gian thực hiện toàn bộ chương trình: %.2f giây\n', elapsed_time);
end

% ========== Subfunctions ==========
function selected = tournament_selection(population, fitness, pop_size)
    tournament_size = 3;
    selected = zeros(pop_size, size(population,2));
    for i = 1:pop_size
        contestants = randperm(pop_size, tournament_size);
        [~, best_idx] = min(fitness(contestants));
        selected(i,:) = population(contestants(best_idx),:);
    end
end

function child = blend_crossover(parent1, parent2, lb, ub)
    alpha = 0.5;
    child = zeros(size(parent1));
    for i = 1:length(parent1)
        d = abs(parent1(i) - parent2(i));
        min_val = max(min(parent1(i), parent2(i)) - alpha * d, lb(i));
        max_val = min(max(parent1(i), parent2(i)) + alpha * d, ub(i));
        child(i) = min_val + rand() * (max_val - min_val);
    end
end

function mutated = gaussian_mutation(individual, lb, ub, gen, max_gen)
    mutated = individual;
    mutation_power = 1 - gen/max_gen;
    for i = 1:length(individual)
        if rand() < 0.3
            mutated(i) = individual(i) + mutation_power * randn() * (ub(i)-lb(i))/10;
            mutated(i) = max(min(mutated(i), ub(i)), lb(i));
        end
    end
    for i = 1:4
        if mutated(i) <= mutated(i+1)
            temp = mutated(i);
            mutated(i) = mutated(i+1);
            mutated(i+1) = temp;
        end
    end
end

function cost = objective(I_pattern)
    CCCV_time = 3710;
    CCCV_capacity = 1800;
    alpha = 0.9;
    beta = 1 - alpha;

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
    if (capacity < CCCV_capacity)
        cost = inf;
        return;
    end

    cost = alpha * (time - CCCV_time) / CCCV_time ...
         + beta * (CCCV_capacity - capacity) / CCCV_capacity;
end

function [time, capacity] = simulate_charge(I_pattern)
    state = 1;
    U_cutoff = 4.2;
    Q0 = 2000 * 3.6;
    h = 0.01;
    t_max = 10000;

    N = t_max / h;
    Qk = 0; Qk_1 = 0;
    Ucpk = 0; Ucpk_1 = 0;
    time = 0; capacity = 0;

    for k = 1:N
        tk = k*h;
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
            + 111.4*SoCk^4 + 44.86*SoCk^5 - 1.53*SoCk^6 + 0.108*SoCk^7;

        Ucpk = Ucpk_1 + h * (-Ucpk / (Rpk * Cpk) + Ik / Cpk);
        U_tk = OCVk + R0k * Ik + Ucpk;

        Qk_1 = Qk;
        Ucpk_1 = Ucpk;

        if U_tk >= U_cutoff
            state = state + 1;
        end
        if state > 5
            time = tk;
            capacity = Qk / 3.6;
            break;
        end
    end
end
