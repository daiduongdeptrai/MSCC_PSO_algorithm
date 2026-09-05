% ===== Chạy GA 10 lần và lưu fitness history =====
num_runs = 5;
max_generations = 60;
all_fitness = zeros(max_generations, num_runs);

for run = 1:num_runs
    fprintf('\n====== LẦN CHẠY THỨ %d ======\n', run);
    [~, ~, fitness_history] = GA_optimization();
    all_fitness(:, run) = fitness_history;
end

% Ghi ra Excel
iterations = (1:max_generations)';
T = array2table([iterations, all_fitness], ...
    'VariableNames', ['Iteration', compose("Run_%d", 1:num_runs)]);

filename = 'GA_10_runs_fitness.xlsx';
writetable(T, filename);
fprintf('\n✅ Đã ghi dữ liệu hội tụ vào file: %s\n', filename);
