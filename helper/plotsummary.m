function plotsummary(scoreTable, varnameparameternames)

arguments
    scoreTable table
    varnameparameternames (1,1) string
end

scoreTable = movevars(scoreTable,varnameparameternames,"Before",1);
methodnames = string(scoreTable.Properties.VariableNames(2:end));

% Convert scores into ranks. Parameters with the same score will be assigned the same score. 
% For example, MRMR give a score of 0 to most parameters except for 3. So, in the case ranks will go from 1 to 4 only.
rankTable = [scoreTable(:,varnameparameternames), varfun(@score2rank, scoreTable(:,2:end))];
rankTable.Properties.VariableNames = erase(rankTable.Properties.VariableNames, "score2rank_");

% Sort the results tables according to the cumulative rank (=sum of ranks across all methods).
cumulatedRanks = sum(rankTable{:,2:end},2);
[~, idx] = sort(cumulatedRanks, "descend");

rankTable = rankTable(idx,:);
scoreTable = scoreTable(idx,:);

% Plot results
N = numel(methodnames);
colors = getcolors(N);
graycolor = 0.7*ones(1,3);

f = figure;
f.Position(3:4) = [1200, 800]; 
tl = tiledlayout(1, N+4, TileSpacing="tight");

if theme(f).Name=="Dark Theme"
  colors = fliplightness(colors);
  graycolor = fliplightness(graycolor);
end

% One plot for each method to display the parameter scores.
for i = 1:N
    ax = nexttile(tl);
    method = methodnames(i);
    if i==1
        b = barh(ax,scoreTable,"Parameter",method, EdgeColor="none");
        ax.YAxis.TickLabelInterpreter = "none";
    else
        b = barh(ax,scoreTable, method, EdgeColor="none");
        yticks(1:height(scoreTable));
        yticklabels(string.empty);
    end
    b.FaceColor = graycolor;
    xlabel(ax,"Score");
    grid(ax,'on');
    tObj = title(ax,split(method,' - '));
    tObj.Color = colors(i,:);
end

limits = ylim(ax);

% One plot to display the parameter's individual ranks.
ax = nexttile(tl,[1,2]);

barh(ax, 1:height(rankTable), rankTable{:,methodnames},'grouped',EdgeColor="none");
colororder(ax,colors);
yticks(ax, 1:height(rankTable));
yticklabels(ax, string.empty);
ylim(ax, limits);
ylabel(ax, string.empty);
xlabel(ax, "Rank");
title(ax, "Individual ranks")

% One plot to display the parameter's cumulative rank.
ax = nexttile(tl,[1,2]);

barh(ax, 1:height(rankTable), rankTable{:,methodnames},'stacked',EdgeColor="none");
colororder(ax,colors);
ax.YAxisLocation = 'right';
yticks(ax, 1:height(rankTable));
yticklabels(ax, rankTable.Parameter);
ax.YAxis.TickLabelInterpreter = "none";
ylim(ax, limits);
ylabel(ax, string.empty);
xlabel(ax, "Cumulated rank");
title(ax, "Sum of ranks")

end % plotsummary


function ranks = score2rank(scores)
[~,~,ranks]=unique(scores,"sorted","last");
ranks = max(ranks) - ranks + 1; % start ranks with 1
end % score2rank

function colors = getcolors(N)
switch N
    case 2
        colors = [    1.0000    0.3673    0.4132
            0    0.7375    0.8344];
    case 3
        colors = [
            1.0000    0.3673    0.4132
            0.0282    0.7141    0.2944
            0    0.6637    1.0000];
    case 4
        colors = [    1.0000    0.3673    0.4132
            0.5270    0.6690         0
            0    0.7375    0.8344
            0.5171    0.5678    1.0000];
    case 5
        colors = [    1.0000    0.3673    0.4132
            0.6845    0.6267         0
            0    0.7325    0.5093
            0    0.7098    1.0000
            0.7721    0.4931    1.0000];
    case 6 
        colors = [    1.0000    0.3673    0.4132
            0.7777    0.5915         0
            0.0282    0.7141    0.2944
            0    0.7375    0.8344
            0    0.6637    1.0000
            0.8903    0.4407    0.9246];
    case 7
        colors = [    1.0000    0.3673    0.4132
            0.8389    0.5629         0
            0.3923    0.6918    0.1392
            0    0.7366    0.6041
            0    0.7221    1.0000
            0.1444    0.6141    1.0000
            0.9560    0.4050    0.8578];
    case 8
        colors = [    1.0000    0.3673    0.4132
            0.8816    0.5397    0.0061
            0.5270    0.6690         0
            0    0.7271    0.4274
            0    0.7375    0.8344
            0    0.6955    1.0000
            0.5171    0.5678    1.0000
            0.9959    0.3808    0.8047];
    case 9
        colors = [    1.0000    0.3673    0.4132
            0.9127    0.5208    0.0779
            0.6175    0.6471         0
            0.0282    0.7141    0.2944
            0    0.7380    0.6568
            0    0.7273    0.9871
            0    0.6637    1.0000
            0.6732    0.5274    1.0000
            1.0000    0.3645    0.7620];
    case 10
        colors =[    1.0000    0.3673    0.4132
            0.9361    0.5052    0.1191
            0.6845    0.6267         0
            0.3269    0.6994    0.1880
            0    0.7325    0.5093
            0    0.7375    0.8344
            0    0.7098    1.0000
            0    0.6305    1.0000
            0.7721    0.4931    1.0000
            1.0000    0.3535    0.7272];
    otherwise
        colors = parula(N);
end % getcolors


end