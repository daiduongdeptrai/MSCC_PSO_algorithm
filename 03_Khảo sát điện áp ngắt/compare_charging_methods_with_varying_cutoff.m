function compare_charging_methods_with_varying_cutoff()
    % Thông số pin từ bài báo
    V_cutoffs = 4.20:0.01:4.25; % Các giá trị điện áp ngắt (V)
    V_initial = 3.35;            % Điện áp ban đầu (V)
    R_eq = 0.068;                % Điện trở tương đương (Ohm)
    C_eq = 11030;                % Điện dung tương đương (F)
    I_CC = 2.6;                  % Dòng sạc CC (A)
    I_min = 0.05;                % Dòng ngắt (A)
    n_stages = 5;                % Số stage sạc MSCC
    
    % Khởi tạo các mảng kết quả
    num_cutoffs = length(V_cutoffs);
    t_CCCV = zeros(1, num_cutoffs);
    t_MSCC = zeros(1, num_cutoffs);
    percent_diff = zeros(1, num_cutoffs);
    
    % Tính toán cho từng giá trị V_cutoff
    for i = 1:num_cutoffs
        V_cutoff = V_cutoffs(i);
        
        % Tính thời gian CC-CV
        [~, ~, t_CCCV(i)] = calculate_CCCV_time(I_CC, 4.22, V_initial, R_eq, C_eq, I_min);
        
        % Tính thời gian MSCC với 5 stage
        I_pattern = generate_optimal_pattern(n_stages, I_CC, I_min);
        t_MSCC(i) = calculate_MSCC_time(I_pattern, V_cutoff, V_initial, R_eq, C_eq);
        
        % Tính phần trăm chênh lệch
        percent_diff(i) = (t_MSCC(i)-t_CCCV(i)) / t_CCCV(i) * 100;
    end
    
    % Hiển thị kết quả
    fprintf('=== Kết quả so sánh thời gian sạc ===\n');
    fprintf('%-8s %-12s %-12s %-15s\n', 'V_cutoff', 'CC-CV (s)', 'MSCC (s)', 'Chênh lệch (%)');
    for i = 1:num_cutoffs
        fprintf('%-8.2f %-12.2f %-12.2f %-15.2f\n', ...
                V_cutoffs(i), t_CCCV(i), t_MSCC(i), percent_diff(i));
    end
    
    % Vẽ đồ thị so sánh
    figure;
    
    % Đồ thị 1: Thời gian sạc
    subplot(2,1,1);
    plot(V_cutoffs, t_CCCV, '-o', 'LineWidth', 2, 'DisplayName', 'CC-CV'); hold on;
    plot(V_cutoffs, t_MSCC, '-s', 'LineWidth', 2, 'DisplayName', 'MSCC 5-stage');
    xlabel('Điện áp ngắt (V)');
    ylabel('Thời gian sạc (s)');
    title('So sánh thời gian sạc CC-CV và MSCC (5 stage)');
    legend('Location', 'best');
    grid on;
    
    % Đồ thị 2: Phần trăm chênh lệch
    subplot(2,1,2);
    bar(V_cutoffs, percent_diff);
    xlabel('Điện áp ngắt (V)');
    ylabel('Chênh lệch (%)');
    title('Phần trăm chênh lệch thời gian sạc (CC-CV so với MSCC)');
    grid on;
    
    % Hiển thị giá trị trên các cột
    for i = 1:num_cutoffs
        text(V_cutoffs(i), percent_diff(i), sprintf('%.2f%%', percent_diff(i)), ...
             'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
    end
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
    if n == 1
        I_pattern = I_first;
    elseif n == 2
        I_pattern = [I_first, I_last];
    else
        % Phân bố dòng sạc theo cấp số nhân
        I_pattern = exp(linspace(log(I_first), log(I_last), n));
    end
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