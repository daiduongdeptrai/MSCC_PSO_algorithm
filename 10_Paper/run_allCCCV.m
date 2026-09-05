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
writetable(Results, 'CCCV_summary.xlsx');
fprintf('=> Đã lưu kết quả tổng hợp vào file: CCCV_summary.xlsx\n');




function [time, Q_end] = simulate_charge(SoC_initial)
    % ================= THÔNG SỐ BAN ĐẦU =================
    state = 1;
    U_cutoff = 4.2;
    Q0 = 2000 * 3.6;            % Dung lượng danh định (C)
    h = 0.001;
    t_max = 10000;


    % ================= KHỞI TẠO DỮ LIỆU =================
    N = t_max / h;

    Qk_1 = SoC_initial* Q0;
    Ucpk = 0;
    Ucpk_1 = 0;
    U_tk=0;

for k=1:N
        if U_tk < U_cutoff
            Ik=2;
        else
            Ik = (U_cutoff - Ucpk - OCVk)/R0k;
        end
        
        tk = k*h;
        
        % Tính Qk (Coulomb)
        Qk = Qk_1 + Ik * h;   % Tích phân dòng theo thời gian

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
        Ucpk = Ucpk_1 + h * (-Ucpk / (Rpk * Cpk) + Ik / Cpk);
        
        % Điện áp pin
        U_tk = OCVk + R0k * Ik + Ucpk; 

        % Cập nhật giá trị
        Qk_1 = Qk;
        Ucpk_1=Ucpk;

        % MSCC logic

        if Ik <= 0.1
            Ik = 0;
            time = tk;
            Q_end = Qk/3.6;
            break;
        end
end
    fprintf('SoC ban đầu: %.2f -> Thời gian sạc kết thúc: %.2f giây, Dung lượng sạc được: %.2f mAh\n', ...
            SoC_initial, time, Q_end);

end