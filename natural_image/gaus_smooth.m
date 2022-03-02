function h1 = gaus_smooth(fr1,up_fact)
half_width = 150;
y = normpdf(-half_width:half_width,0);%[he gaussian filter
h1 = interp(conv(fr1,y,'same'),up_fact);%filter and up sample for x
end