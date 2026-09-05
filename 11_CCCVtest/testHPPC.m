clc; clear; close all;

% ====== Tạo vector SoC ======
SoC = linspace(0, 1, 200); % từ 0 đến 1, 200 điểm

% ====== Các hàm tham số mới ======
% Cp mới
Cp = 1.36e7*SoC.^7 - 5.74e7*SoC.^6 + 1e8*SoC.^5 - 9.37e7*SoC.^4 ...
     + 5.02e7*SoC.^3 - 1.54e7*SoC.^2 + 2.48e6*SoC - 1.61e5;

% Rp mới
Rp = -113*SoC.^7 + 476*SoC.^6 - 842*SoC.^5 + 810*SoC.^4 ...
     - 456*SoC.^3 + 150*SoC.^2 - 26.8*SoC + 2.01;

% R0 mới
R0 = -26.3*SoC.^7 + 110*SoC.^6 - 190*SoC.^5 + 177*SoC.^4 ...
     - 94.1*SoC.^3 + 28.7*SoC.^2 - 4.63*SoC + 0.317;

% OCV giữ nguyên
OCV = 49.6*SoC.^7 - 243*SoC.^6 + 482*SoC.^5 - 502*SoC.^4 ...
      + 297*SoC.^3 - 99.9*SoC.^2 + 18.2*SoC + 2.29;

% ====== Vẽ 4 đồ thị độc lập ======
figure;

subplot(2,2,1);
plot(SoC, Cp, 'r', 'LineWidth', 1.5);
xlabel('SoC'); ylabel('C_p'); title('C_p theo SoC'); grid on;

subplot(2,2,2);
plot(SoC, Rp, 'b', 'LineWidth', 1.5);
xlabel('SoC'); ylabel('R_p'); title('R_p theo SoC'); grid on;

subplot(2,2,3);
plot(SoC, R0, 'g', 'LineWidth', 1.5);
xlabel('SoC'); ylabel('R_0'); title('R_0 theo SoC'); grid on;

subplot(2,2,4);
plot(SoC, OCV, 'm', 'LineWidth', 1.5);
xlabel('SoC'); ylabel('OCV (V)'); title('OCV theo SoC'); grid on;
