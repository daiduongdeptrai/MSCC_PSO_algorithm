#include <math.h>
#include <stdlib.h>



static double V;
static double I_i;
static int i;
static int n=5;
static double I_CC=2.6;
static double SoC_initial = 0.8;
static double V_cutoff=4.2;

V=x1;

double I_pattern[5] = {1.31, 1.054, 0.714, 0.503, 0.292};
if(t<1){
    I_i = I_pattern[0];
}

if(V>= V_cutoff){
    I_i = I_pattern[i];
    i+=1;
}


y1=I_i;


