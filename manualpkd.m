
for j = 1:2
    tempz = results{1,j};
    for i = 1:length(tempz)
        figure
        plot(results{3,1},tempz(i).MI)
        vline(0)
%         tempz(i).dps = input('double peak?');
%         tempz(i).fp = input('first peak');
%         tempz(i).sp = input('second peak');%[0,0]if there is only one peak;
    end
    results{1,j}= tempz  ;
end




