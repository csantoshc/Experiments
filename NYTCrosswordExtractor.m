clear all
clc
dateinput = inputdlg('Enter date (yyyy-mm-dd) or just type today');

if strcmp(dateinput{1},'today') == 1
    dateinput{1} = datestr(date,29);
end
dateparsed = regexp(dateinput{1},'-','split');
year = dateparsed{1};
month = dateparsed{2};
chosendate = dateparsed{3};

if strcmp(chosendate,'01') == 1
    corrmonth = str2double(month) - 1;
    if corrmonth < 10
        correction = '0';
    else
        correction = '';
    end
    monthcorrected = [correction num2str(corrmonth)];
else
    monthcorrected = month;
end
crosswordurl = ['http://www.nytcrossword.com/' year '/' monthcorrected '/' month chosendate '-' year(end-1:end) '-new-york-times-crossword.html'];
page = urlread(crosswordurl); % Reads in the whole webpage
% web(['http://www.nytcrossword.com/2013/11/' date '-13-new-york-times-crossword.html']) % Reads in the whole webpage
%% Reads in and parses the clues
disp('Parsing the Webpage...')
firstmarker = strfind(page,'For the sake of'); %Searches for that particular string (occurs before the clues)
startpt = strfind(page(firstmarker:end),'Across') + firstmarker - 1;
lastmarker = strfind(page(firstmarker:end),'Return to top of page') + firstmarker; %Searches for that particular string (occurs after the clues)
endpt = lastmarker - 2;
unparsed = page(startpt:endpt);
parseone = regexp(unparsed,'<\w+.*?>','split'); % Removes HTML tags
disp('Extracting the clues and answers...')
for(parsed = 1:length(parseone))
    cluesandans{parsed,:} = regexp(parseone{parsed},' : ','split');
    clues{parsed} = cluesandans{parsed}{1}; % Contains the clues
    if size(cluesandans{parsed},2) > 1
        answers{parsed} = cluesandans{parsed}{2};
    else
        answers{parsed} = []; % Contains the answers
    end
end
%% Reads in the Crossword Image
disp('Extracting the crossword image...')
marker = strfind(page,'image_src'); %Searches for that particular string (occurs before the clues)
marker2 = strfind(page,'QuickLinks'); %Searches for that particular string (occurs before the clues)
clear startpt
startpt = max(strfind(page(1:marker),'http'));

% Check if image link is to a PNG file
formatMarker = min(strfind(page(startpt:marker2(1)),'png'));
if isempty(formatMarker)
    formatMarker = min(strfind(page(startpt:marker2),'jpg'));
end
endpt = startpt + formatMarker + 1;
imageurl = page(startpt:endpt); % Finds the Crossword image URL
format = imageurl(end-2:end);
switch format
    case 'png'
        [tempimg,map,alpha] = imread(imageurl); % Reads in the image
    case 'jpg'
        tempimg = imread(imageurl); % Reads in the image
        alpha = [];
end

if isempty(alpha)
    Crossword = tempimg; % No transparency data
else
    Crossword = imcomplement(alpha);% The usable image is in the transparency data
end
figure, imshow(Crossword)
title(['The NY Times Crossword published on ' datestr(dateinput)])
pause(1)
%% Clears the Crossword up - using height of characters
disp('Cleaning up...')
bwthresh = 160;
minsize = 9;
maxsize = 15; %Height of letters is 11 pixels
close all
clear temp
temp = Crossword(:,:,1);
% figure,imshow(temp)
temp(temp < bwthresh) = 0;
temp(temp > bwthresh) = 1; % Binarizing the image
[Labeled, number] = bwlabel(1-(temp)); % Inverting the image and then labeling regions
% figure,imshow(Labeled)
regions = regionprops(Labeled,'PixelIdxList','Extrema','MajorAxisLength'); % Calculating properties of labeled regions
for(iter = 1:number)
%     if regions(iter).MajorAxisLength > minsize && regions(iter).MajorAxisLength < maxsize
    height = abs(regions(iter).Extrema(5,2) - regions(iter).Extrema(2,2)); % Computes height of regions
%     heights(iter) = height;
    if height > minsize && height < maxsize 
       Labeled(regions(iter).PixelIdxList) = 0; % Regions of certain height colored black
    end
end
% figure,imshow(1 - Labeled)
BlankCrossword = 1 - Labeled;
%% Save
baseDir = 'C:\Users\Santosh\Pictures\Crosswords\';
figure,imshow(BlankCrossword)
export_fig([baseDir 'NYTCrossword_' char(dateinput) '.png'],'-native')
close all
disp('Done!')
%%
fid = fopen([baseDir 'NYTCrossword_' char(dateinput) '.txt'],'w');
for iclue = 1:length(clues)
    fprintf(fileID,'%s',clues{iclue});
end
fclose(fid)