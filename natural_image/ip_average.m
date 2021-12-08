function output = ip_average(input_image, background_level)
%does average to the imput image, and this includes the mean 
%   compute the average of the image and add in the back ground intensity 
 im_reshape = reshape(input_image,[],1);
 output = mean(im_reshape)+background_level;

end

