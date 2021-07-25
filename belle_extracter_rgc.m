%data loader for the HMM experiment
close all
clear all
clc
%on ststain = 1
%on transiant = 2
%off sustain =3
%off transiant =4
%unknown =5
name_char{1,1} ='on_s';
name_char{1,2} ='on_t';
name_char{1,3} ='off_s';
name_char{1,4} ='off_t';
name_char{1,5} ='unknown';
cd('D:\RiekeLab\Belle\belle_extract\191217')
load('D:\RiekeLab\spikes\191217\hmm_results_p.mat')
load('D:\RiekeLab\spikes\191217\type.mat')
for i = 1:2
    temp_g = results{1,i};
    for j = 1:length(temp_g)
        %save stimulus, firing rate, MI, spike time
        MI = temp_g(j).MI;
        FR = temp_g(j).FR;
        stim = temp_g(j).stim;
        spikes = temp_g(j).spikes;
        ID =  temp_g(j).ID;
        pre_name = ['HMM_g_' num2str(results{2,i}) '_t_' num2str(type(ID)) '_cell_' num2str(ID) '_e_' num2str(j) '_' ];
        save([pre_name 'MI'],'MI')
        save([pre_name 'FR'],'FR')
        save([pre_name 'stim'],'stim')
        save([pre_name 'spikes'],'spikes')
    end
    
end

%%
close all
clear all
clc
load('D:\RiekeLab\spikes\191217\ou_results_p.mat')
load('D:\RiekeLab\spikes\191217\type.mat')
cd('D:\RiekeLab\Belle\belle_extract\191217')
for i = 1:2
    temp_g = results{1,i};
    for j = 1:length(temp_g)
        %save stimulus, firing rate, MI, spike time
        MI = temp_g(j).MI;
        FR = temp_g(j).FR;
        stim = temp_g(j).stim;
        spikes = temp_g(j).spikes;
        ID =  temp_g(j).ID;
        pre_name = ['OU_g_' num2str(results{2,i}*10) '_t_' num2str(type(ID)) '_cell_' num2str(ID)  '_e_' num2str(j) '_' ];
        save([pre_name 'MI'],'MI')
        save([pre_name 'FR'],'FR')
        save([pre_name 'stim'],'stim')
        save([pre_name 'spikes'],'spikes')
    end
    
end

