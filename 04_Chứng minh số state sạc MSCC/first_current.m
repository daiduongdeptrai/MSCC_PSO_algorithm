function MSCC_charging_analysis()
    % Thông số pin từ bài báo
    V_cutoff = 4.22;       % Điện áp ngắt (V) - Bài báo sử dụng 4.22V
    V_initial = 3.35;      % Điện áp ban đầu (V) - Giá trị từ bài báo
    R_eq = 0.068;          % Điện trở tương đương (Ohm) - Bài báo
    C_eq = 11030;          % Điện dung tương đương (F) - Bài báo
    I_first = 2.6;         % Dòng sạc giai đoạn đầu (A) - 1C rate từ bài báo
    n_stages = 5;          % Số giai đoạn sạc - Bài báo dùng 5 giai đoạn
    Q0 = V_cutoff*C_eq;
    SoC_t = 0.8;
    Q_t = SoC_t*Q0;
    I_last = (V_cutoff-(V_cutoff-I_first*R_eq))/R_eq - Q_t/(R_eq*C_eq);         % Dòng sạc giai đoạn cuối (A) - Tính từ công thức (11)

    % Tính toán pattern dòng sạc tối ưu theo công thức (16)-(19)
    I_pattern = calculate_optimal_pattern(I_first, I_last, n_stages);
    
    % Tính thời gian sạc và dung lượng sạc
    [total_time, total_capacity] = calculate_MSCC_performance(I_pattern, V_cutoff, V_initial, R_eq, C_eq);
    
    % Hiển thị kết quả
    fprintf('=== Kết quả sạc MSCC (%d giai đoạn) ===\n', n_stages);
    fprintf('Pattern dòng sạc: [%.2fA, %.2fA, %.2fA, %.2fA, %.2fA]\n', I_pattern);
    fprintf('Thời gian sạc: %.2f giây\n', total_time);
    fprintf('Dung lượng sạc: %.2f mAh\n', total_capacity/3.6); % Chuyển từ Coulomb sang Ah
    fprintf('Trạng thái sạc: %.2f %%\n', total_capacity/Q0*100); % Chuyển từ Coulomb sang A
end

%% Hàm tính pattern dòng sạc tối ưu theo công thức (16)-(19)
function I_pattern = calculate_optimal_pattern(I1, I5, n_stages)
    if n_stages ~= 5
        error('Hiện chỉ hỗ trợ 5 giai đoạn sạc');
    end
    
    % Tính các dòng sạc trung gian theo công thức trong bài báo
    I3 = sqrt(I1 * I5);    % Công thức (19)
    I2 = sqrt(I1 * I3);    % Công thức (17)
    I4 = sqrt(I3 * I5);    % Công thức (18)
    
    I_pattern = [I1, I2, I3, I4, I5];
end

%% Hàm tính thời gian và dung lượng sạc MSCC theo công thức (5)-(9)
function [total_time, total_capacity] = calculate_MSCC_performance(I_pattern, V_cutoff, V_initial, R_eq, C_eq)
    total_time = 0;
    total_capacity = 0;
    V_s = V_initial;
    
    for i = 1:length(I_pattern)
        I_i = I_pattern(i);
        
        % Tính thời gian cho từng giai đoạn - Công thức (6)
        delta_t = (C_eq/I_i) * (V_cutoff - V_s - I_i*R_eq);
        total_time = total_time + delta_t;
        
        % Tính dung lượng cho từng giai đoạn - Công thức (8)
        delta_Ah = delta_t*I_i;
        total_capacity = total_capacity + delta_Ah;
        
        % Cập nhật điện áp ban đầu cho giai đoạn tiếp theo - Công thức (7)
        V_s = V_cutoff - I_i*R_eq;
    end
end