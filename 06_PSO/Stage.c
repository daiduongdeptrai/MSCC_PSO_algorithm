#include <math.h>
#include <stdlib.h>


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

double I_pattern[10] = {2,1.5,1,0.6,0.2};

if(first_time){
    I_i = I_pattern[i];
    first_time=0;
    i+=1;
}


if (V >= V_cutoff) {
    I_i = I_pattern[i];
    i += 1;
}


if(i>n){
    I_i = 0;
}

tk=t;
Q_k=Q_k1+I_i*(tk-tk1);
Q_k1 = Q_k;
tk1 = tk;
Q = Q_k/3.6;



y1=I_i;
y2 = i;
y3= Q;
    

    

