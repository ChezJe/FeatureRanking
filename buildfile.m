function plan = buildfile
import matlab.buildtool.tasks.*

plan = buildplan(localfunctions);

plan("clean") = CleanTask;
plan("check") = CodeIssuesTask;

proj = currentProject;
plan("exportMDfile").Inputs = ...
    fullfile(proj.RootFolder,"Feature_Ranking_script.m");
plan("exportMDfile").Dependencies = "check";

plan.DefaultTasks = "exportMDfile";
end


function exportMDfileTask(context)
% filenames = context.Task.Inputs.paths;
% export(filenames{:}, Format="markdown", EmbedImages=true, AcceptHTML=true);
filenames = context.Task.Inputs.paths;
export(filenames{:}, Format="html", FigureFormat="webcanvas", EmbedImages=true);
end
