function simulate_chargeCCCV
    % ================= THÔNG SỐ BAN ĐẦU =================
    state = 1;
    U_cutoff = 4.2;
    Q0 = 2000 * 3.6;            % Dung lượng danh định (C)
    h = 0.001;
    t_max = 10000;


    % ================= KHỞI TẠO DỮ LIỆU =================
    N = t_max / h;

    Qk = 0;
    Qk_1 = 0;
    Ucpk = 0;
    Ucpk_1 = 0;
    % Khởi tạo mảng lưu dữ liệu
    tk_arr = zeros(1, N);
    Q_arr = zeros(1, N);
    U_arr = zeros(1, N);
    I_arr = zeros(1, N);
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

        % Lưu giá trị tại mỗi bước
        tk_arr(k) = tk;
        Q_arr(k) = Qk / 3.6;   % Chuyển sang đơn vị Ah
        U_arr(k) = U_tk;
        I_arr(k) = Ik;


        if Ik <= 0.1
            Ik = 0;
            fprintf('\n======= ĐÃ ĐẠT CCCV ĐƠN GIẢN =======\n');
            fprintf('Thời gian sạc: %.6f s\n', tk);
            fprintf('Dung lượng Q sạc: %.6f Ah\n', Qk/3.6);
            fprintf('State: %f\n', state);
            break;
        end
end
% Cắt mảng tại điểm dừng nếu thoát sớm
tk_arr = tk_arr(1:k);
Q_arr = Q_arr(1:k);
U_arr = U_arr(1:k);
I_arr = I_arr(1:k);

% Vẽ đồ thị
figure(1);
subplot(3,1,1);
plot(tk_arr, Q_arr, 'b', 'LineWidth', 1.5);
xlabel('Thời gian (s)');
ylabel('Dung lượng (Ah)');
title('Dung lượng tích lũy theo thời gian');
grid on;

subplot(3,1,2);
plot(tk_arr, U_arr, 'r', 'LineWidth', 1.5);
xlabel('Thời gian (s)');
ylabel('Điện áp (V)');
title('Điện áp pin theo thời gian');
grid on;

subplot(3,1,3);
plot(tk_arr, I_arr, 'g', 'LineWidth', 1.5);
xlabel('Thời gian (s)');
ylabel('Dòng điện (A)');
title('Dòng điện sạc theo thời gian');
grid on;

end
