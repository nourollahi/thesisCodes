Set_DET_limits(0.01,0.6,0.001,0.8)
figure;
   Plot_DET (Miss,False_Alarm,'r');
   title('A DET plot For WMD(green) and Cosine (red)');
   hold on;

   C_miss = 1;
   C_fa = 0.1;
   P_target = 0.02;

   Set_DCF(C_miss,C_fa,P_target);
   [DCF_opt Popt_miss Popt_fa] = Min_DCF(Miss,False_Alarm);
   Plot_DET (Miss1,False_Alarm1,'g');