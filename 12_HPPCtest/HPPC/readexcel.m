% Đọc dữ liệu từ Excel
filename = 'HPPC.xlsx';   % thay bằng tên file Excel của bạn
data = readtable(filename);  % đọc thành bảng

% Hiển thị tên các cột
disp('Tên các cột trong file:');
disp(data.Properties.VariableNames);