function simulate_charge

    % ================= THÔNG SỐ BAN ĐẦU =================
    U_cutoff = 4.2;
    Q0 = 2000 * 3.6;            % Dung lượng danh định (Coulomb)
    h = 0.01;
    t_max = 10000;

    % Tạo I_pattern với I3 hiện tại
    I_pattern = [2 1.117 0.7112 0.43 0.2416];

    % ================= KHỞI TẠO DỮ LIỆU =================
    N = t_max / h;
    Qk = 0;
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
    figure(1);
    
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

    % Tạo bảng
    T = table(t_data, I_data, U_data, Q_data, ...
              'VariableNames', {'Time_s','Current_A','Voltage_V','Capacity_mAh'});

    % Xuất ra file Excel
    filename = 'MSCC_results.xlsx';
    writetable(T, filename);

    fprintf('Dữ liệu 3 đồ thị đã được lưu vào file: %s\n', filename);

end
