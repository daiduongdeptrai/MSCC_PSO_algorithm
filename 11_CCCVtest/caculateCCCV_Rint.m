function caculateCCCV
    % ================= THÔNG SỐ BAN ĐẦU =================
    I_cutoff = 0.1;     % A
    U_cutoff = 4.2;     % V
    I_cc = 1.31;        % A
    Q0 = 1310 * 3.6;    % Dung lượng danh định (Coulomb)
    h = 0.01;           % Bước thời gian (s)272
    t_max = 10000;      % Thời gian mô phỏng tối đa (s)

    % ================= KHỞI TẠO DỮ LIỆU =================
    N = t_max / h;
    SoC_initial = 0.2;
    Qk_1 = SoC_initial * Q0;
    Ucpk = 0;
    Ucpk_1 = 0;
    Ik = I_cc;

    % Mảng lưu dữ liệu (dự trữ đủ lớn, sau sẽ cắt)
    time_arr     = zeros(1, N);
    voltage_arr  = zeros(1, N);
    current_arr  = zeros(1, N);
    capacity_arr = zeros(1, N);

    idx = 0; % chỉ số dữ liệu đã lưu

    % ================= VÒNG LẶP MÔ PHỎNG =================
    for k = 1:N
        tk = k * h;

        % Tính Qk (Coulomb)
        Qk = Qk_1 + Ik * h;

        % Tính SoC
        SoCk = Qk / Q0;

% ======= OCV theo mô hình mới =======
OCVk = 49.6031746026527*SoCk^7 - 242.777777775253*SoCk^6 ...
    + 482.05555555048*SoCk^5 - 502.20085469538*SoCk^4 ...
    + 296.925106834202*SoCk^3 - 99.8582591285466*SoCk^2 ...
    + 18.1649483181218*SoCk^1 + 2.28813333335013;
 
% ======= Rp theo mô hình mới =======
Rpk = - 112.726962371923*SoCk^7 + 475.810770564809*SoCk^6 ...
    - 842.118461485493*SoCk^5 + 809.705712605166*SoCk^4 ...
    - 456.246715585319*SoCk^3 + 150.407513926122*SoCk^2 ...
    - 26.8229600075181*SoCk^1 + 2.0116277956127;
 
% ======= Cp theo mô hình mới =======
Cpk = 13569519.4166804*SoCk^7 - 57373648.2503943*SoCk^6 ...
    + 100336200.459551*SoCk^5 - 93667153.1337912*SoCk^4 ...
    + 50177303.8499047*SoCk^3 - 15362475.1852854*SoCk^2 ...
    + 2483348.92753031*SoCk^1 - 161291.986997882;
 
% ======= Ro theo mô hình mới =======
R0k = - 26.2660619799801*SoCk^7 + 109.918871250544*SoCk^6 ...
    - 190.459259256136*SoCk^5 + 176.52916835934*SoCk^4 ...
    - 94.135374438522*SoCk^3 + 28.7364437013528*SoCk^2 ...
    - 4.63111345743667*SoCk^1 + 0.316849947081998;

        U_tk = OCVk + R0k * Ik;

        % Cập nhật giá trị cho lần lặp tiếp theo
        Qk_1 = Qk;
        Ucpk_1 = Ucpk;

        % Chế độ CV
        if U_tk >= U_cutoff
            U_tk = U_cutoff;
            Ik = (U_tk - OCVk) / R0k;
        else
            Ik = I_cc;
        end

        % === Chỉ lưu dữ liệu mỗi 1 giây ===
        if abs(mod(tk,1)) < 1e-6  
            idx = idx + 1;
            time_arr(idx)     = tk;
            voltage_arr(idx)  = U_tk;
            current_arr(idx)  = Ik;
            capacity_arr(idx) = SoCk * 100; % %
        end

        % Điều kiện dừng
        if (Ik <= I_cutoff) || (SoCk >= 1)
            break;
        end
    end

    % Cắt mảng dư
    time_arr     = time_arr(1:idx);
    voltage_arr  = voltage_arr(1:idx);
    current_arr  = current_arr(1:idx);
    capacity_arr = capacity_arr(1:idx);

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

    % ================= XUẤT DỮ LIỆU RA EXCEL =================
    data_out = [time_arr(:), voltage_arr(:), current_arr(:), capacity_arr(:)];
    header = {'Thoi_gian_s', 'Dien_ap_V', 'Dong_A', 'SoC_%'};
    filename = 'ket_qua_CCCV_Rint.xlsx';

    writecell(header, filename, 'Sheet', 1, 'Range', 'A1');
    writematrix(data_out, filename, 'Sheet', 1, 'Range', 'A2');

    disp(['--- Đã lưu dữ liệu vào file: ' filename ' ---']);
end
