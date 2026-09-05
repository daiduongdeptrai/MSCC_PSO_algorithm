function Chungminhbangcapsonhan2()
    % Thông số pin từ bài báo
    V_cutoff = 4.22;       % Điện áp ngắt (V)
    OCV = 3.35;
    R_eq = 0.068;         % Điện trở tương đương (Ohm)
    C_eq = 11030;         % Điện dung tương đương (F)
    n_stages = 5;         % Số giai đoạn sạc
    Q0 = 2.6 * 3600;
    
    % Tạo vector điện áp ban đầu từ 3.35V đến 4V
    V_initial = linspace(3.35, 4, 100);
    
    % Tính toán các tham số
    SoC = (V_initial - OCV)*C_eq ./ Q0;  % Tính SoC từ V_initial
    
    % Tính I_last cho mỗi V_initial
    I_last = (V_cutoff - V_initial) / R_eq - Q0 * (1 - SoC) ./ (R_eq * C_eq);
    

    % Tính I_first cho mỗi V_initial
    I_first = nthroot(((V_cutoff - V_initial) / R_eq) .^ (n_stages - 1) .* I_last, n_stages);
    I_first_const = 2.6 * ones(size(V_initial));

    % Tính q cho mỗi V_initial
    q = nthroot(I_last ./ I_first, 4);
    
    % Tính thời gian T và dung lượng Q
    T = (V_cutoff - V_initial) * C_eq ./ I_first + (4 ./ q - 5) * R_eq * C_eq;
    Q = ((V_cutoff - V_initial) * C_eq - I_last * C_eq * R_eq) + Q0 * SoC;
    
    
    % Tạo figure với 4 ô đồ thị (2x2)
    figure;
    
    % Ô 1: Đồ thị Thời gian T
    subplot(2, 2, 1);
    plot(V_initial, T, 'b-', 'LineWidth', 2);
    xlabel('Điện áp ban đầu V_{initial} (V)');
    ylabel('Thời gian T (s)');
    title('(a) Thời gian sạc T');
    grid on;
    
    % Ô 2: Đồ thị Dòng điện I_first
    subplot(2, 2, 2);
    plot(V_initial, I_first, 'r--', 'LineWidth', 2);
    xlabel('Điện áp ban đầu V_{initial} (V)');
    ylabel('Dòng điện I_{first} (A)');
    title('(b) Dòng điện sạc ban đầu');
    grid on;
    
    % Ô 3: Đồ thị Dung lượng Q
    subplot(2, 2, 3);
    plot(V_initial, Q/3.6, 'g-', 'LineWidth', 2);
    xlabel('Điện áp ban đầu V_{initial} (V)');
    ylabel('Dung lượng Q (C)');
    title('(c) Dung lượng pin');
    grid on;
    
    % Ô 4: Trống hoặc ghi chú (tùy chọn)
    subplot(2, 2, 4);
    axis off; % Tắt trục
    text(0.1, 0.5, sprintf('Thông số:\nV_{cutoff} = %.2f V\nR_{eq} = %.3f Ω\nC_{eq} = %d F', V_cutoff, R_eq, C_eq), ...
        'FontSize', 10, 'Interpreter', 'tex');
    
    % Hiển thị thông tin
    fprintf('=== Kết quả tính toán ===\n');
    fprintf('Dòng cuối cùng I_last: từ %.4f A đến %.4f A\n', min(I_last), max(I_last));
    fprintf('Hệ số q: từ %.4f đến %.4f\n', min(q), max(q));
    fprintf('Thời gian sạc: từ %.2f s đến %.2f s\n', min(T), max(T));
end