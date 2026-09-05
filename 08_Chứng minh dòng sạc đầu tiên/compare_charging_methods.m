function compare_charging_methods()
    % Thông số pin từ bài báo
    V_cutoff = 4.22;       % Điện áp ngắt (V)
    V_initial = 3.35;      % Điện áp ban đầu (V)
    R_eq = 0.068;          % Điện trở tương đương (Ohm)
    C_eq = 11030;          % Điện dung tương đương (F)
    I_CC = 2.6;            % Dòng sạc CC (A)
    I_min = 0.05;          % Dòng ngắt (A)
    
    % Tính toán thời gian sạc CC-CV
    [t_CC, t_CV, t_CCCV] = calculate_CCCV_time(I_CC, V_cutoff, V_initial, R_eq, C_eq, I_min);
    
    % Tính toán cho MSCC (từ 2-50 stages)
    min_stages = 2;
    max_stages = 50;
    stage_counts = min_stages:max_stages;
    t_MSCC = zeros(size(stage_counts));
    
    for i = 1:length(stage_counts)
        n = stage_counts(i);
        I_pattern = generate_optimal_pattern(n, I_CC, I_min);
        t_MSCC(i) = calculate_MSCC_time(I_pattern, V_cutoff, V_initial, R_eq, C_eq);
    end
    
    % Hiển thị kết quả
    fprintf('=== Kết quả thời gian sạc (giây) ===\n');
    fprintf('Phương pháp CC-CV:\n');
    fprintf('  - Giai đoạn CC: %.2f s\n', t_CC);
    fprintf('  - Giai đoạn CV: %.2f s\n', t_CV);
    fprintf('  - Tổng thời gian: %.2f s (≈%.2f phút)\n\n', t_CCCV, t_CCCV/60);
    
    fprintf('Phương pháp MSCC (từ %d stage trở lên):\n', min_stages);
    for i = 1:length(stage_counts)
        n = stage_counts(i);
        fprintf('  - %d stage: %.2f s (≈%.2f phút)\n', n, t_MSCC(i), t_MSCC(i)/60);
    end
    
    % Vẽ đồ thị so sánh
    figure;
    plot(stage_counts, t_MSCC, '-o', 'LineWidth', 2); hold on;
    yline(t_CCCV, '--r', 'CC-CV', 'LineWidth', 2);
    xlabel('Số stage sạc MSCC');
    ylabel('Thời gian sạc (giây)');
    title('So sánh thời gian sạc MSCC và CC-CV');
    legend('MSCC', 'CC-CV', 'Location', 'best');
    grid on;
end

%% Hàm tính thời gian sạc CC-CV
function [t_CC, t_CV, t_total] = calculate_CCCV_time(I_CC, V_cutoff, V_initial, R_eq, C_eq, I_min)
    % Giai đoạn CC (công thức 4 trong bài báo)
    t_CC = (C_eq/I_CC) * (V_cutoff - V_initial - I_CC*R_eq);
    
    % Giai đoạn CV (giải phương trình vi phân dI/dt = -I/(R_eq*C_eq))
    tau = R_eq * C_eq; % Hằng số thời gian
    t_CV = tau * log(I_CC/I_min);
    
    t_total = t_CC + t_CV;
end

%% Hàm tạo pattern dòng sạc tối ưu cho MSCC
function I_pattern = generate_optimal_pattern(n, I_first, I_last)
    % Phân bố dòng sạc theo cấp số nhân
    I_pattern = exp(linspace(log(I_first), log(I_last), n));
end

%% Hàm tính thời gian sạc MSCC
function total_time = calculate_MSCC_time(I_pattern, V_cutoff, V_initial, R_eq, C_eq)
    total_time = 0;
    V_s = V_initial;
    
    for i = 1:length(I_pattern)
        I_i = I_pattern(i);
        delta_t = (C_eq/I_i) * (V_cutoff - V_s - I_i*R_eq);
        total_time = total_time + delta_t;
        V_s = V_cutoff - I_i*R_eq;
    end
end