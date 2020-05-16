clc;
myfolder='C:\Users\Konafa\Desktop\Currency Counter-20200510T001140Z-001\Currency Counter\TestCases\1. Upright front-back Single';
filePattern = fullfile(myfolder, '*.jpg');
jpgFiles = dir(filePattern);
Data=zeros(16,10);
for i=1:length(jpgFiles)
    
    baseFileName = jpgFiles(i).name;
    fullFileName = fullfile(myfolder, baseFileName);
    fprintf(1, 'Now reading %s\n', fullFileName);
    Image=imread(fullFileName);
    Gray_img=rgb2gray(Image);
    features=extractLBPFeatures(Gray_img,'Upright',false);
    Data(i,:)=features; 
    drawnow; % Force display to update immediatel
end    
disp(Data)

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% testcase-2

[file,path]=uigetfile('*.jpg','*.jpg');
img=imread(fullfile(path,file));
Gray_img3=rgb2gray(img);
BW=imbinarize(Gray_img3,0.999);
inversed=~bwareaopen(BW,3000);
figure,imshow(inversed);
temp=medfilt2(inversed,[10,10]);
se=strel('diamond',180);
se2=strel('rectangle',[10,20]);
eroded_img=imopen(temp,se);
new=imerode(eroded_img,se2);
[label,num ]=bwlabel(new);
figure,imshow(eroded_img);
figure,imshow(new);
disp(num)

statsobj=regionprops(label,'BoundingBox','Orientation');
% angle=statsobj.Orientation;
% rotate_img=imrotate(Gray_img3,-angle,'bicubic','crop');
% figure,imshow(rotate_img);

cumCurrancy=0;
for i= 1:num
    
    x=uint64(statsobj(i).BoundingBox(1));
    y=uint64(statsobj(i).BoundingBox(2));
    w=statsobj(i).BoundingBox(3);
    h=statsobj(i).BoundingBox(4);
    angle=statsobj(i).Orientation;
   
%     if i==1
%          cut=imcrop(new,[x,y,w,h]);
%            figure,imshow(cut);
%          cut_new
%      end 
    note=imcrop(Gray_img3,[x,y,w,h]);
    figure,imshow(note);
%     final_img=imrotate(note,-angle,'bicubic','crop');
%     
%     [h,w]=size(final_img); 
%     
%     for k=1:h
%         for l=1:w
%             if(final_img(k,l)==255)
%                 final_img(k,l)=0;
%                 
%             end   
%         end  
%          
%     end
%    
%    
%     final_img=imresize(final_img,[361 ,701]);
%     [label,num ]=bwlabel(final_img);
%     disp(num)
%    
%       final_img=imcrop(final_img,[39.5100   85.5100  620.9800  192.9800]);
%      figure,imshow(final_img);
%    
    Casefeatures=extractLBPFeatures(note,'Upright',false);
   
    Distance=zeros(1,16);

    for j=1:length(Data)

        Distance(1,j)=sqrt((Casefeatures(1,1)-Data(j,1))^2+(Casefeatures(1,2)-Data(j,2))^2+(Casefeatures(1,3)-Data(j,3))^2+(Casefeatures(1,4)-Data(j,4))^2+(Casefeatures(1,5)-Data(j,5))^2+(Casefeatures(1,6)-Data(j,6))^2+(Casefeatures(1,7)-Data(j,7))^2+(Casefeatures(1,8)-Data(j,8))^2+(Casefeatures(1,9)-Data(j,9))^2+(Casefeatures(1,10)-Data(j,10))^2);
    end    
   
    [val,col]=min(Distance);

    fprintf(1, 'Min value= %s\n', int2str(val));
    fprintf(1, 'column: %s\n',int2str(col));

    Currancies=[0.5,0.5,1,1,10,10,100,100,20,20,200,200,5,5,50,50];
    % disp(Currancies);


    cumCurrancy=cumCurrancy+Currancies(1,col);
    fprintf(1, 'Total currancy= %s\n',num2str(cumCurrancy));


 end  
