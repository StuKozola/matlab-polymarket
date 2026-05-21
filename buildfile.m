function plan = buildfile
%BUILDFILE Build tasks for the MATLAB Polymarket toolbox.
plan = buildplan(localfunctions);
plan.DefaultTasks = "test";
plan("package").Dependencies = "java";
end

function testTask(~)
addpath("src");
suite = testsuite("tests");
tags = {suite.Tags};
include = cellfun(@(value) ~any(strcmp(value, "Integration")), tags);
runner = matlab.unittest.TestRunner.withTextOutput;
results = runner.run(suite(include));
assertSuccess(results);
end

function checkTask(~)
files = dir(fullfile("src", "**", "*.m"));
paths = fullfile({files.folder}, {files.name});
issues = checkcode(paths);
issueCount = 0;
for k = 1:numel(issues)
    issueCount = issueCount + numel(issues{k});
end
if issueCount > 0
    disp(issues);
    error("polymarket:CheckcodeIssues", ...
        "checkcode reported %d issue(s).", issueCount);
end
fprintf("checkcode reported no issues.\n");
end

function integrationTask(~)
addpath("src");
suite = testsuite("tests", Tag="Integration");
runner = matlab.unittest.TestRunner.withTextOutput;
results = runner.run(suite);
assertSuccess(results);
end

function javaTask(~)
run("tools/buildJavaHelper.m");
end

function packageTask(~)
run("tools/packageToolbox.m");
end
