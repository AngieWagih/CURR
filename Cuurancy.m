clc;
Mypath='C:\Users\Konafa\Desktop\Currency Counter-20200510T001140Z-001\Currency Counter\TestCases\1. Upright front-back Single';
Data=Generate_Dataset(Mypath);
Gray_img2=get_image();
cumCurrancy=Identify_curr(Data,Gray_img2);
fprintf(1, 'Total currancy= %s\n',num2str(cumCurrancy));

Total_curr=get_Totalcurr(Data);
fprintf(1, '*all_non_intersect case* Total currancy= %s\n',num2str(Total_curr));

Total_curr2=get_Totalcurr2(Data);
fprintf(1, '*all_non_intersect_Rotatedcase* Total currancy= %s\n',num2str(Total_curr2));

Total_curr3=get_Totalcurr3(Data);
fprintf(1, '*all_intersect case* Total currancy= %s\n',num2str(Total_curr3));

Total_curr6=get_Totalcurr6(Data);
fprintf(1, '*noise case* Total currancy= %s\n',num2str(Total_curr6));


function[Data]=Generate_Dataset(path)

myfolder=path;
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
  
end
end

function[Gray_img]=get_image()
[file,path]=uigetfile('*.jpg','*.jpg');
 img=imread(fullfile(path,file));
 Gray_img=rgb2gray(img);
end


function[cumCurrancy]=Identify_curr(Data,Gray_img2)
    
    Casefeatures=extractLBPFeatures(Gray_img2,'Upright',false);
%     disp(Casefeatures);

    Distance=zeros(1,16);

    for j=1:length(Data)
   
       Distance(1,j)=sqrt((Casefeatures(1,1)-Data(j,1))^2+(Casefeatures(1,2)-Data(j,2))^2+(Casefeatures(1,3)-Data(j,3))^2+(Casefeatures(1,4)-Data(j,4))^2+(Casefeatures(1,5)-Data(j,5))^2+(Casefeatures(1,6)-Data(j,6))^2+(Casefeatures(1,7)-Data(j,7))^2+(Casefeatures(1,8)-Data(j,8))^2+(Casefeatures(1,9)-Data(j,9))^2+(Casefeatures(1,10)-Data(j,10))^2);
    end    
%     disp(Distance);

   [val,col]=min(Distance);

   fprintf(1, 'Min value= %s\n', int2str(val));
   fprintf(1, 'column: %s\n',int2str(col));

   Currancies=[0.5,0.5,1,1,10,10,100,100,20,20,200,200,5,5,50,50];

   cumCurrancy=0;
   cumCurrancy=cumCurrancy+Currancies(1,col);
    
end


function[Total_curr]=get_Totalcurr(Data)
    Gray_img=get_image();
    BW=imbinarize(Gray_img,0.999);
%     figure,imshow(BW);
%     inverted_BW=~BW;
    [label,num ]=bwlabel(~BW);
    statsobj=regionprops(label,'BoundingBox');
    Total_curr=0;
    for i= 1:num
        x=uint64(statsobj(i).BoundingBox(1));
        y=uint64(statsobj(i).BoundingBox(2));
        w=statsobj(i).BoundingBox(3);
        h=statsobj(i).BoundingBox(4);
        note=imcrop(Gray_img,[x,y,w,h]);
%         figure,imshow(note);
        
        Total_curr=Identify_curr(Data,note)+Total_curr;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Rotation

function[Total_curr2]=get_Totalcurr2(Data)
    Gray_img=get_image();
    BW=imbinarize(Gray_img,0.999);
%     figure,imshow(BW);
    inverted_BW=~BW;
    temp=medfilt2(inverted_BW,[5,5]);
    [label,num ]=bwlabel(temp);
    statsobj=regionprops(label,'BoundingBox','Orientation');
    Total_curr2=0;
    for i= 1:num
        x=uint64(statsobj(i).BoundingBox(1));
        y=uint64(statsobj(i).BoundingBox(2));
        w=statsobj(i).BoundingBox(3);
        h=statsobj(i).BoundingBox(4);
        angle=statsobj(i).Orientation;%get angle of rotation
        
        note=imcrop(Gray_img,[x,y,w,h]);
%         figure,imshow(note);
        final_img=imrotate(note,-angle,'bicubic','crop');%rotate the note
    
    [h,w]=size(final_img); 
    
    for k=1:h
        for l=1:w
            if(final_img(k,l)==255)
                final_img(k,l)=0;
                
            end   
        end  
         
    end
   
   
    final_img=imresize(final_img,[361 ,701]);
    
   
     final_img=imcrop(final_img,[39.5100   85.5100  620.9800  192.9800]);
%      figure,imshow(final_img);
        
        Total_curr2=Identify_curr(Data,final_img)+Total_curr2;
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Intersaction
function[Total_curr]=get_Totalcurr3(Data)
    Gray_img=get_image();
    BW=imbinarize(Gray_img,0.999);
%     figure,imshow(BW);
%     inverted_BW=~BW;
    se=strel('diamond',55);
    se2=strel('diamond',40);
%     figure,imshow(~BW);
    eroded_img=imopen(~BW,se);
    new=imclose(eroded_img,se2);
%     figure,imshow(new);
    [label,num ]=bwlabel(new);
    statsobj=regionprops(label,'BoundingBox');
    Total_curr=0;
    for i= 1:num
        x=uint64(statsobj(i).BoundingBox(1));
        y=uint64(statsobj(i).BoundingBox(2));
        w=statsobj(i).BoundingBox(3);
        h=statsobj(i).BoundingBox(4);
        note=imcrop(Gray_img,[x,y,w,h]);
%         figure,imshow(note);
        
        Total_curr=Identify_curr(Data,note)+Total_curr;
    end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Noisy

function[Total_curr6]=get_Totalcurr6(Data)
    Gray_img=get_image();
    BW=imbinarize(Gray_img,0.999);
    temp=medfilt2(BW,[3,3]);
    figure,imshow(temp);
    se=strel('square',160);
    dilated_img=imdilate(temp,se);
    figure,imshow(BW);
    figure,imshow(dilated_img);
    
    inverted_BW=~ dilated_img;
    figure,imshow(inverted_BW);
    [label,num ]=bwlabel(inverted_BW);
    disp(num)
   
    statsobj=regionprops(label,'BoundingBox');

    Total_curr6=0;
    for i= 1:num
        x=uint64(statsobj(i).BoundingBox(1));
        y=uint64(statsobj(i).BoundingBox(2));
        w=statsobj(i).BoundingBox(3);
        h=statsobj(i).BoundingBox(4);
        note=imcrop(Gray_img,[x,y,w,h]);
        figure,imshow(note);
        
        Total_curr6=Identify_curr(Data,note)+Total_curr6;
    end
end