function simulate_charge_test

    % ================= THÔNG SỐ BAN ĐẦU =================
    U_cutoff = 4.2;
    Q0 = 2000 * 3.6;            % Dung lượng danh định (C)
    h = 0.01;
    t_max = 10000;
    I3_values = linspace(0.1, 2, 30); % Giảm số điểm để chạy nhanh hơn (20 điểm từ 0 đến 5A)
    
    % Khởi tạo mảng lưu thời gian sạc
    charge_times = zeros(size(I3_values));
    
    % Lặp qua từng giá trị I3
    for i = 1:length(I3_values)
        I3 = I3_values(i);
        
        % Tạo I_pattern với I3 hiện tại
        I_pattern = [2.6, 2, I3, 0.8, 0.4];
        
        % ================= KHỞI TẠO DỮ LIỆU =================
        N = t_max / h;
        Qk = 0;
        Ucpk = 0;
        state = 1;
        time = 0;
        
        for k = 1:N
            tk = k * h;
            Ik = I_pattern(state);
            
            % Tính Qk (Coulomb)
            Qk = Qk + Ik * h;
            
            % Tính SoC
            SoCk = Qk / Q0;
            
            % Tính các thông số tương ứng
            OCVk = 2.896 + 9.563*SoCk - 57.92*SoCk^2 + 188.2*SoCk^3 ...
                 - 340.7*SoCk^4 + 347.5*SoCk^5 - 184.2*SoCk^6 + 38.95*SoCk^7;
            
            R0k = 0.039 - 0.131*SoCk + 0.507*SoCk^2 - 1.129*SoCk^3 ...
                + 1.679*SoCk^4 - 1.764*SoCk^5 + 1.157*SoCk^6 - 0.331*SoCk^7;
            
            Rpk = 0.048 - 0.318*SoCk + 2.075*SoCk^2 - 9.171*SoCk^3 ...
                 + 23.41*SoCk^4 - 31.96*SoCk^5 + 21.71*SoCk^6 - 5.78*SoCk^7;
            
            Cpk = 104.9 - 311.3*SoCk + 277.9*SoCk^2 - 2.435*SoCk^3 ...
                 - 111.4*SoCk^4 + 44.86*SoCk^5 - 1.53*SoCk^6 + 0.108*SoCk^7;
            
            % RC song song
            Ucpk = Ucpk + h * (-Ucpk / (Rpk * Cpk) + Ik / Cpk);
            
            % Điện áp pin
            U_tk = OCVk + R0k * Ik + Ucpk;
            
            % MSCC logic
            if U_tk >= U_cutoff
                state = state + 1;
            end
            
            if state > 5
                time = tk;
                break;
            end
        end
        
        % Lưu thời gian sạc
        charge_times(i) = time;
    end
    
    % ================= VẼ ĐỒ THỊ =================
    figure(1);
    plot(I3_values, charge_times, 'b-o', 'LineWidth', 2, 'MarkerFaceColor', 'b');
    xlabel('Dòng điện I3 (A)');
    ylabel('Thời gian sạc (s)');
    title('Thời gian sạc theo dòng điện I3');
    grid on;
    

    % ================= TÌM VÀ ĐÁNH DẤU GIÁ TRỊ MIN =================
    [min_time, min_idx] = min(charge_times);
    min_I3 = I3_values(min_idx);
    
    % Đánh dấu điểm min trên đồ thị
    hold on;
    plot(min_I3, min_time, 'ro', 'MarkerSize', 10, 'LineWidth', 2);
    text(min_I3, min_time, sprintf('Min: %.2f s tại %.2f A', min_time, min_I3), ...
    'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', ...
    'FontWeight', 'bold', 'Color', 'red');
    
    % Thêm chú thích
    legend('Thời gian sạc', 'Điểm min', 'Location', 'best');
    hold off;

end