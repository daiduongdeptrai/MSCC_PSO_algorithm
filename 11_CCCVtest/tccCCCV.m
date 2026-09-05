function cccv_charging_with_export
    % =============== THÔNG SỐ BAN ĐẦU ===============
    Icc = 1.31;                   % Dòng điện sạc ở chế độ dòng không đổi (A)
    U_cv = 4.2;                % Điện áp sạc ở chế độ áp không đổi (V)
    I_cutoff = 0.05;           % Dòng điện ngưỡng cắt (A)
    Q0 = 1310 * 3.6;           % Dung lượng pin (Coulomb) = 2000mAh
    h = 0.01;                  % Bước thời gian mô phỏng (s)
    t_max = 10000;             % Thời gian mô phỏng tối đa (s)

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
        % Sử dụng thông số mới
        R0 = -25.3*SoC(k)^7 + 106*SoC(k)^6 - 185*SoC(k)^5 + 172*SoC(k)^4 + ...
             -91.8*SoC(k)^3 + 28.1*SoC(k)^2 - 4.53*SoC(k) + 0.311;

        Rp = -101*SoC(k)^7 + 431*SoC(k)^6 - 771*SoC(k)^5 + 749*SoC(k)^4 + ...
             -426*SoC(k)^3 + 142*SoC(k)^2 - 25.6*SoC(k) + 1.94;

        Cp = 1.43e7*SoC(k)^7 - 6.02e7*SoC(k)^6 + 1.05e8*SoC(k)^5 - 9.75e7*SoC(k)^4 + ...
             5.2e7*SoC(k)^3 - 1.59e7*SoC(k)^2 + 2.56e6*SoC(k) - 1.66e5;

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

            if I_t_arr(k) < I_cutoff
                fprintf('Kết thúc sạc tại %.2f s, I = %.4f A, SoC = %.2f%%\n', ...
                    t(k), I_t_arr(k), SoC(k)*100);
                break;
            end
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
    plot(t, SoC, 'm','LineWidth',1.5);
    xlabel('Thời gian (s)'); ylabel('Dung lượng (mAh)');
    title('Biến thiên dung lượng trong quá trình sạc'); grid on;
end
