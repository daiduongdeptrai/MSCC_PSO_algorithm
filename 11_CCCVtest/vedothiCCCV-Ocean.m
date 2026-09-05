% Đọc file
data = readtable('VEDOTHICCCV.xlsx');
disp(data.Properties.VariableNames)

% Giả sử có cột: 'Time', 'Voltage_MATLAB', 'Voltage_PSIM',
%                'Current_MATLAB', 'Current_PSIM',
%                'Capacity_MATLAB', 'Capacity_PSIM'

t_M = data.Col1/1000;
t_P = data.Thoi_gian_s;

figure('Units','inches','Position',[1 1 10 8]); % Figure chung

%% Subplot 1: Điện áp
subplot(3,1,1);
plot(t_M, data.Col4/9000, 'b', 'LineWidth', 1.5); hold on;
plot(t_P, data.Dien_ap_V, 'r--', 'LineWidth', 2);
xlabel('Time (s)');
ylabel('Voltage (V)');
title('Điện áp');
legend('Thực nghiệm', 'Mô hình Thevenin');
ylim([3.6 4.25])
grid on;

%% Subplot 2: Dòng điện
subplot(3,1,2);
plot(t_M, data.Col14/1000, 'b', 'LineWidth', 1.5); hold on;
plot(t_P, data.Dong_A, 'r--', 'LineWidth', 2);
xlabel('Time (s)');
ylabel('Current (A)');
title('Dòng điện');
legend('Thực nghiệm', 'Mô hình Thevenin');
ylim([0 1.5]);
grid on;

%% Subplot 3: Dung lượng
subplot(3,1,3);
plot(t_M, data.Col2/3600 + 262.36, 'b', 'LineWidth', 1.5); hold on;
plot(t_P, data.Dungluong, 'r--', 'LineWidth', 1.5);
xlabel('Time (s)');
ylabel('Capacity (mAh)');
title('Dung lượng');
legend('Thực nghiệm', 'Mô hình Thevenin');
grid on;
