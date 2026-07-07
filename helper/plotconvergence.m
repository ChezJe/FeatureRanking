% Plot convergence of sensitivity results stored in cell arrays.
% Each variable must be a cell array whose first cell contains a table with
% variables Parameter, Sobol, MPGSA, and Elementary effects.

function plotconvergence

load resultsGSA.mat
resultVars = ["results1000","results5000","results10000","results1000P", "results2000P", "results3000P", "results4000P", "results5000P"];
sampleSizes = [[1000, 5000, 10000],[1000,2000,3000,4000,5000]*44];
methodNames = ["Sobol", "MPGSA", "Elementary effects"];

resultTables = cell(numel(resultVars), 1);
for i = 1:numel(resultVars)
    x = eval(resultVars(i));
    resultTables{i} = x{1};
end

paramNames = strings(0, 1);
for i = 1:numel(resultTables)
    paramNames = [paramNames; string(resultTables{i}.Parameter)]; %#ok<AGROW>
end
paramNames = unique(paramNames, "stable");
nParams = numel(paramNames);

valuesByMethod = cell(numel(methodNames), 1);
for m = 1:numel(methodNames)
    Y = NaN(numel(sampleSizes), nParams);

    for i = 1:numel(resultTables)
        T = resultTables{i};
        paramsHere = string(T.Parameter);
        [tf, loc] = ismember(paramNames, paramsHere);
        Y(i, tf) = T{loc(tf), char(methodNames(m))};
    end

    valuesByMethod{m} = Y;
end

fig = figure();
fig.Name="Convergence of sensitivity results by parameter";
fig.Color="w";
fig.Position(3:4) = [1200, 500]; 

t = tiledlayout(fig, 1, numel(methodNames), TileSpacing="compact", Padding="compact");
title(t,"Convergence of results by parameter and method");
xlabel(t,"Number of samples");
ylabel(t,"Score");

mylinestyles = ["-o"; "-.x"; "--*";":v"];

for m = 1:numel(methodNames)
    ax = nexttile(t);
    if m==2
        xvalues = sampleSizes*(44+2);
    else
        xvalues = sampleSizes;
    end
    loglog(ax, xvalues, valuesByMethod{m}, LineWidth=2);
    ax.LineStyleOrder = mylinestyles;
    ax.ColorOrder = get_cmap();

    grid(ax, "on");
    box(ax, "on");
    xlim(ax, [min(xvalues) max(xvalues)]);
    xticks(ax, xvalues);
    xticklabels(ax,xvalues*1e-3);
    xtickangle(ax,60);
    xsecondarylabel(ax,"\times 10^3")
    ax.XAxis.FontSize = 8;
    title(ax, methodNames(m), Interpreter="none");

end

lgd = legend(ax, paramNames, Interpreter="none", NumColumns=2);
lgd.Layout.Tile = "east";
end

function cmap = get_cmap()
cmap = [
    1.0000    0.3673    0.4132
    0.9543    0.4922    0.1486
    0.7364    0.6082         0
    0.4447    0.6842    0.0885
    0    0.7241    0.3907
    0    0.7386    0.6900
    0    0.7300    0.9621
    0    0.6879    1.0000
    0.3348    0.5981    1.0000
    0.8406    0.4644    0.9639
    1.0000    0.3461    0.6985];

end