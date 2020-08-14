function [x,fval,exitflag,output,population,score] = ga_hyberd(nvars,PopulationSize_Data)
%% This is an auto generated MATLAB file from Optimization Tool.

%% Start with the default options
options = optimoptions('ga');
%% Modify options setting
options = optimoptions(options,'PopulationSize', PopulationSize_Data);
options = optimoptions(options,'CreationFcn', @gacreationuniform);
options = optimoptions(options,'FitnessScalingFcn', {  @fitscalingtop [] });
options = optimoptions(options,'SelectionFcn', @selectionroulette);
options = optimoptions(options,'MutationFcn', {  @mutationuniform [] });
options = optimoptions(options,'HybridFcn', {  @fminsearch [] });
options = optimoptions(options,'Display', 'off');
options = optimoptions(options,'PlotFcn', { @gaplotbestf });
[x,fval,exitflag,output,population,score] = ...
ga(@ot_LN_errf,nvars,[],[],[],[],[],[],[],[],options);
