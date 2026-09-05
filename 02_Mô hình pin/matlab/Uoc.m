% Dữ liệu SOC và OCV đo (ví dụ)
SOC = linspace(0,1,25);
OCV_data = [2.75, 3.6, 3.76, 3.80, 3.82, 3.83, 3.84, 3.85, ...
            3.855, 3.86, 3.865, 3.868, 3.87, 3.871, 3.872, ...
            3.874, 3.875, 3.876, 3.878, 3.88, 3.885, 3.89, ...
            3.9, 3.95, 4.2]; % Cập nhật bằng dữ liệu thực tế của bạn nếu có

% Hàm Tremblay2
Tremblay2 = @(p, SOC) p(1) + p(2) * exp(-p(3)*(1 - SOC)) - p(4)./(SOC + p(5));

% Tham số ban đầu để khởi tạo
p0 = [3.9, 0.2, 10, 0.02, 0.01]; 

% Fit nonlinear least squares
opts = optimoptions('lsqcurvefit','Display','off');
p_opt = lsqcurvefit(Tremblay2, p0, SOC, OCV_data, [], [], opts);

% OCV fitted
OCV_fit = Tremblay2(p_opt, SOC);

% Vẽ đồ thị
figure;
% Vẽ dữ liệu đo (đường nối màu xanh có chấm tròn)
plot(SOC*100, OCV_data, '-ob', 'LineWidth', 1.5, 'MarkerFaceColor', 'b', ...
    'DisplayName', 'Dữ liệu đo'); hold on;
% Vẽ đường xấp xỉ Tremblay2 (nét đứt đỏ)
plot(SOC*100, OCV_fit, 'r--', 'LineWidth', 1.5, 'DisplayName', 'Tremblay2 fit (NLS)');
ylim([2.6 4.4]);

xlabel('SOC (%)');
ylabel('OCV (V)');
title('Xấp xỉ OCV bằng hàm Tremblay2 với Nonlinear Least Squares');
legend('Location', 'southeast');
grid on;

% In ra tham số tối ưu
disp('Tham số tối ưu [a, b, c, d, e]:');
disp(p_opt);
