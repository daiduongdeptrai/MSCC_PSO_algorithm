function cccv_charging_with_export
    % =============== THÔNG SỐ BAN ĐẦU ===============
    Icc = 1.31;                   % Dòng điện sạc ở chế độ dòng không đổi (A)
    U_cv = 4.2;                   % Điện áp sạc ở chế độ áp không đổi (V)
    I_cutoff = 0.05;               % Dòng điện ngưỡng cắt (A)
    Q0 = 1310 * 3.6;               % Dung lượng pin (Coulomb)
    h = 0.01;                      % Bước thời gian mô phỏng (s)
    t_max = 10000;                 % Thời gian mô phỏng tối đa (s)

    % =============== KHỞI TẠO DỮ LIỆU ===============
    N = t_max / h;                         
    t = 0:h:t_max;                         
    Ucp = zeros(1, length(t));             
    U_t_arr = zeros(1, length(t));         
    I_t_arr = zeros(1, length(t));         
    mode_arr = zeros(1, length(t));        
    SoC = zeros(1, length(t));             
    
    % =============== VÒNG LẶP MÔ PHỎNG ===============
    mode = 1; % 1 = CC, 2 = CV
    for k = 1:N
        % Thời gian
        t(k) = k * h;

        % Trạng thái SoC
        if k == 1
            SoC(k) = 0.2;
        else
            SoC(k) = SoC(k-1) + (I_t_arr(k-1) * h) / Q0;
        end

        % ======= Mô hình mới =======
        OCV = 49.6*SoC(k)^7 - 243*SoC(k)^6 + 482*SoC(k)^5 - 502*SoC(k)^4 + ...
              297*SoC(k)^3 - 99.9*SoC(k)^2 + 18.2*SoC(k) + 2.29;

        R0 = -22.2*SoC(k)^7 + 94.4*SoC(k)^6 - 166*SoC(k)^5 + 156*SoC(k)^4 + ...
             -83.9*SoC(k)^3 + 25.8*SoC(k)^2 - 4.2*SoC(k) + 0.29;

        Rp = -105*SoC(k)^7 + 445*SoC(k)^6 - 793*SoC(k)^5 + 768*SoC(k)^4 + ...
             -436*SoC(k)^3 + 145*SoC(k)^2 - 26*SoC(k) + 1.96;

        Cp = 3.48e7*SoC(k)^7 - 1.39e8*SoC(k)^6 + 2.3e8*SoC(k)^5 - 2.04e8*SoC(k)^4 + ...
             1.04e8*SoC(k)^3 - 3.06e7*SoC(k)^2 + 4.77e6*SoC(k) - 3e5;

        % ======= Chế độ sạc =======
        if mode == 1  % CC
            I_t_arr(k) = Icc;
            U_t_arr(k) = OCV + R0*I_t_arr(k) + Ucp(k);

            if U_t_arr(k) >= U_cv
                mode = 2;
                fprintf('Chuyển sang CV tại %.2f s, U = %.4f V, SoC = %.2f%%\n', ...
                    t(k), U_t_arr(k), SoC(k)*100);
            end
        else           % CV
            U_t_arr(k) = U_cv;
            I_t_arr(k) = (U_t_arr(k) - OCV - Ucp(k)) / R0;

            % Điều kiện dừng CV
            if I_t_arr(k) < I_cutoff || SoC(k) > 0.9
                fprintf('Kết thúc sạc tại %.2f s, I = %.4f A, SoC = %.2f%%\n', ...
                    t(k), I_t_arr(k), SoC(k)*100);
                break;
            end
        end

        % Điều kiện dừng nếu SoC > 90% ngay cả khi ở CC mode
        if SoC(k) > 0.9
            fprintf('Ngừng sạc vì SoC đạt %.2f%% tại %.2f s\n', SoC(k)*100, t(k));
            break;
        end

        mode_arr(k) = mode;

        % Cập nhật RC song song
        if k < N
            Ucp(k+1) = Ucp(k) + h * (-Ucp(k)/(Rp*Cp) + I_t_arr(k)/Cp);
        end
    end

    % =============== CẮT DỮ LIỆU ===============
    t = t(1:k);
    U_t_arr = U_t_arr(1:k);
    I_t_arr = I_t_arr(1:k);
    mode_arr = mode_arr(1:k);
    SoC = SoC(1:k);
    Capacity_mAh = SoC * (Q0/3.6);

    % =============== XUẤT EXCEL ===============
    data = table(t', U_t_arr', I_t_arr', mode_arr', SoC'*100, Capacity_mAh', ...
        'VariableNames', {'ThoiGian_s','DienAp_V','DongDien_A','CheDo','SoC_%','DungLuong_mAh'});
    writetable(data,'CCCV_Data.xlsx');
    fprintf('Đã xuất file CCCV_Data.xlsx\n');

    % =============== VẼ ĐỒ THỊ ===============
    figure;
    % Điện áp
    subplot(3,1,1);
    plot(t, U_t_arr, 'b','LineWidth',1.5); hold on;
    yline(U_cv,'--r','U_{cv}');
    xlabel('Thời gian (s)'); ylabel('Điện áp (V)');
    title('Biến thiên điện áp trong quá trình sạc CCCV'); grid on;

    % Dòng điện
    subplot(3,1,2);
    plot(t, I_t_arr, 'r','LineWidth',1.5); hold on;
    yline(Icc,'--b','I_{cc}');
    yline(I_cutoff,'--g','I_{cutoff}');
    xlabel('Thời gian (s)'); ylabel('Dòng điện (A)');
    title('Biến thiên dòng điện trong quá trình sạc CCCV'); grid on;

    % Dung lượng
    subplot(3,1,3);
    plot(t, Capacity_mAh, 'm','LineWidth',1.5);
    xlabel('Thời gian (s)'); ylabel('Dung lượng (mAh)');
    title('Biến thiên dung lượng trong quá trình sạc'); grid on;
end
