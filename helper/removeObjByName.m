function outputObj = removeObjByName(inputObj, names)

obj = sbioselect(inputObj,'Name', names);
outputObj = setdiff(inputObj,obj);

end