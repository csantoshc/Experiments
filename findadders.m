%% Recursive function to obtain all possible combinations to add upto a certain number
%% with limits of number of adders and candidate adders

%% Santosh Chandrasekaran, 2017

function adders = findadders(N,numofadders,candidates,repeats,nozeros)
% N                 : the sum to be achieved
% numofadders       : the number of entities that have to be added to get N
% candidates        : the interval in whoch your candidates hae to be chosen from
% repeats           : 1 for allowing repeats; 0 for not allowing repeats among candidates
% nozeros           : 1 for allowing 0 to be among the candidates; 0 for not allowing 0
% e.g. output = findadders(65,5,1:25,0,1);

Sum = N;
candidateList = sort(candidates(candidates<=Sum));
candidates = candidateList;
if Sum < 0
    adders = [];
    return
end
if numofadders == 1
    adders = candidateList(candidateList == Sum);
else
    for i = 1:length(candidates)
        candidateList = candidates;
        newsum = Sum - candidates(i);
        if ~repeats
            candidateList(i) = [];
        end
        if isempty(candidateList)
            continue
        end
        if newsum < 0 || (nozeros && newsum == 0)
            break
        end        
            
        numofadders = numofadders - 1;        
        if (repeats && newsum > numofadders*max(candidates)) || (~repeats && newsum > sum(candidateList(end-numofadders+1:end)))
            numofadders = numofadders + 1;
            continue
        end
        if newsum == 0 && numofadders >= 1
            if exist('adders','var')
                adders = [adders;[zeros(1,size(adders,2)-1) candidates(i)]];
            else
                adders = [zeros(1,numofadders) candidates(i)];
            end
            return
        else       
            %do things            
            nextcandidate = candidates(i);
            if numofadders ~= 0 && newsum>0       
                subadders = findadders(newsum,numofadders,candidateList,repeats,nozeros);
                if isempty(subadders)
                    numofadders = numofadders + 1;
                    continue
                end
                if exist('adders','var')
                    adders = [adders;[subadders repmat(nextcandidate,size(subadders,1),1)]];
                else
                    adders = [subadders repmat(nextcandidate,size(subadders,1),1)];
                end                
            end
        end
        numofadders = numofadders + 1;
    end
    if ~exist('adders','var')
        adders = [];
    end
end
end