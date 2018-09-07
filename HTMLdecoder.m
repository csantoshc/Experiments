%% HTML character decoder
function str = HTMLdecoder(inputstr)
x = inputstr;
y = regexp(x,'&#.*?;','match'); % ? makes it a lazy match, returns the first match it gets
n = size(y,2);
restStr = strsplit(x,y); % split the string removing the HTML codes
str = restStr{1};
for ii = 1:n
    code = y{ii}(3:end-1);
    decoded{ii} = char(str2double(code));
    if length(restStr) > n
        str = [str decoded{ii} restStr{ii+1}];
    else
        str = [str decoded{ii}];
    end
end