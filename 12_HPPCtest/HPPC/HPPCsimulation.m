function charge_discharge_cycle
    % ================= THÔNG SỐ BAN ĐẦU =================
    I_pos   =  1.31;       % A (sạc dương 20s)
    I_neg   = -1.31;       % A (sạc âm 6 phút)
    t_pos   = 20;          % thời gian sạc dương (s)
    t_rest1 = 360;         % nghỉ sau sạc dương (s)
    t_neg   = 360;         % thời gian sạc âm (s)
    t_rest2 = 1200;        % nghỉ sau sạc âm (s)
    h = 0.1;               % bước thời gian (s)
    t_max = 100000;        % thời gian mô phỏng tối đa (s)

    Q0 = 1310 * 3.6;       % Dung lượng danh định (Coulomb)
    SoC_initial = 1;       % SOC ban đầu (100%)
    Qk_1 = SoC_initial * Q0;
    Ucpk = 0;
    Ucpk_1 = 0;

    % ================= KHỞI TẠO LƯU DỮ LIỆU =================
    N = round(t_max / h);
    time_arr    = zeros(1,N);
    voltage_arr = zeros(1,N);
    current_arr = zeros(1,N);
    soc_arr     = zeros(1,N);

    idx = 0;
    rest1_cnt = 0;   % Đếm số lần nghỉ sau sạc dương

    % ================= VÒNG LẶP =================
    cycle_period = t_pos + t_rest1 + t_neg + t_rest2;

    for k = 1:N
        tk = k * h;

        % Xác định trạng thái trong chu kỳ
        t_mod = mod(tk, cycle_period);

        if t_mod <= t_pos
            Ik = I_pos;          % sạc dương
        elseif t_mod <= t_pos + t_rest1
            Ik = 0;              % nghỉ sau sạc dương
            % Nếu vừa kết thúc thời gian nghỉ sau sạc dương
            if abs(t_mod - (t_pos + t_rest1)) < h/2  
                rest1_cnt = rest1_cnt + 1;
            end
        elseif t_mod <= t_pos + t_rest1 + t_neg
            Ik = I_neg;          % sạc âm
        else
            Ik = 0;              % nghỉ sau sạc âm
        end

        % Cập nhật điện lượng
        Qk = Qk_1 + Ik * h;
        SoCk = Qk / Q0;

        % ======= OCV (đa thức) =======
        OCVk = 49.6031746026527*SoCk^7 - 242.777777775253*SoCk^6 ...
            + 482.05555555048*SoCk^5 - 502.20085469538*SoCk^4 ...
            + 296.925106834202*SoCk^3 - 99.8582591285466*SoCk^2 ...
            + 18.1649483181218*SoCk + 2.28813333335013;

        % ======= Rp (đa thức) =======
        Rpk = -112.726962371923*SoCk^7 + 475.810770564809*SoCk^6 ...
            - 842.118461485493*SoCk^5 + 809.705712605166*SoCk^4 ...
            - 456.246715585319*SoCk^3 + 150.407513926122*SoCk^2 ...
            - 26.8229600075181*SoCk + 2.0116277956127;

        % ======= Cp (đa thức) =======
        Cpk = 13569519.4166804*SoCk^7 - 57373648.2503943*SoCk^6 ...
            + 100336200.459551*SoCk^5 - 93667153.1337912*SoCk^4 ...
            + 50177303.8499047*SoCk^3 - 15362475.1852854*SoCk^2 ...
            + 2483348.92753031*SoCk - 161291.986997882;

        % ======= R0 (đa thức) =======
        R0k = -26.2660619799801*SoCk^7 + 109.918871250544*SoCk^6 ...
            - 190.459259256136*SoCk^5 + 176.52916835934*SoCk^4 ...
            - 94.135374438522*SoCk^3 + 28.7364437013528*SoCk^2 ...
            - 4.63111345743667*SoCk + 0.316849947081998;

        % ======= Cập nhật trạng thái mạch RC =======
        Ucpk = Ucpk_1 + h * (-Ucpk / (Rpk * Cpk) + Ik / Cpk);

        % ======= Điện áp đầu cực =======
        U_tk = OCVk + R0k*Ik + Ucpk;

        % Cập nhật cho vòng sau
        Qk_1 = Qk;
        Ucpk_1 = Ucpk;

        % Lưu dữ liệu
        idx = idx + 1;
        time_arr(idx)    = tk;
        voltage_arr(idx) = U_tk;
        current_arr(idx) = Ik;
        soc_arr(idx)     = SoCk * 100;

        % === Điều kiện dừng sau khi kết thúc nghỉ sau sạc dương lần 9 ===
        if rest1_cnt >= 9
            break;
        end
    end

    % Cắt mảng dư
    time_arr    = time_arr(1:idx);
    voltage_arr = voltage_arr(1:idx);
    current_arr = current_arr(1:idx);
    soc_arr     = soc_arr(1:idx);

    % ================= VẼ ĐỒ THỊ =================
    figure(1);
    plot(time_arr, current_arr, 'LineWidth',1.5);
    xlabel('Thời gian (s)'); ylabel('Dòng (A)');
    title('Dòng điện theo thời gian');
    grid on;
    hold on

    figure(2);
    plot(time_arr, voltage_arr, 'b', 'LineWidth',1.5);
    xlabel('Thời gian (s)'); ylabel('Điện áp (V)');
    title('Điện áp trong chu trình HPPC');
    grid on;

    disp('--- Mô phỏng hoàn tất ---');
end
