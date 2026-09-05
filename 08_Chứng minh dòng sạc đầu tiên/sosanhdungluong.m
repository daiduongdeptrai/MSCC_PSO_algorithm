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
    
    

    % Vẽ đồ thị Q theo SoC cho cả hai trường hợp
    figure(1);
    plot(SoC*100, Q/3.6, 'b-', 'LineWidth', 2); hold on;  % Q theo I_first (thường)
    plot(SoC*100, Q/3.6, 'r--', 'LineWidth', 2);     % Q theo I_first_const
    xlabel('Mức sạc ban đầu SoC (%)');
    ylabel('Dung lượng pin sau khi sạc (mAh)');
    title('So sánh dung lượng sạc');
    legend('Dung lượng sạc 1C', 'Dung lượng sạc tối ưu', 'Location', 'SouthEast');
    grid on;
    ylim([0, 3000]);
    
    % Hiển thị thông tin
    fprintf('=== Kết quả tính toán ===\n');
    fprintf('Dòng cuối cùng I_last: từ %.4f A đến %.4f A\n', min(I_last), max(I_last));
    fprintf('Hệ số q: từ %.4f đến %.4f\n', min(q), max(q));
    fprintf('Thời gian sạc: từ %.2f s đến %.2f s\n', min(T), max(T));
end