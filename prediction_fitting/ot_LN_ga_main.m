function [x,fval,exitflag,output,population,score] = ot_LN_ga_main(sr_pair)
%for excution the of the LN fitting and spit out the results 
clc
fit_dir = 'D:\RiekeLab\codes\fitting_temp_home';%Nori, you can create and change to your own dir
ot_file_remover(fit_dir)%clean all the file in that dir
cd(fit_dir)
save('sr_pair.mat','sr_pair')%save sr_pair as sr_pair.mat
nvars = 9;
PopulationSize_Data = 500;
[x,fval,exitflag,output,population,score] = ga_hyberd2(nvars,PopulationSize_Data);

end