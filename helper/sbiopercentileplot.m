function varargout = sbiopercentileplot(simresults, options)
% Creates a percentile plot of scan runs
%
% simresults: array of simdata
%
% Name: names of species to plot as cell array or string array.
% Ex: 'drug' or {'drug','complex'}
%
% Times: vector of double. Timepoints at which all simulations should be
% resampled to be synchronized. Resampling is required to be able to
% compute statistics over all simulations.
% Ex: 0:0.1:100
%
% Parent: axis where to plot
%
% Names: Vector of species or parameter names to plot.
%
% Times: Vector of times to use to compute the statistics.
%
% Alpha: Percent for percentiles between 0 and 1.
%
% Color: Matrix of RGB values between 0 and 1 with one row per species to
% plot.
%
%
% Example: sbiopercentileplot(simdataObj, Name=["Receptor","Complex"],Alpha=[0.05, 0.01])

% To do:
% - convert to ChartContainer using this example https://www.mathworks.com/help/releases/R2023a/matlab/creating_plots/chart-development-overview.html

arguments (Input)
    simresults   SimData {mustBeVector(simresults)}
    options.Name  string {mustBeVector(options.Name),mustBeInSimdata(options.Name,simresults)} = getStateNames(simresults)
    options.Times double {mustBeVector(options.Times)} = getTimes(simresults)
    options.Parent (1,1) {mustBeA(options.Parent,["matlab.ui.control.UIAxes","matlab.graphics.axis.Axes"])}
    options.Alpha  (1,:) double {mustBeInRange(options.Alpha,0,1)} = 0.05
    options.Color  (:,3) double {mustBeInRange(options.Color,0,1)} = double.empty
    options.YScale (1,1) string {mustBeMember(options.YScale,["linear","log"])} = "linear"
    options.Legend (1,1) string {mustBeMember(options.Legend,["on","off"])} = "on"
end


% turn off warning that shows up because of the workaround used to get
% the legend with both line and shade
warnS1 = warning('off', 'MATLAB:handle_graphics:exceptions:SceneNode');
warnS2 = warning('off', 'MATLAB:legend:DeprecationCompatibleLegend');
cleanupObj  = onCleanup(@() warning([warnS1;warnS2]));

% Input handling
times = options.Times(:);
speciesname = options.Name(:);
alpha = sort(options.Alpha,'descend');

if ~isempty(options.Color) && height(options.Color)~=numel(speciesname)
    error("Invalid name-value argument 'Color'. " + ...
        "You must specify as many colors as species to plot. " +...
        "Here, the color matrix should contain " + numel(speciesname) + " rows.")
end

% make sure simresults is a column vector
simresults = simresults(:);

% Resample data at tspan
simresults = resample(simresults, times);

% Keep only selected vars
simresults = selectbyname(simresults, speciesname);

% figure setup
if ~isfield(options,'Parent')
    ax = gca;
else
    ax = options.Parent;
    holdOn = ishold(ax);
end
hold(ax,'on');


nPatch = numel(alpha);
nSpec = numel(speciesname);
gObj = gobjects(nSpec*(nPatch+1),1);

% color palette
if isempty(options.Color)

    colors = [    1.0000    0.3673    0.4132
        0.8816    0.5397    0.0061
        0.5270    0.6690         0
        0    0.7271    0.4274
        0    0.7375    0.8344
        0    0.6955    1.0000
        0.5171    0.5678    1.0000
        0.9959    0.3808    0.8047];

else
    colors = options.Color; % user-defined colors
end


currentFig = ancestor(ax,'figure');
if isprop(currentFig,'LiveEditorRunTimeFigure') && get(currentFig,'LiveEditorRunTimeFigure')
    drawnow limitrate nocallbacks
end

% prepare results table
resultsTable = table(times,'VariableNames',"Time");

% compute and plot percentile
for i = 1:nSpec
    % Extract data for specified species
    [ ~, x] = selectbyname(simresults, speciesname(i)) ;

    % Plot
    valuesPlot = cell2mat(x');
    [lh,p,pctValues] = createPlot(ax,times,valuesPlot,speciesname(i),alpha, options.YScale, colors(i,:));
    gObj(((i-1)*(1+nPatch)+1):(i)*(1+nPatch)) = [lh;p(:)];

    resultsTable.(speciesname(i)) = pctValues;
end

% time units
timeunits = unique(string({simresults(:).TimeUnits}));
if isscalar(timeunits)
    timeunit = timeunits;
else
    timeunit = "mixed";
end

% data units
datainfos = get(simresults,'DataInfo');
datainfos = vertcat(datainfos{:});
dataunits = unique(string(cellfun(@(x) x.Units,datainfos,'UniformOutput',false)));
if isscalar(dataunits)
    dataunit = dataunits;
else
    dataunit = "mixed units";
end

% add legend and descriptions
hold(ax,'off');

if options.Legend == "on"
    addcustomlegend(ax, gObj);
end
xlabel(ax,"Time (" + timeunit + ")");
ylabel(ax,dataunit);

% define axes limits
if isMATLABReleaseOlderThan("R2021a")
    offsetFactor = 0.03;
    offset = offsetFactor*times(end);
    ax.XLim = offset*[-1,1]+[0, times(end)];

    minY = min(arrayfun(@(x) min(x.YData),ax.Children));
    maxY = max(arrayfun(@(x) max(x.YData),ax.Children));

    offset = offsetFactor*(maxY-minY);
    ax.YLim = offset*[-1,1]+[minY, maxY];

else
    ax.XLimitMethod = 'padded';
    ax.YLimitMethod = 'padded';
end

if isfield(options,'Parent')

    % restoring hold status if originally 'off'
    if ~holdOn
        hold(ax,'off');
    end

end

ax.YScale = options.YScale;

if nargout > 0
    varargout{1} = resultsTable;
end

end % sbiopercentileplot


%% Code for single Plot
function [lh,p,pctValues] = createPlot(ax,t,y,name,alpha, scale, color)

% sort alpha descending
alpha = unique(alpha);
alpha = sort(alpha, "descend");
percentiles = string(sort(100*[alpha, 1-alpha],'ascend'));

% Calculate median
med = median(y, 2);

% line for median first to get color following color order
lh = plot(ax,t, med, 'LineWidth', 1, 'Color',color);
lh.DisplayName = name;
hold(ax,'on');
nPatch = numel(alpha);
p = gobjects(nPatch,1);

pctValues = nan(numel(t),2*numel(alpha));

for i=1:nPatch
    % Calculate percentiles
    pctRange = 100*[alpha(i)/2,1-alpha(i)/2];
    pct = prctile(y, pctRange, 2);
    pctValues(:, [i,end-i+1]) = pct;

    % We remove the origin when conc=0 at t=0 and YScale='log'
    if scale == "log" && any(pct(1,:)==0)
        pct(1,:) = [];
        t(1) = [];
    end

    % percentiles as patch
    xconf = [t; flipud(t)] ;
    yconf = [pct(:,1); flipud(pct(:,2))];

    p(i) = fill(ax, xconf , yconf, 'black');
    p(i).FaceColor = lh.Color; % same color as line
    p(i).FaceAlpha = 0.25;
    p(i).EdgeColor = 'none';
    p(i).DisplayName = string.empty;
end

% change order to get line on top
ax.Children(1:1:(1+nPatch)) = ax.Children((1+nPatch):-1:1);

% return result table
pctValues = array2table(pctValues,'VariableNames',percentiles);

end % createPlot

function times = getTimes(simresults)
% common data points (should include dosing times)
ref = simresults(1).Time;
for i=2:numel(simresults)
    ref = intersect(ref,simresults(i).time);
end % 

% interpolate 1000 points between 0 and stoptime
numPoints = 1e3;
timeStart = simresults(1).Time(1);
timeEnd = simresults(1).Time(end);
times = linspace(timeStart, timeEnd, numPoints);

% make sure final vector contains commun time points
times = union(times, ref,'sorted');
end % getTimes

function allnames = getStateNames(simresults)

% get all state names
allnames = string([simresults(1).DataNames]);

% convert the species to compartment.species format to make sure they are
% unique
type = string(cellfun(@(x) x.Type, simresults(1).DataInfo, 'UniformOutput', false));

idxSpecies = type == "species";
if any(idxSpecies)
    speciesInfo  = [simresults(1).DataInfo{idxSpecies}];
    speciesInfo  = struct2table(speciesInfo,"AsArray",true);
    speciesnames = string(speciesInfo.Compartment) + "." + string(speciesInfo.Name);

    % modify species names in list
    allnames(idxSpecies) = speciesnames;
end
end % getStateNames

function mustBeInSimdata(name,simresults)
validnames = getStateNames(simresults);
name = string(name);
tf = ~ismember(name, validnames);

if any(tf)
    eid = 'Names:wrongName';
    msg = "Data for '" + strjoin(name(tf),"', '") + "' not available in SimData objects.";
    throwAsCaller(MException(eid,msg))
end 
end % mustBeInSimdata

function addcustomlegend(ax, gObj)

[lgd,icons] = legend(ax,gObj,'Interpreter','none','Visible','on'); %#ok<LEGMOP>
lgd.Location = 'eastoutside';
lgd.Box = 'off';
lgd.AutoUpdate = "off"; 
lgd.HitTest = 'off';

% correct patches in legend
patches = findobj(icons,'Type','Patch');
set(patches, 'FaceAlpha',0.25);

% find lines
alllineIdx = find(arrayfun(@(x) (x.Type=="line"),icons));
dataSize   = arrayfun(@(x) numel(x.XData),icons(alllineIdx));
lineIdx    = alllineIdx(dataSize>1); 
lineIdx    = [lineIdx;numel(icons)+1];

for k = 1:numel(lineIdx)-1
    iconLine  = icons(lineIdx(k));
    newcenter = iconLine.YData(1);
    % each patch is resized incrementally so that the different
    % percentiles are visible in the legend too
    nPatch = (lineIdx(k+1)) - (lineIdx(k)+2);
    numCurrentPatch = 1;
    for l=(lineIdx(k)+2):(lineIdx(k+1)-1)
        iconPatch = icons(l);
        oldcenter = mean(iconPatch.Vertices(1:2,2));
        iconPatch.Vertices(:,2) = iconPatch.Vertices(:,2) + (newcenter-oldcenter);

        % augment all patch size by 50% and decrease size depending on which patch number it is
        sizePatch = diff(iconPatch.Vertices(1:2,2));
        offset = 1.5*sizePatch*(numCurrentPatch-1)/(nPatch);
        iconPatch.Vertices([1,4],2) = iconPatch.Vertices([1,4],2)+0.5*offset-0.25*sizePatch;
        iconPatch.Vertices([2,3],2) = iconPatch.Vertices([2,3],2)-0.5*offset+0.25*sizePatch;

        numCurrentPatch = numCurrentPatch + 1;
    end
end

end % addcustomlegend