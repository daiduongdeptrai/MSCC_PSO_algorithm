% Đọc file
data = readtable('CCCV-DATA.xlsx');

% Giả sử có cột: 'Time', 'Voltage_MATLAB', 'Voltage_PSIM',
%                'Current_MATLAB', 'Current_PSIM',
%                'Capacity_MATLAB', 'Capacity_PSIM'

t_M = data.Var1;
t_P = data.Var8;

% Điện áp
figure;
plot(t_M, data.Var2, 'b', 'LineWidth', 1.5); hold on;
plot(t_P, data.Var10, 'r--', 'LineWidth', 1.5);
xlabel('Time (s)');
ylabel('Voltage (V)');
title('Điện áp');
legend('Thực nghiệm', 'Mô phỏng bằng mô hình Thevenin');
grid on;

% Dòng điện
figure;
plot(t_M, data.Var3, 'b', 'LineWidth', 1.5); hold on;
plot(t_P, data.Var9, 'r--', 'LineWidth', 1.5);
xlabel('Time (s)');
ylabel('Current (A)');
title('Dòng điện');
legend('Thực nghiệm', 'Mô phỏng bằng mô hình Thevenin');
grid on;
ylim([0 2.2]);

% Dung lượng
figure;
plot(t_M, data.Var5, 'b', 'LineWidth', 1.5); hold on;
plot(t_P, data.Var13, 'r--', 'LineWidth', 1.5);
xlabel('Time (s)');
ylabel('Capacity (mAh)');
title('Dung lượng');
legend('Thực nghiệm', 'Mô phỏng bằng mô hình Thevenin');
grid on;
