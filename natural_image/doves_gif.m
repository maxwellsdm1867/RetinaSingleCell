function [sel_1,sel_2] = doves_gif(fr1,fr2,save_path,up_fact,xl,yl)
cd(save_path)
half_width = 150;
y = normpdf(-half_width:half_width,0);%[he gaussian filter
h1 = interp(conv(fr1,y,'same'),up_fact);%filter and up sample for x
h2 = interp(conv(fr2,y,'same'),up_fact);%filter and up sample for y

%take out the sclience part
sel_idx = unique([find(h1>0.01) find(h2>0.01)]);%where there is activity 
sel_1 = h1(sel_idx);
sel_2 = h2(sel_idx);
tic 
parfor i =1:length(sel_idx)
figure%('units','normalized','outerposition',[0 0 1 1])
scatter(sel_1,sel_2)
xlabel(xl)
ylabel(yl)
hold on
scatter(sel_1(i),sel_2(i), 'filled')
saveas(gca, [num2str(100000+i) '.jpg'])
close
end
toc



end