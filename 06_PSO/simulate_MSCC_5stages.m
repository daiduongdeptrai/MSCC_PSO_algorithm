function simulate_MSCC_5stages
    % Thông số pin từ bài báo
    V_cutoff = 4.22;       % Điện áp ngắt (V)
    V_initial = 3.35;      % Điện áp ban đầu (V)
    R_eq = 0.068;          % Điện trở tương đương (Ohm)
    C_eq = 11030;          % Điện dung tương đương (F)
    I_CC = 2.6;            % Dòng sạc CC (A)
    I_min = 0.05;          % Dòng ngắt (A)
    
    % Tạo pattern dòng sạc cho 5 stage
    n_stages = 5;
    I_pattern = generate_optimal_pattern(n_stages, I_CC, I_min);
    
    % Mô phỏng chi tiết từng giai đoạn
    [time_points, voltage_points, current_points] = simulate_MSCC_stages(I_pattern, V_cutoff, V_initial, R_eq, C_eq);
    
    % Hiển thị kết quả
    fprintf('=== Mô phỏng MSCC 5 stage ===\n');
    fprintf('Dòng sạc các stage: [');
    fprintf('%.2f ', I_pattern);
    fprintf('] A\n');
    
    total_time = time_points(end);
    fprintf('Tổng thời gian sạc: %.2f s (≈%.2f phút)\n\n', total_time, total_time/60);
    
    % Vẽ đồ thị
    figure;
    
    % Subplot 1: Điện áp
    subplot(2,1,1);
    plot(time_points, voltage_points, 'b-', 'LineWidth', 2);
    hold on;
    yline(V_cutoff, 'r--', 'V_{cutoff}', 'LineWidth', 1.5);
    xlabel('Thời gian (s)');
    ylabel('Điện áp (V)');
    title('Điện áp pin trong quá trình sạc MSCC 5 stage');
    grid on;
    
end

%% Hàm mô phỏng chi tiết từng stage sạc
function [time_points, voltage_points, current_points] = simulate_MSCC_stages(I_pattern, V_cutoff, V_initial, R_eq, C_eq)
    time_points = 0;
    voltage_points = V_initial;
    current_points = [];
    
    V_s = V_initial;
    total_time = 0;
    
    for i = 1:length(I_pattern)
        I_i = I_pattern(i);
        delta_t = (C_eq/I_i) * (V_cutoff - V_s - I_i*R_eq);
        
        % Tạo các điểm thời gian trong giai đoạn này
        t_stage = linspace(0, delta_t, 50) + total_time;
        V_stage = V_s + (I_i/C_eq)*t_stage + I_i*R_eq*(1-exp(-t_stage/(R_eq*C_eq)));
        
        % Lưu dữ liệu
        time_points = [time_points t_stage(2:end)];
        voltage_points = [voltage_points V_stage(2:end)];
        current_points = [current_points repmat(I_i, 1, length(t_stage))];
        
        % Cập nhật cho giai đoạn tiếp theo
        total_time = total_time + delta_t;
        V_s = V_cutoff - I_i*R_eq;
    end
    
    % Thêm điểm cuối cùng
    current_points = [current_points current_points(end)];
end

%% Hàm tạo pattern dòng sạc tối ưu cho MSCC (giữ nguyên từ code gốc)
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