function tmin = computeTmin(time, Protein)

[~,idx] = min(Protein);
tmin = time(idx);

end