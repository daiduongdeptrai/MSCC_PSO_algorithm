function Chungminhbangcapsonhan()
    % Thông số pin từ bài báo
    V_cutoff = 4.22;       % Điện áp ngắt (V) - Bài báo sử dụng 4.22V
    V_initial = 3.35;      % Điện áp ban đầu (V) - Giá trị từ bài báo
    R_eq = 0.068;          % Điện trở tương đương (Ohm) - Bài báo
    C_eq = 11030;          % Điện dung tương đương (F) - Bài báo
    I_first = 2.6;         % Dòng sạc giai đoạn đầu (A) - 1C rate từ bài báo
    n_stages = 5;          % Số giai đoạn sạc - Bài báo dùng 5 giai đoạn
    Q0 = 2.6*3600;
    I_last = (V_cutoff-V_initial)/R_eq - Q0/(R_eq*C_eq);         % Dòng sạc giai đoạn cuối (A) - Tính từ công thức (11)
    q = nthroot(I_last/I_first, 4);


    % Tính toán pattern dòng sạc tối ưu theo công thức (16)-(19)
    I_pattern = calculate_optimal_pattern(I_first, I_last, n_stages);
    
    % Tính thời gian sạc và dung lượng sạc
    total_time =  (V_cutoff-V_initial)*C_eq/I_first + (4/q - 5)*R_eq*C_eq;
    
    % Hiển thị kết quả
    fprintf('=== Kết quả sạc MSCC (%d giai đoạn) ===\n', n_stages);
    fprintf('Pattern dòng sạc: [%.2fA, %.2fA, %.2fA, %.2fA, %.2fA]\n', I_pattern);
    fprintf('Thời gian sạc: %.2f giây\n', total_time);
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
