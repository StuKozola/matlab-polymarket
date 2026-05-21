function plan = buildfile
%BUILDFILE Build tasks for the MATLAB Polymarket toolbox.
plan = buildplan(localfunctions);
plan.DefaultTasks = "test";
end

function testTask(~)
addpath("src");
results = runtests("tests");
assertSuccess(results);
end

function checkTask(~)
files = dir(fullfile("src", "**", "*.m"));
paths = fullfile({files.folder}, {files.name});
issues = checkcode(paths, "-cyc");
disp(issues);
end

function packageTask(~)
run("tools/packageToolbox.m");
end

