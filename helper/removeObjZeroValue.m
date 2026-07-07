function outputObj = removeObjZeroValue(inputObj)

valuesCell = get(inputObj,'Value');
values = cell2mat(valuesCell);

idx = values==0;
outputObj = inputObj(~idx);

end