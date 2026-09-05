function simulate_charge

    % ================= THÔNG SỐ BAN ĐẦU =================
    U_cutoff = 4.2;
    Q0 = 1310 * 3.6;            % Dung lượng danh định (Coulomb)
    h = 0.01;                   % bước mô phỏng (s)
    t_max = 10000;              % thời gian mô phỏng tối đa (s)
    SoC_initial = 0.25;

    % Tạo I_pattern với I3 hiện tại
    I_pattern = [1.34 0.85 0.65 0.43 0.292];

    % ================= KHỞI TẠO DỮ LIỆU =================
    N = t_max / h;
    Qk = SoC_initial * Q0;
    Ucpk = 0;
    state = 1;
    time = 0;

    % Mảng lưu dữ liệu để vẽ
    t_array = zeros(1, N);
    I_array = zeros(1, N);
    U_array = zeros(1, N);
    Q_array = zeros(1, N);

    for k = 1:N
        tk = k * h;
        Ik = I_pattern(state);

        % Tính Qk (Coulomb)
        Qk = Qk + Ik * h;

        % Tính SoC
        SoCk = Qk / Q0;

    % ======= Tham số từ mô hình mới =======
    OCVk = 49.6031746023540*SoCk^7 - 242.777777773998*SoCk^6 + 482.055555548292*SoCk^5 - 502.200854693335*SoCk^4 ...
         + 296.925106833103*SoCk^3 - 99.8582591282089*SoCk^2 + 18.1649483180672*SoCk + 2.28813333335377;

    R0k = -26.2660619798791*SoCk^7 + 109.918871250115*SoCk^6 - 190.459259255377*SoCk^5 + 176.529168358619*SoCk^4 ...
        - 94.1353744381275*SoCk^3 + 28.7364437012291*SoCk^2 - 4.63111345741627*SoCk + 0.316849947080660;

    Rpk = -112.726962371470*SoCk^7 + 475.810770562890*SoCk^6 - 842.118461482113*SoCk^5 + 809.705712601971*SoCk^4 ...
        - 456.246715583578*SoCk^3 + 150.407513925579*SoCk^2 - 26.8229600074291*SoCk + 2.01162779560696;

    Cpk = 13569519.4166240*SoCk^7 - 57373648.2501548*SoCk^6 + 100336200.459128*SoCk^5 - 93667153.1333908*SoCk^4 ...
        + 50177303.8496861*SoCk^3 - 15362475.1852170*SoCk^2 + 2483348.92751907*SoCk - 161291.986997137;

        % RC song song
        Ucpk = Ucpk + h * (-Ucpk / (Rpk * Cpk) + Ik / Cpk);

        % Điện áp pin
        U_tk = OCVk + R0k * Ik + Ucpk;

        % Lưu dữ liệu
        t_array(k) = tk;
        I_array(k) = Ik;
        U_array(k) = U_tk;
        Q_array(k) = Qk / 3.6;  % đổi sang mAh

        % MSCC logic
        if U_tk >= U_cutoff
            state = state + 1;
        end

        if state > 5
            time = tk;
            break;
        end
    end

    % ================= VẼ ĐỒ THỊ =================
    figure();
    
    subplot(3,1,1);
    plot(t_array(1:k), I_array(1:k), 'b', 'LineWidth', 1.5);
    ylabel('Dòng điện (A)');
    title('Dòng điện sạc theo thời gian');
    grid on;

    subplot(3,1,2);
    plot(t_array(1:k), U_array(1:k), 'r', 'LineWidth', 1.5);
    ylabel('Điện áp (V)');
    title('Điện áp sạc theo thời gian');
    grid on;

    subplot(3,1,3);
    plot(t_array(1:k), Q_array(1:k), 'g', 'LineWidth', 1.5);
    xlabel('Thời gian (s)');
    ylabel('Dung lượng (mAh)');
    title('Dung lượng sạc theo thời gian');
    grid on;

    % In kết quả
    fprintf('Thời gian sạc kết thúc: %.2f giây\n', time);
    fprintf('Dung lượng sạc được: %.2f mAh\n', Q_array(k));

    % ================= XUẤT DỮ LIỆU RA EXCEL =================
    % Cắt dữ liệu đến thời điểm k (kết thúc sạc)
    t_data = t_array(1:k)';
    I_data = I_array(1:k)';
    U_data = U_array(1:k)';
    Q_data = Q_array(1:k)';

    % ---- THIẾT LẬP BƯỚC LƯU ----
    save_step = 1;   % đơn vị: giây (có thể đổi sang 0.5, 2, 5,...)

    % Chỉ lấy dữ liệu tại các thời điểm bội số của save_step
    idx = abs(mod(t_data, save_step)) < 1e-9; 
    t_data = t_data(idx);
    I_data = I_data(idx);
    U_data = U_data(idx);
    Q_data = Q_data(idx);

    % Tạo bảng
    T = table(t_data, I_data, U_data, Q_data, ...
              'VariableNames', {'Time_s','Current_A','Voltage_V','Capacity_mAh'});

    % Tên file
    filename = 'MSCC_results.xlsx';

    % ---- XÓA FILE CŨ NẾU TỒN TẠI ----
    if isfile(filename)
        delete(filename);
        fprintf('Đã xoá file cũ: %s\n', filename);
    end

    % Xuất ra file Excel
    writetable(T, filename);
    fprintf('Dữ liệu (mỗi %.2f giây) đã được lưu vào file: %s\n', save_step, filename);

end
