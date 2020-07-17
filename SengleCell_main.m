close all
clear all
clc
%main process
hmmg=[];
oug=[];
load('mega.mat')
%to check how many g values are there in the Hmm and OU
for i=1:length(mega)
    temp = mega{1,i};
    es =length(temp);
    for j=1:es%add in noise step data later
        if strcmp(temp(j).meta.displayName,'HMM Single')
            hmmg =[hmmg temp(j).meta.correlationTime];
        elseif strcmp(temp(j).meta.displayName,'OU Single')
            oug =[oug temp(j).meta.correlationTime];
        end
    end
end
hmmg_u = unique(hmmg);
oug_u = unique(oug);

%% cell type identification(human eye for now)
close all
type = 99*ones(1,size(mega,2));
for i=1:length(mega)
    temp = mega{1,i};
    es =length(temp);
    figure;
    hold on
    for j=1:es
        if strcmp(temp(j).meta.displayName,'Led Pulse')
            plot(temp(j).epoch)
        end
    end
    hold off
    type(i) = input('cell type?')
    %on ststain = 1
    %on transiant = 2
    %off sustain =3
    %off transiant =4
    %unknown =5
end
cabinet.type=input('cell type?');
%% make them into a sorted megafile
cabinet.hmm=cell(2,length(hmmg_u));
for k = 1:length(hmmg_u)
    target = hmmg_u(k);
    cabinet.hmm{2,k} = target;
    for i=1:length(mega)%cell id there is an error here
        temp = mega{1,i};
        es =length(temp);
        for j =1:es%all the epochs
            if strcmp(temp(j).meta.displayName,'HMM Single') & temp(j).meta.correlationTime==target
                temp(j).id=i;
                cabinet.hmm{1,k} =  [cabinet.hmm{1,k}; temp(j)];
            end
        end
    end
end

cabinet.ou=cell(2,length(oug_u));

for k = 1:length(oug_u)
    target = oug_u(k);
    cabinet.ou{2,k} = target;
    for i=1:length(mega)%cell id 
        temp = mega{1,i};
        es =length(temp);
        for j =1:es%all the epochs
            if strcmp(temp(j).meta.displayName,'OU Single') & temp(j).meta.correlationTime==target
                temp(j).id=i;%i th cell
                cabinet.ou{1,k} =  [cabinet.ou{1,k}; temp(j)];
            end
        end
    end
end







