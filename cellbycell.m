%this is for generating the figures for one condition for one cell type
close all
clear all
clc

tar = 3;
load('hmm_r.mat')
load('ou_r.mat')
%%
type{1,1}= 'cone biploar';
type{1,2}= 'cone biploar';
type{1,3}= 'cone biploar';

close all
for cell_id = 1:length(type)
    figure('units','normalized','outerposition',[0 0 1 1])
    hold on
    sk = [];
    parm = [];
    for hmm_i = 1:size(hmm_r,2)%get the color scheme
        tempz = hmm_r{1,hmm_i};
        for k = 1:length(tempz)%one g-value
            if tempz(k).ID == cell_id
                sk = [sk 0];%0 is hmm
                parm = [parm hmm_r{2,hmm_i} ];
            end
        end
    end
    n_colors = sum(sk==0);
    colors = distinguishable_colors(n_colors);
    ci = 0;
    for hmm_i = 1:size(hmm_r,2)
        tempz = hmm_r{1,hmm_i};
        for k = 1:length(tempz)%one g-value
            if tempz(k).ID == cell_id
                ci = ci+1;
                plot(hmm_r{3,1},tempz(k).MI,'LineWidth',1.5, 'Color',colors(ci,:))
            end
        end
    end
    
    for ou_i =1:size(ou_r,2)
        tempy = ou_r{1,ou_i};
        for ck = 1:length(tempy)
            if tempy(ck).ID == cell_id
                %plot(ou_r{3,1},tempy(ck).MI,'--','LineWidth',1.2,'Color',colors(ci,:))
                sk = [sk 1];%1 is ou
                parm = [parm ou_r{2,ou_i} ];
            end
        end
    end
    
    n_colors = sum(sk==1);
    colors = distinguishable_colors(n_colors);
    ci = 0;
    
    for ou_i =1:size(ou_r,2)
        tempy = ou_r{1,ou_i};
        for ck = 1:length(tempy)
            if tempy(ck).ID == cell_id
                ci = ci+1;
                plot(ou_r{3,1},tempy(ck).MI,'--','LineWidth',1.2,'Color',colors(ci,:))
            end
        end
    end
    tmpn = cell(1,length(parm));
    for n = 1:length(parm)
        if sk(n)== 0
            tmpn{1,n}= ['HMM,G=' num2str(parm(n)) ];
        elseif sk(n)==1
            tmpn{1,n}= ['OU,G=' num2str(parm(n)) ];
        end
    end
    legend(tmpn)
    
    xlim([-2000 2000])
    hold off
    xlabel('time shift(ms)')
    ylabel('bit/sec')
    title(['cell' num2str(cell_id) ' type ' type{1,cell_id}])
    xline(0,'-','DisplayName','zero time shift');
    saveas(gcf,['type' type{1,cell_id} 'cell' num2str(cell_id) '.jpg'])
    
end
