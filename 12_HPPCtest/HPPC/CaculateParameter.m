clc; clear; close all;

%% ===== ĐỌC DỮ LIỆU TỪ EXCEL =====
filename = 'HPPC.xlsx';   % thay bằng tên file Excel
data = readtable(filename);

% Hiển thị tên các cột
disp('Tên các cột trong file:');
disp(data.Properties.VariableNames);

% Đọc dữ liệu cần thiết (chỉnh tên cột nếu file bạn khác)
SOC = data.SoC;
Uoc = data.VE;
Rp  = data.Rp;
Cp  = data.Cp;
Ro  = data.R0;

%% ===== DANH SÁCH THAM SỐ =====
vars   = {Uoc, Rp, Cp, Ro};
names  = {'Uoc','Rp','Cp','Ro'};

%% ===== Thiết lập font mặc định Cambria size 12 cho figure hiện tại =====
set(groot, 'defaultAxesFontName', 'Cambria');
set(groot, 'defaultTextFontName', 'Cambria');
set(groot, 'defaultAxesFontSize', 12);
set(groot, 'defaultLegendFontSize', 12);

%% ===== FIT ĐA THỨC & VẼ ĐỒ THỊ =====
for k = 1:numel(vars)
    [p, fit_y, SOC_fit] = SOC_approx(SOC, vars{k}, names{k});

    % In hệ số
    fprintf('\n--- Hệ số đa thức %s (bậc 7 -> bậc 0) ---\n', names{k});
    disp(p);

    % Vẽ figure riêng
    figure;
    plot(SOC, vars{k}, 'bo', SOC_fit, fit_y, 'r-', 'LineWidth', 2);
    grid on;
    xlabel('SOC', 'FontName','Cambria','FontSize',14);
    ylabel(names{k}, 'FontName','Cambria','FontSize',14);
    legend('Data','Polyfit','Location','best','FontSize',14,'FontName','Cambria');

    % In code MATLAB
    fprintf('\n%% ======= %s theo mô hình mới =======\n', names{k});
    print_poly([names{k},'k'], p);
end

%% ===== HÀM PHỤ =====
function [p, x_fit, SOC_fit] = SOC_approx(SOC, x, name)
    valid = ~(isnan(SOC) | isnan(x) | isinf(SOC) | isinf(x));
    SOC = SOC(valid);
    x   = x(valid);

    if length(SOC) < 8
        warning(['Không đủ điểm để fit bậc 7 cho ',name]);
        p = NaN(1,8);
        SOC_fit = [];
        x_fit = [];
        return;
    end

    p = polyfit(SOC, x, 7);
    SOC_fit = linspace(min(SOC), max(SOC), 200);
    x_fit   = polyval(p, SOC_fit);
end

function print_poly(varname, p)
    % In đa thức dưới dạng code MATLAB
    n = length(p);
    str = [varname,' = '];
    count = 0;
    
    for i = 1:n
        coeff = p(i);
        pow = n - i;
        if abs(coeff) < 1e-12, continue; end
        
        if coeff >= 0
            sign_str = '+ ';
        else
            sign_str = '- ';
            coeff = abs(coeff);
        end
        
        if pow > 0
            term = sprintf('%s%.15g*SoCk^%d', sign_str, coeff, pow);
        else
            term = sprintf('%s%.15g', sign_str, coeff);
        end
        
        if i == 1 && sign_str(1)=='+'   % bỏ dấu +
            term = term(3:end);
        end
        
        if count == 0
            str = [str, term];
        else
            str = [str, ' ', term];
        end
        
        count = count + 1;
        if count >= 2 && i < n
            disp([str, ' ...']);
            str = '    ';
            count = 0;
        end
    end
    
    str = [str, ';'];
    disp(str);
end
