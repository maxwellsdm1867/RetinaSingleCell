close all
clear all
clc
%load the data
load('C:\Users\USER\Downloads\doves_data\doves_psth_onT_211026.mat')
clip_id  =3; %temp
lvs= size(psth_cabnet{1,1},1);
half_width = 150;
fact =10 ;
avg_psth = psth_cabnet{clip_id,1};

%%
fr1 = avg_psth(1,:);
fr2 = avg_psth(2,:);
save_path = 'C:\Users\USER\Downloads\doves_data\d2';
up_fact = 10;
xl = 'firing rate at 100r*';
yl =  'firing rate at 10r*';
doves_gif(fr1,fr2,save_path,up_fact,xl,yl)
figure
hold on 

%low pass the filter 
close all
del = 0;%delay
figure
hold on 
h1 = gaus_smooth(fr1,up_fact);
y = interp(lowpass(fr1,0.001,100),up_fact);
c = [zeros(1,del) y(1:end-del) ];
plot(h1)
plot(c)
hold off
h2 = c;
sel_idx = unique([find(h1>0.01) find(h2>0.01)]);%where there is activity 
sel_1 = h1(sel_idx);
sel_2 = h2(sel_idx);


figure 
scatter(sel_1,sel_2)

figure
hold on 
plot(sel_1,'Linewidth',1.2)
plot(sel_2,'Linewidth',1.2)
hold off
legend('original data', 'lowpass+delayed data')
xlabel('time bins')
ylabel('spike per bins')




xlabel('original data')
ylabel('lowpass+delayed data')

figure 
scatter(sel_1/max(se),0.6*sel_1)

%%
close all
v_gain =0.5;
v_delay =50;
cut_off =1;
[sel_1_n,y_out,y_non_filter]= adapt_mod(fr1,v_gain,v_delay,up_fact,cut_off);
% scatter(sel_1_n,y_non_filter)