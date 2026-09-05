data = readtable("Time.xlsx");

% Đọc dữ liệu
num_runs = data.L_nCh_y;
timeGA = data.Th_iGianGA_s_;
timePSO = data.Th_iGianPSO_s_;

% Vẽ biểu đồ
figure;
hold on;

% Vẽ GA: màu xanh dương
scatter(num_runs, timeGA, 60, 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'k'); 
text(num_runs, timeGA + 20, string(timeGA), 'HorizontalAlignment', 'center');

% Vẽ PSO: màu đỏ
scatter(num_runs, timePSO, 60, 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k'); 

% Hiển thị text PSO với vị trí lệch tùy chẵn/lẻ
for i = 1:length(num_runs)
    if mod(num_runs(i), 2) == 0  % số chẵn
        y_offset = 40;
    else                         % số lẻ
        y_offset = 20;
    end
    text(num_runs(i), timePSO(i) + y_offset, string(timePSO(i)), 'HorizontalAlignment', 'center');
end

% Cài đặt trục và tiêu đề
xlabel('Lần thực hiện');
ylabel('Thời gian (s)');
title('So sánh thời gian');
legend('GA', 'PSO');
xlim([0 21]);
grid on;
box on;
