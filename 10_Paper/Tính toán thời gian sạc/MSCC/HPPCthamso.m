% ==================== VẼ OCV, R0, Rp, Cp THEO SoC ====================
% Tạo vector SoC mịn để vẽ đường
SoC = linspace(0,1,200);

% Vector SoC lấy mẫu mỗi 0.1 để đánh dấu
SoC_mark = 0:0.1:1;

% Tính toán các giá trị (đường mịn)
OCV = 2.896 + 9.563*SoC - 57.92*SoC.^2 + 188.2*SoC.^3 ...
      - 340.7*SoC.^4 + 347.5*SoC.^5 - 184.2*SoC.^6 + 38.95*SoC.^7;

R0  = 0.039 - 0.131*SoC + 0.507*SoC.^2 - 1.129*SoC.^3 ...
      + 1.679*SoC.^4 - 1.764*SoC.^5 + 1.157*SoC.^6 - 0.331*SoC.^7;

Rp  = 0.048 - 0.318*SoC + 2.075*SoC.^2 - 9.171*SoC.^3 ...
      + 23.41*SoC.^4 - 31.96*SoC.^5 + 21.71*SoC.^6 - 5.78*SoC.^7;

Cp  = 104.9 - 311.3*SoC + 277.9*SoC.^2 - 2.435*SoC.^3 ...
      - 111.4*SoC.^4 + 44.86*SoC.^5 - 1.53*SoC.^6 + 0.108*SoC.^7;

% Tính toán giá trị tại các điểm SoC_mark
OCV_mark = 2.896 + 9.563*SoC_mark - 57.92*SoC_mark.^2 + 188.2*SoC_mark.^3 ...
      - 340.7*SoC_mark.^4 + 347.5*SoC_mark.^5 - 184.2*SoC_mark.^6 + 38.95*SoC_mark.^7;

R0_mark  = 0.039 - 0.131*SoC_mark + 0.507*SoC_mark.^2 - 1.129*SoC_mark.^3 ...
      + 1.679*SoC_mark.^4 - 1.764*SoC_mark.^5 + 1.157*SoC_mark.^6 - 0.331*SoC_mark.^7;

Rp_mark  = 0.048 - 0.318*SoC_mark + 2.075*SoC_mark.^2 - 9.171*SoC_mark.^3 ...
      + 23.41*SoC_mark.^4 - 31.96*SoC_mark.^5 + 21.71*SoC_mark.^6 - 5.78*SoC_mark.^7;

Cp_mark  = 104.9 - 311.3*SoC_mark + 277.9*SoC_mark.^2 - 2.435*SoC_mark.^3 ...
      - 111.4*SoC_mark.^4 + 44.86*SoC_mark.^5 - 1.53*SoC_mark.^6 + 0.108*SoC_mark.^7;

% Font mặc định Cambria + size
set(groot, 'defaultAxesFontName', 'Cambria');
set(groot, 'defaultTextFontName', 'Cambria');
set(groot, 'defaultAxesFontSize', 12);

% --------- OCV ---------
figure;
plot(SoC, OCV, 'b', 'LineWidth', 1.5); hold on;
plot(SoC_mark, OCV_mark, 'bo', 'MarkerSize', 6, 'MarkerFaceColor','b');
xlabel('SoC');
ylabel('OCV (V)');
grid on;

% --------- R0 ---------
figure;
plot(SoC, R0, 'r', 'LineWidth', 1.5); hold on;
plot(SoC_mark, R0_mark, 'ro', 'MarkerSize', 6, 'MarkerFaceColor','r');
xlabel('SoC');
ylabel('R_0 (\Omega)');
grid on;

% --------- Rp ---------
figure;
plot(SoC, Rp, 'm', 'LineWidth', 1.5); hold on;
plot(SoC_mark, Rp_mark, 'mo', 'MarkerSize', 6, 'MarkerFaceColor','m');
xlabel('SoC');
ylabel('R_p (\Omega)');
grid on;

% --------- Cp ---------
figure;
plot(SoC, Cp, 'g', 'LineWidth', 1.5); hold on;
plot(SoC_mark, Cp_mark, 'go', 'MarkerSize', 6, 'MarkerFaceColor','g');
xlabel('SoC');
ylabel('C_p (F)');
grid on;
