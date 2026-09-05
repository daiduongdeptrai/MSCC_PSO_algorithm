function caculateCCCV
    % ================= THÔNG SỐ BAN ĐẦU =================
    I_cutoff = 0.1;     % A
    U_cutoff = 4.2;     % V
    I_cc = 1.25;        % A
    Q0 = 1310 * 3.6;    % Dung lượng danh định (Coulomb)
    h = 0.01;           % Bước thời gian (s)
    t_max = 10000;      % Thời gian mô phỏng tối đa (s)

    % ================= KHỞI TẠO DỮ LIỆU =================
    N = t_max / h;
    SoC_initial = 0.2;
    Qk_1 = SoC_initial * Q0;
    Ucpk = 0;
    Ucpk_1 = 0;
    Ik = I_cc;

    % Mảng lưu dữ liệu để vẽ
    time_arr = zeros(1, N);
    voltage_arr = zeros(1, N);
    current_arr = zeros(1, N);
    capacity_arr = zeros(1, N);

    % ================= VÒNG LẶP MÔ PHỎNG =================
    for k = 1:N
        tk = k * h;

        % Tính Qk (Coulomb)
        Qk = Qk_1 + Ik * h;

        % Tính SoC
        SoCk = Qk / Q0;

        % ======= Tham số từ mô hình mới =======
        % OCV giữ nguyên
        OCVk = 49.6*SoCk^7 - 243*SoCk^6 + 482*SoCk^5 - 502*SoCk^4 ...
             + 297*SoCk^3 - 99.9*SoCk^2 + 18.2*SoCk + 2.29;

        % R0 mới
        R0k = -26.3*SoCk^7 + 110*SoCk^6 - 190*SoCk^5 + 177*SoCk^4 ...
            - 94.1*SoCk^3 + 28.7*SoCk^2 - 4.63*SoCk + 0.317;

        % Rp mới
        Rpk = -113*SoCk^7 + 476*SoCk^6 - 842*SoCk^5 + 810*SoCk^4 ...
            - 456*SoCk^3 + 150*SoCk^2 - 26.8*SoCk + 2.01;

        % Cp mới
        Cpk = 1.36e7*SoCk^7 - 5.74e7*SoCk^6 + 1e8*SoCk^5 - 9.37e7*SoCk^4 ...
            + 5.02e7*SoCk^3 - 1.54e7*SoCk^2 + 2.48e6*SoCk - 1.61e5;

        % RC song song
        Ucpk = Ucpk_1 + h * (-Ucpk / (Rpk * Cpk) + Ik / Cpk);

        % Điện áp pin
        U_tk = OCVk + R0k * Ik + Ucpk;

        % Cập nhật giá trị cho lần lặp tiếp theo
        Qk_1 = Qk;
        Ucpk_1 = Ucpk;

        % Chế độ CV
        if U_tk >= U_cutoff
            U_tk = U_cutoff;
            Ik = (U_tk - OCVk - Ucpk_1) / R0k;
        else
            Ik = I_cc;
        end

        % Lưu dữ liệu
        time_arr(k) = tk;
        voltage_arr(k) = U_tk;
        current_arr(k) = Ik;
        capacity_arr(k) = SoCk * 100;  % %

        % Điều kiện dừng
        if (Ik <= I_cutoff) || (SoCk >= 1)
            time_arr = time_arr(1:k);
            voltage_arr = voltage_arr(1:k);
            current_arr = current_arr(1:k);
            capacity_arr = capacity_arr(1:k);
            break;
        end
    end

    % ================= VẼ ĐỒ THỊ =================
    figure;
    subplot(3,1,1);
    plot(time_arr, voltage_arr, 'LineWidth', 1.5);
    xlabel('Thời gian (s)'); ylabel('Điện áp (V)');
    title('Điện áp theo thời gian');
    grid on; ylim([3.5 4.22]);

    subplot(3,1,2);
    plot(time_arr, current_arr, 'LineWidth', 1.5);
    xlabel('Thời gian (s)'); ylabel('Dòng (A)');
    title('Dòng điện theo thời gian');
    grid on; ylim([0 2]);

    subplot(3,1,3);
    plot(time_arr, capacity_arr, 'LineWidth', 1.5);
    xlabel('Thời gian (s)'); ylabel('SoC (%)');
    title('SoC theo thời gian');
    grid on;
end
