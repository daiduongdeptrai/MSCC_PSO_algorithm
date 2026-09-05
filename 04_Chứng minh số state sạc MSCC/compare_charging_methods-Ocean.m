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
    
    % Tính toán cho MSCC (từ 2-20 stages)
    min_stages = 2;
    max_stages = 20;
    stage_counts = min_stages:max_stages;
    t_MSCC = zeros(size(stage_counts));
    
    for i = 1:length(stage_counts)
        n = stage_counts(i);
        I_pattern = generate_optimal_pattern(n, I_CC, I_min);
        t_MSCC(i) = calculate_MSCC_time(I_pattern, V_cutoff, V_initial, R_eq, C_eq);
    end
    
    % Hiển thị kết quả (bằng fprintf)
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
    
    % Vẽ đồ thị so sánh (với font Cambria & kích thước theo chuẩn IEEE)
    fig = figure('Color','w'); 
    hold on;
    % MSCC line (set DisplayName để legend tự lấy)
    h_mscc = plot(stage_counts, t_MSCC, '-o', 'LineWidth', 2, ...
                  'MarkerSize',6, 'DisplayName','MSCC');
    % CC-CV horizontal line (đưa vào legend bằng DisplayName)
    h_cccv = yline(t_CCCV, '--r', 'LineWidth', 2, 'DisplayName','CCCV');
    
    % Axis labels (IEEE-friendly sizes)
    xlabel('Số mức sạc MSCC', 'FontName','Cambria', 'FontSize', 10);
    ylabel('Thời gian sạc (s)', 'FontName','Cambria', 'FontSize', 10);
    % BỎ title theo yêu cầu (không gọi title)
    
    % Thiết lập font cho ticks và toàn trục (tick labels ~8 pt)
    ax = gca;
    ax.FontName = 'Cambria';
    ax.FontSize = 14;         % tick labels
    ax.LineWidth = 1.5;      % độ dày trục
    ax.Box = 'on';
    
    % Legend (đặt font Cambria nhỏ)
    lg = legend([h_mscc, h_cccv], 'Location','best');
    set(lg, 'FontName', 'Cambria', 'FontSize', 14);
    
    % Grid và tight layout
    grid on;
    hold off;
    
    % Nếu muốn xuất hình theo kích thước IEEE chuẩn (ví dụ 3.5 inch wide),
    % uncomment các dòng sau để set kích thước xuất ảnh khi saveas hoặc print:
    %
    % fig.Units = 'inches';
    % fig.Position = [1 1 3.5 2.1]; % [left bottom width height] (example)
    % set(gca, 'LooseInset', max(get(gca,'TightInset'), 0.02));
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
