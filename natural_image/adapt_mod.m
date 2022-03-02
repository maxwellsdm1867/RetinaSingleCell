function[sel_1_n,y_out,y_non_filter]= adapt_mod(fr1,v_gain,v_delay,up_fact,cut_off)
h1 = gaus_smooth(fr1,up_fact);%gaussian kernal smoothing
y = interp(lowpass(fr1,cut_off,100),up_fact);%low pass and upsample

sel_idx = unique([find(h1>0.01) find(y>0.01)]);%where there is activity 
sel_1 = h1(sel_idx);
sel_2 = y(sel_idx);

sel_1_n = sel_1/max(sel_1);%up sampled firing rate(normalized)
sel_2_n = sel_2/max(sel_2);%filtered data(normalized)

y_delay = [zeros(1,v_delay) sel_2_n(1:end-v_delay) ];%zero padding, creating a delay
y_out = v_gain*(y_delay );
y_non_filter =v_gain*[zeros(1,v_delay) sel_1_n(1:end-v_delay) ];


figure
hold on 
plot(sel_1_n,'Linewidth',1.2)
plot(y_out,'Linewidth',1.2)
hold off
legend('original data', 'lowpass+delayed data')
xlabel('time bins')
ylabel('Normilzed spikes per bins')
ylim([0,1])
saveas(gca,['gain_' num2str(v_gain) '_delay_' num2str(v_delay) '_cutoff_' num2str(cut_off) '_comp.jpg'])

figure 
scatter(sel_1_n,y_out)
xlim([0 1])
ylim([0 1])
xlabel('original data')
ylabel('lowpass+delayed data')
saveas(gca,[ 'gain_' num2str(v_gain) '_delay_' num2str(v_delay) '_cutoff_' num2str(cut_off) '_scat.jpg'])

end