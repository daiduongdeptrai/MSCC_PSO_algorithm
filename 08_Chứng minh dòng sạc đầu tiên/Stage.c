#include <math.h>
#include <stdlib.h>


// Hàm tạo pattern dòng sạc tối ưu cho MSCC
double* generate_optimal_pattern(int n, double I_first, double I_last) {
    double* I_pattern = (double*)malloc(n * sizeof(double));
    
    if (n == 1) {
        I_pattern[0] = I_first;
    } 
    else if (n == 2) {
        I_pattern[0] = I_first;
        I_pattern[1] = I_last;
    } 
    else {
        // Phân bố dòng sạc theo cấp số nhân
        double log_first = log(I_first);
        double log_last = log(I_last);
        double step = (log_last - log_first) / (n - 1);
        int i;
        for (i = 0; i < n; i++) {
            I_pattern[i] = exp(log_first + i * step);
        }
    }
    
    return I_pattern;
}

static double V;
static double I_i;
static int i;
static int n=5;
static double I_CC=2.6;
static double I_min;
static double V_cutoff=4.22;
static double V_initial;
static double R=0.068;
static double C=11030;
static double SoC;

V=x1;
V_initial=x2;

SoC=(V_initial-3.35)*C/(2.6*3600);
I_min = (V_cutoff - V_initial)/R - 2.6*3600*(1-SoC)/(C*R);
double* I_pattern = generate_optimal_pattern(n, I_CC, I_min);

if(t<1){
    I_i = I_pattern[0];
}

if(V>= V_cutoff){
    I_i = I_pattern[i];
    i+=1;
}
    

y1=I_i;

    

    

