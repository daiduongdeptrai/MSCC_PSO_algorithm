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
static int i=0;
static int n=5;
static double I_CC=1.1;
static double I_min=0.01;
static double V_cutoff=4.2;
static double tk;
static double tk1;
static int first_time = 1;
static double Q_k;
static double Q_k1;
static double Q;

V=x1;

double* I_pattern = generate_optimal_pattern(n, I_CC, I_min);

if(first_time){
    I_i = I_pattern[i];
    first_time=0;
    i+=1;
}


if (V >= V_cutoff && i < n) {
    I_i = I_pattern[i];
    i += 1;
    if(Q>=5.1){
        i = n;
    }
}

tk=t;
Q_k=Q_k1+I_i*(tk-tk1);
Q_k1 = Q_k;
tk1 = tk;
Q = Q_k/3600;

if (Q >= 5.51) {
    Q = 5.51;
    i = n;
    I_i = 0;
}

y1=I_i;
y2 = i;
y3= Q;
    

    

