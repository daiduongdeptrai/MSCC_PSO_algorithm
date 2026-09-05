GA = readtable('GA.xlsx');
PSO = readtable("PSO.xlsx");

iteration = GA.Iteration;

figure(1);
hold on

% Vẽ cho GA: đường liền màu xanh
for i = 2:16
    plot(iteration, GA{:, i}, 'b-', 'LineWidth', 1.2);
end

% Vẽ cho PSO: nét đứt ngắn đỏ
for i = 2:16
    plot(iteration, PSO{:, i}, 'r-.', 'LineWidth', 1.2);
end

xlabel('Số lần lặp');
ylabel('Cost function');
title('Giá trị hàm mục tiêu qua các lần lặp');
legend('GA', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ...
       'PSO', '', '', '', '', '', '', '', '', '', '', '', '', '', '');

ylim([0 2]);
xlim([0 100]);
grid on;
box on;

% Thiết lập font Cambria, cỡ chữ 10
set(gca, 'FontName', 'Cambria', 'FontSize', 14);
set(findall(gcf, '-property', 'FontName'), 'FontName', 'Cambria');
set(findall(gcf, '-property', 'FontSize'), 'FontSize', 14);
