% Danh sách SoC ban đầu cần chạy
SoC_list = 0:0.05:0.9;

% Bảng lưu kết quả tổng hợp
Results = table([], [], [], 'VariableNames', {'SoC_initial','ChargeTime_s','Capacity_mAh'});

for SoC = SoC_list
    [time, Q_end] = simulate_charge(SoC);
    % Ghi vào bảng
    Results = [Results; {SoC, time, Q_end}];
end

% Xuất ra Excel tổng hợp
writetable(Results, 'MSCC_summary.xlsx');
fprintf('=> Đã lưu kết quả tổng hợp vào file: MSCC_summary.xlsx\n');




function [time, Q_end] = simulate_charge(SoC_initial)

    % ================= THÔNG SỐ BAN ĐẦU =================
    U_cutoff = 4.2;
    Q0 = 2000 * 3.6;            % Dung lượng danh định (Coulomb)
    h = 0.01;
    t_max = 10000;

    % Tạo I_pattern với I3 hiện tại
    I_pattern = [2 1.117 0.7112 0.43 0.2416];

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


    % In kết quả
    fprintf('SoC ban đầu: %.2f -> Thời gian sạc kết thúc: %.2f giây, Dung lượng sạc được: %.2f mAh\n', ...
            SoC_initial, time, Q_array(k));

    % ================= XUẤT DỮ LIỆU RA EXCEL =================
    % Cắt dữ liệu đến thời điểm k (kết thúc sạc)
    t_data = t_array(1:k)';
    I_data = I_array(1:k)';
    U_data = U_array(1:k)';
    Q_data = Q_array(1:k)';

    % Trả về kết quả để dùng ngoài
    Q_end = Q_array(k);

end
