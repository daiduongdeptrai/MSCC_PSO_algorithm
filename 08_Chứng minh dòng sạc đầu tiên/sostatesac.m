function Chungminhbangcapsonhan2()
    % Thông số pin từ bài báo
    V_cutoff = 4.22;       % Điện áp ngắt (V)
    OCV = 3.35;
    R_eq = 0.068;         % Điện trở tương đương (Ohm)
    C_eq = 11030;         % Điện dung tương đương (F)
    Q0 = 2.6 * 3600;      % Dung lượng pin (Coulomb)
    V_initial = 3.35;     % Điện áp ban đầu
    
    % Tạo vector số giai đoạn sạc từ 2 đến 10
    n_stages_range = 2:50;
    
    % Tính toán các tham số cơ bản
    SoC = (V_initial - OCV) / (V_cutoff - OCV);
    I_last = (V_cutoff - V_initial) / R_eq - Q0 * (1 - SoC) / (R_eq * C_eq);
    I_first_const = 2.6;  % Dòng sạc 1C cố định
    
    % Khởi tạo các vector kết quả
    T_results = zeros(size(n_stages_range));
    Q_results = zeros(size(n_stages_range));
    
    % Tính toán cho từng số giai đoạn sạc
    for i = 1:length(n_stages_range)
        n_stages = n_stages_range(i);
        
        % Tính q
        q_const = nthroot(I_last / I_first_const, n_stages-1);
        
        % Tính thời gian sạc T
        T_results(i) = (V_cutoff - V_initial) * C_eq / I_first_const + ...
                      ((n_stages-1)/q_const - n_stages) * R_eq * C_eq;
        
        % Tính dung lượng Q
        Q_results(i) = ((V_cutoff - V_initial) * C_eq - I_last * C_eq * R_eq) + Q0 * SoC;
    end
    
    % Vẽ đồ thị 1: Thời gian sạc T theo số giai đoạn
    figure(1);
    plot(n_stages_range, T_results, 'b-o', 'LineWidth', 2, 'MarkerFaceColor', 'b');
    xlabel('Số giai đoạn sạc n_{stages}');
    ylabel('Thời gian sạc T (s)');
    title('Thời gian sạc theo số giai đoạn');
    grid on;
    
    % Vẽ đồ thị 2: Dung lượng Q theo số giai đoạn
    figure(2);
    plot(n_stages_range, Q_results/3600, 'r-s', 'LineWidth', 2, 'MarkerFaceColor', 'r'); % Chuyển sang đơn vị Ah
    xlabel('Số giai đoạn sạc n_{stages}');
    ylabel('Dung lượng Q (Ah)');
    title('Dung lượng sạc theo số giai đoạn');
    grid on;
    
    % Hiển thị thông tin
    fprintf('=== Kết quả tính toán ===\n');
    fprintf('Thời gian sạc trung bình: %.2f s\n', mean(T_results));
    fprintf('Dung lượng trung bình: %.2f Ah\n', mean(Q_results/3600));
    fprintf('Số giai đoạn tối ưu cho thời gian sạc ngắn nhất: %d\n', ...
            n_stages_range(T_results == min(T_results)));
end