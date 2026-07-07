function componentsObj = getFreeParameters(model)

% free parameters = compartment volumes + constant parameters without
% initial assign + non-constant parameters or species defined with rate
% rules only + parameters or species not defined by algebraic rule
% <->
% free parameters ~= non-constant parameters without rate rule + species
% defined with initial or repeated assign

% get all components
allComponents = sbioselect(model,"Type",["Parameter","Species","Compartment"]);

% get components defined by rules
rules = sbioselect(model,"Type","Rule");
rulesComponentsNames = extractBefore(get(rules,'Rule'),' =');
rulesComponents = sbioselect(model,'where','Name','==',rulesComponentsNames);

% get components modified by events
events = sbioselect(model,'Type','Event','Active',true);
if ~isempty(events)
    eventFcns = get(events,'EventFcns');
    if iscell(eventFcns), eventFcns = string(vertcat(eventFcns{:})); end
    eventFcnsComponentsNames = extractBefore(eventFcns,' =');
    eventFcnsComponents = sbioselect(model,'where','Name','==',eventFcnsComponentsNames);
else
    eventFcnsComponents = [];
end

% take the difference
componentsObj = setdiff(allComponents,[rulesComponents;eventFcnsComponents]);

end
