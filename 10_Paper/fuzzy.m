clc; clear; close all;

%% Thiết lập font Cambria + chuẩn IEEE
set(groot,'defaultAxesFontName','Cambria');
set(groot,'defaultTextFontName','Cambria');
set(groot,'defaultAxesFontSize',12);   % mặc định chữ thường size 12
set(groot,'defaultTextFontSize',12);
set(groot,'defaultAxesLineWidth',1);
set(groot,'defaultLineLineWidth',1.2);

lw = 1.2; % độ dày nét

%% ========== (a) – Hàm thành viên của NCC ==========
x1 = 70:0.1:110; % trục SoC (%)
mf_S  = trapmf(x1,[0 0 80 85]);
mf_MS = trimf(x1,[80 85 90]);
mf_M  = trimf(x1,[85 90 95]);
mf_ML = trimf(x1,[90 95 100]);
mf_L  = trapmf(x1,[95 100 1000 1000]);

figure;
plot(x1,mf_S,'k','LineWidth',lw); hold on;
plot(x1,mf_MS,'k','LineWidth',lw);
plot(x1,mf_M,'k','LineWidth',lw);
plot(x1,mf_ML,'k','LineWidth',lw);
plot(x1,mf_L,'k','LineWidth',lw);

xlabel('(%)');
ylabel('µ_{C_{charge-norm}}','FontSize',14); % riêng nhãn mu size 14
ylim([0 1.2]); xlim([75 105]); grid on;

text(80,1.05,'S','FontWeight','bold','Color','k');
text(85,1.05,'MS','FontWeight','bold','Color','k');
text(90,1.05,'M','FontWeight','bold','Color','k');
text(95,1.05,'ML','FontWeight','bold','Color','k');
text(100,1.05,'L','FontWeight','bold','Color','k');


%% ========== (b) – Hàm thành viên của CT ==========
x2 = 0:0.1:100; % trục Thời gian (min)
mf_S2  = trapmf(x2,[0 0 10 30]);
mf_MS2 = trimf(x2,[10 30 50]);
mf_M2  = trimf(x2,[30 50 70]);
mf_ML2 = trimf(x2,[50 70 90]);
mf_L2  = trapmf(x2,[70 90 1000 1000]);

figure;
plot(x2,mf_S2,'k','LineWidth',lw); hold on;
plot(x2,mf_MS2,'k','LineWidth',lw);
plot(x2,mf_M2,'k','LineWidth',lw);
plot(x2,mf_ML2,'k','LineWidth',lw);
plot(x2,mf_L2,'k','LineWidth',lw);

xlabel('(min.)');
ylabel('µ_{T_{charge}}','FontSize',14);
ylim([0 1.2]); grid on;

text(10,1.05,'S','FontWeight','bold','Color','k');
text(30,1.05,'MS','FontWeight','bold','Color','k');
text(50,1.05,'M','FontWeight','bold','Color','k');
text(70,1.05,'ML','FontWeight','bold','Color','k');
text(90,1.05,'L','FontWeight','bold','Color','k');


%% ========== (c) – Hàm thành viên của F ==========
x3 = -0.1:0.001:1.1; % trục F (chuẩn hóa)
mf_VS = trapmf(x3,[-10 -10 0 0.125]);
mf_SS = trimf(x3,[0 0.125 0.25]);
mf_S3 = trimf(x3,[0.125 0.25 0.375]);
mf_MS3 = trimf(x3,[0.25 0.375 0.5]);
mf_MT3 = trimf(x3,[0.375 0.5 0.625]);
mf_ML3 = trimf(x3,[0.5 0.625 0.75]);
mf_L3  = trimf(x3,[0.625 0.75 0.875]);
mf_LL3 = trimf(x3,[0.75 0.875 1]);
mf_VL3 = trapmf(x3,[0.875 1 10 10]);

figure;
plot(x3,mf_VS,'k','LineWidth',lw); hold on;
plot(x3,mf_SS,'k','LineWidth',lw);
plot(x3,mf_S3,'k','LineWidth',lw);
plot(x3,mf_MS3,'k','LineWidth',lw);
plot(x3,mf_MT3,'k','LineWidth',lw);
plot(x3,mf_ML3,'k','LineWidth',lw);
plot(x3,mf_L3,'k','LineWidth',lw);
plot(x3,mf_LL3,'k','LineWidth',lw);
plot(x3,mf_VL3,'k','LineWidth',lw);

xlabel('');
ylabel('µ_{F}','FontSize',14);
ylim([0 1.2]); xlim([-0.1 1.1]); grid on;

text(0,1.05,'VS','FontWeight','bold','Color','k');
text(0.125,1.05,'SS','FontWeight','bold','Color','k');
text(0.25,1.05,'S','FontWeight','bold','Color','k');
text(0.375,1.05,'MS','FontWeight','bold','Color','k');
text(0.5,1.05,'M','FontWeight','bold','Color','k');
text(0.625,1.05,'ML','FontWeight','bold','Color','k');
text(0.75,1.05,'L','FontWeight','bold','Color','k');
text(0.875,1.05,'LL','FontWeight','bold','Color','k');
text(1,1.05,'VL','FontWeight','bold','Color','k');
