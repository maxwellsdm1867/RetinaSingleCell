function output = ip_contast(input_image, background_level)
%does average to the imput image, and this includes the mean
%   compute the average of the image and add in the back ground intensity
im_reshape = reshape(input_image,[],1);
output1 = mean(im_reshape)+background_level;
output2 = std(im_reshape);
output = output2/(output1 +background_level);
end
