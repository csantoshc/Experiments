function [uphits, downhits] = findthreshcrosses(signal,threshold,peakdist)
signalthresh = threshold;
clear abovethresh crosses upwardslopes uphits
abovethresh = find(signal>=signalthresh);
if ismember(1,abovethresh)
    abovethresh(abovethresh == 1) = [];% to account for ends of the signal
end
crosses = abovethresh(signal(abovethresh-1)<signalthresh);
upwardslopes = find(sign(diff(signal))>0);
uphits = intersect(crosses-1,upwardslopes) + 1;

clear abovethresh crosses downwardslopes downhits
abovethresh = find(signal>=signalthresh);
if ismember(length(signal),abovethresh)
    abovethresh(abovethresh == length(signal)) = [];% to account for ends of the signal
end
crosses = abovethresh(signal(abovethresh+1)<signalthresh);
downwardslopes = find(sign(diff(signal))<0);
downhits = intersect(crosses,downwardslopes);

if ~isempty(uphits) && ~isempty(downhits)
    %to ensure that there is an upswing before the first downswing and
    %vice-versa
    earliesthit = find(downhits<uphits(1));
    latesthit = find(uphits>downhits(end));
    if ~isempty(earliesthit)
        downhits(earliesthit) = [];
    end
    if ~isempty(latesthit)
        uphits(latesthit) = [];
    end

    % Remove transient spikes if necessary
    if length(uphits) ~= length(downhits)
        uphits(signal(uphits+1) < signalthresh) = [];
        downhits(signal(downhits-2) < signalthresh) = [];
        %to ensure that there is an upswing before the first downswing and
        %vice-versa
        earliesthit = find(downhits<uphits(1));
        latesthit = find(uphits>downhits(end));
        if ~isempty(earliesthit)
            downhits(earliesthit) = [];
        end
        if ~isempty(latesthit)
            uphits(latesthit) = [];
        end
    end

    idelete = zeros(size(uphits));
    for ihit = 1:length(uphits)
        if ~idelete(ihit)
            idelete(abs(uphits - uphits(ihit)) < peakdist & abs(uphits - uphits(ihit)) > 0) = 1;
        end
    end
    uphits(logical(idelete)) = [];
%     idelete = zeros(size(downhits));
%     for ihit = 1:length(downhits)
%         if ~idelete(ihit)
%             idelete(abs(downhits - downhits(ihit)) < peakdist & abs(downhits - downhits(ihit)) > 0) = 1;
%         end
%     end
%     downhits(logical(idelete)) = [];
%     uphits(diff(uphits) < peakdist) = [];
    downhits(diff(downhits) < peakdist) = [];
end
end
