function tcc_mscc
    % ================= THÔNG SỐ BAN ĐẦU =================
    state = 1;
    U_cutoff = 4.2;
    Q0 = 2000 * 3.6;            % Dung lượng danh định (C)
    h = 0.01;
    t_max = 10000;

    % ================= KHỞI TẠO DỮ LIỆU =================
    N = t_max / h;
    t = 0:h:t_max;
    Ucp = zeros(1, length(t));
    U_t_arr = zeros(1, length(t));
    Icc_arr = zeros(1, length(t));
    Qk = zeros(1, length(t));   % Dung lượng sạc được (Coulomb)

    % ================= VÒNG LẶP MÔ PHỎNG =================
    for k = 1:N
        t(k) = k * h;
        Icc = State(state);
        Icc_arr(k) = Icc;
        
        if(k>0)
        % Tính Qk (Coulomb)
        Qk(k+1) = Qk(k) + Icc * h;   % Tích phân dòng theo thời gian
        end
        % Tính SoC
        SoC(k) = Qk(k) / Q0;

        % Tính các thông số tương ứng
        OCV(k) = 2.896 + 9.563*SoC(k) - 57.92*SoC(k)^2 + 188.2*SoC(k)^3 ...
               - 340.7*SoC(k)^4 + 347.5*SoC(k)^5 - 184.2*SoC(k)^6 + 38.95*SoC(k)^7;

        R0(k) = 0.039 - 0.131*SoC(k) + 0.507*SoC(k)^2 - 1.129*SoC(k)^3 ...
              + 1.679*SoC(k)^4 - 1.764*SoC(k)^5 + 1.157*SoC(k)^6 - 0.331*SoC(k)^7;

        Rp(k) = 0.048 - 0.318*SoC(k) + 2.075*SoC(k)^2 - 9.171*SoC(k)^3 ...
              + 23.41*SoC(k)^4 - 31.96*SoC(k)^5 + 21.71*SoC(k)^6 - 5.78*SoC(k)^7;

        Cp(k) = 104.9 - 311.3*SoC(k) + 277.9*SoC(k)^2 - 2.435*SoC(k)^3 ...
              - 111.4*SoC(k)^4 + 44.86*SoC(k)^5 - 1.53*SoC(k)^6 + 0.108*SoC(k)^7;

        % RC song song
        Ucp(k+1) = Ucp(k) + h * (-Ucp(k) / (Rp(k) * Cp(k)) + Icc / Cp(k));

        % Điện áp pin
        U_t = OCV(k) + R0(k) * Icc + Ucp(k);
        U_t_arr(k) = U_t;

        % MSCC logic
        if U_t >= U_cutoff
            state = state + 1;
        end

        if state > 5
            
            fprintf('\n======= ĐÃ ĐẠT MSCC =======\n');
            fprintf('Thời gian sạc: %.6f s\n', t(k-1));
            fprintf('SoC tại thời điểm này: %.6f\n', SoC(k-1));
            fprintf('OCV tại thời điểm này: %.6f V\n', OCV(k-1));
            fprintf('Dung lượng Q tại thời điểm này: %.6f Ah\n', Qk(k-1)/3.6);
            fprintf('State: %.6f V\n', state);
            break;
        end
    end

    % =============== VẼ ĐỒ THỊ ===============
    figure(1);

    % Đồ thị điện áp
    subplot(3,1,1);
    plot(t(1:k), U_t_arr(1:k), 'b', 'LineWidth', 1.5);
    xlabel('Thời gian (s)');
    ylabel('Điện áp (V)');
    title('Biến thiên điện áp trong quá trình sạc (MSCC)');
    grid on;

    % Đồ thị dòng điện
    subplot(3,1,2);
    plot(t(1:k), Icc_arr(1:k), 'r', 'LineWidth', 1.5);
    xlabel('Thời gian (s)');
    ylabel('Dòng sạc (A)');
    title('Dòng điện sạc thay đổi theo MSCC');
    grid on;

    % Đồ thị dung lượng Qk
    subplot(3,1,3);
    plot(t(1:k), Qk(1:k)/3.6, 'g', 'LineWidth', 1.5);
    xlabel('Thời gian (s)');
    ylabel('Dung lượng sạc (Ah)');
    title('Dung lượng Q_k tích lũy theo thời gian');
    grid on;
end

function I = State(state)
    switch state 
        case 1
            I = 2;
        case 2
            I = 1.6;
        case 3
            I = 1.2;
        case 4
            I = 0.8;
        case 5
            I = 0.4;
        case 6
            I = 0;
    end
end
