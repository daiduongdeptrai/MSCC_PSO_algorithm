function cccv_charging_with_export
    % =============== THÔNG SỐ BAN ĐẦU ===============
    Icc = 2;                   % Dòng điện sạc ở chế độ dòng không đổi (A)
    U_cv = 4.2;                % Điện áp sạc ở chế độ áp không đổi (V)
    I_cutoff = 0.05;           % Dòng điện ngưỡng cắt (A)
    Q0 = 2000 * 3.6;           % Dung lượng pin (Coulomb) = 2000mAh
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
            SoC(k) = 0;
        else
            SoC(k) = SoC(k-1) + (I_t_arr(k-1) * h) / Q0;
        end

        % Tính thông số theo SoC(k)
        OCV = 2.896 + 9.563*SoC(k) - 57.92*SoC(k)^2 + 188.2*SoC(k)^3 ...
            - 340.7*SoC(k)^4 + 347.5*SoC(k)^5 - 184.2*SoC(k)^6 + 38.95*SoC(k)^7;

        R0 = 0.039 - 0.131*SoC(k) + 0.507*SoC(k)^2 - 1.129*SoC(k)^3 ...
            + 1.679*SoC(k)^4 - 1.764*SoC(k)^5 + 1.157*SoC(k)^6 - 0.331*SoC(k)^7;

        Rp = 0.048 - 0.318*SoC(k) + 2.075*SoC(k)^2 - 9.171*SoC(k)^3 ...
            + 23.41*SoC(k)^4 - 31.96*SoC(k)^5 + 21.71*SoC(k)^6 - 5.78*SoC(k)^7;

        Cp = 104.9 - 311.3*SoC(k) + 277.9*SoC(k)^2 - 2.435*SoC(k)^3 ...
            - 111.4*SoC(k)^4 + 44.86*SoC(k)^5 - 1.53*SoC(k)^6 + 0.108*SoC(k)^7;

        % Chế độ sạc
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
                k_end = k;
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
    t = t(1:k_end);
    U_t_arr = U_t_arr(1:k_end);
    I_t_arr = I_t_arr(1:k_end);
    mode_arr = mode_arr(1:k_end);
    SoC = SoC(1:k_end);
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
