function Chungminhbangcapsonhan2()
    % Thông số pin từ bài báo
    V_cutoff = 4.22;       % Điện áp ngắt (V)
    OCV = 3.35;
    R_eq = 0.068;         % Điện trở tương đương (Ohm)
    C_eq = 11030;         % Điện dung tương đương (F)
    n_stages = 5;         % Số giai đoạn sạc
    I = 2.6;
    Q0 = I * 3600;
    
    % Tạo vector điện áp ban đầu từ 3.35V đến 4V
    V_initial = linspace(3.35, 4.1, 100);
    %V_initial = 4;

    % Tính toán các tham số
    SoC = (V_initial - OCV)*C_eq ./ Q0;  % Tính SoC từ V_initial
    
    % Tính I_last cho mỗi V_initial
    I_last = (V_cutoff - V_initial) / R_eq - Q0 * (1 - SoC) ./ (R_eq * C_eq);
    
    % Tính I_first cho mỗi V_initial
    I_first = nthroot(((V_cutoff - V_initial) / R_eq) .^ (n_stages - 1) .* I_last, n_stages);
    I_first_const = I * ones(size(V_initial));  % Tạo vector cùng kích thước

    % Tính q cho mỗi V_initial
    q = nthroot(I_last ./ I_first, 4);
    q_const = nthroot(I_last ./ I_first_const, 4);
    
    % Tính thời gian T
    T1 = (V_cutoff - V_initial) * C_eq ./ I_first_const + (4 ./ q_const - 5) * R_eq * C_eq;
    T2 = (V_cutoff - V_initial) * C_eq ./ I_first + (4 ./ q - 5) * R_eq * C_eq;
    Q = ((V_cutoff - V_initial) * C_eq - I_last * C_eq * R_eq);

    % Tạo figure với kích thước "dài ngang" (width > height)
    figure('Position', [100, 100, 1200, 400]); % [x, y, width, height]
    
    % Subplot 1: Đồ thị thời gian sạc (dài ngang)
    subplot(1, 2, 1);
    plot(SoC*100, T1, 'b-', 'LineWidth', 2, 'DisplayName', 'Thời gian sạc 1C');
    hold on;
    plot(SoC*100, T2, 'r--', 'LineWidth', 2, 'DisplayName', 'Thời gian sạc tối ưu');
    xlabel('Mức sạc ban đầu SoC (%)');
    ylabel('Thời gian sạc (s)');
    title('So sánh thời gian sạc', 'FontWeight', 'bold');
    grid on;
    legend('show', 'Location', 'northwest');
    ylim([min([T1(:); T2(:)])*0.95, max([T1(:); T2(:)])*1.05]);
    hold off;
    
    % Subplot 2: Đồ thị dòng điện sạc (dài ngang)
    subplot(1, 2, 2);
    plot(SoC*100, I_first_const, 'b-', 'LineWidth', 2, 'DisplayName', 'Dòng 1C (2.6A)');
    hold on;
    plot(SoC*100, I_first, 'r--', 'LineWidth', 2, 'DisplayName', 'Dòng tối ưu');
    xlabel('Mức sạc ban đầu SoC (%)');
    ylabel('Dòng điện sạc (A)');
    title('So sánh dòng điện sạc', 'FontWeight', 'bold');
    grid on;
    legend('show', 'Location', 'northwest');
    ylim([min([I_first(:); I_first_const(:)])*0.95, max([I_first(:); I_first_const(:)])*1.05]);
    hold off;

    % Hiển thị thông tin
    fprintf('=== Kết quả tính toán ===\n');
    fprintf('Thời gian sạc 1C (T1): từ %.2f s đến %.2f s\n', min(T1), max(T1));
    fprintf('Thời gian sạc tối ưu (T2): từ %.2f s đến %.2f s\n', min(T2), max(T2));
    fprintf('Dòng sạc tối ưu: từ %.2f A đến %.2f A\n', min(I_first), max(I_first));
    fprintf('Chênh lệch thời gian trung bình: %.2f s\n', mean(T1 - T2));
    fprintf('Thời gian sạc: %.2f s\n', T1);
    fprintf('Dung lượng cần sạc: %.2f J\n', Q/3.6);
end