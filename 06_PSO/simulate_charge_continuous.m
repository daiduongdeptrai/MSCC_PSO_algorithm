function simulate_charge_continuous
    % ================= THÔNG SỐ BAN ĐẦU =================
    U_cutoff = 4.2;          % Điện áp ngắt (V)
    Q0 = 2000 * 3.6;         % Dung lượng danh định (C) = 2000mAh * 3600s/h

    % Dãy dòng sạc I1 (A)
    I1_vals = linspace(0.5, 5, 100);
    t1_vals = zeros(size(I1_vals));

    % Vòng lặp tìm nghiệm t1 cho từng I1
    for k = 1:length(I1_vals)
        I1 = I1_vals(k);
        syms t1 

        % Tính SoC
        SoC = (3000 * I1 + ) / Q0;

        % Các hàm phụ thuộc SoC
        OCV = 2.896 + 9.563*SoC - 57.92*SoC^2 + 188.2*SoC^3 ...
             - 340.7*SoC^4 + 347.5*SoC^5 - 184.2*SoC^6 + 38.95*SoC^7;

        Ro = 0.039 - 0.131*SoC + 0.507*SoC^2 - 1.129*SoC^3 ...
            + 1.679*SoC^4 - 1.764*SoC^5 + 1.157*SoC^6 - 0.331*SoC^7;

        Rp = 0.048 - 0.318*SoC + 2.075*SoC^2 - 9.171*SoC^3 ...
           + 23.41*SoC^4 - 31.96*SoC^5 + 21.71*SoC^6 - 5.78*SoC^7;

        Cp = 104.9 - 311.3*SoC + 277.9*SoC^2 - 2.435*SoC^3 ...
           - 111.4*SoC^4 + 44.86*SoC^5 - 1.53*SoC^6 + 0.108*SoC^7;

        % Biểu thức điện áp
        UCp = I1 * Rp * (1 - exp(-t1 / (Rp * Cp)));
        U_batt = OCV + Ro * I1 + UCp;

        % Giải phương trình U_batt = U_cutoff để tìm t1
        try
            t1_sol = vpasolve(U_batt == U_cutoff, t1, [0, 5000]); % Giới hạn khoảng tìm
            if isempty(t1_sol)
                t1_vals(k) = NaN;
            else
                t1_vals(k) = double(t1_sol);
            end
        catch
            t1_vals(k) = NaN;
        end
    end

    % Vẽ đồ thị
    plot(I1_vals, t1_vals, 'LineWidth', 2)
    xlabel('Dòng sạc I1 (A)')
    ylabel('Thời gian t1 (s)')
    title('Thời gian sạc t1 theo dòng sạc I1 (giải số)')
    grid on
end
