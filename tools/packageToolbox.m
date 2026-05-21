%% packageToolbox Package the Polymarket MATLAB toolbox.
% Run this script from the repository root.
% Requires MATLAB R2023a or later for ToolboxOptions.

repoRoot = fileparts(fileparts(mfilename("fullpath")));
toolboxUUID = "2b386b46-196f-4c98-9fa8-f1554ed9fa80";
toolboxName = "Polymarket";
toolboxVersion = "0.1.0";
outputFile = fullfile(repoRoot, "release", "Polymarket.mltbx");

jarFile = fullfile(repoRoot, "lib", "polymarket-java-helper.jar");
if ~isfile(jarFile)
    warning("polymarket:MissingJavaHelper", ...
        "WebSocket helper JAR is missing. Run tools/buildJavaHelper.m before packaging WebSocket support.");
end

opts = matlab.addons.toolbox.ToolboxOptions(repoRoot, toolboxUUID);
opts.ToolboxName = toolboxName;
opts.ToolboxVersion = toolboxVersion;
opts.AuthorName = "";
opts.AuthorEmail = "";
opts.AuthorCompany = "";
opts.Summary = "MATLAB client toolbox for the Polymarket APIs.";
opts.Description = [ ...
    "MATLAB clients for Polymarket Gamma, Data, CLOB, Bridge, Relayer, " + ...
    "and WebSocket APIs, including L2 request signing helpers and " + ...
    "toolbox packaging support."];
opts.OutputFile = outputFile;
opts.ToolboxMatlabPath = fullfile(repoRoot, "src");

gettingStarted = fullfile(repoRoot, "doc", "GettingStarted.m");
if isfile(gettingStarted)
    opts.ToolboxGettingStartedGuide = gettingStarted;
end

opts.SupportedPlatforms.Win64 = true;
opts.SupportedPlatforms.Maci64 = true;
opts.SupportedPlatforms.Glnxa64 = true;
opts.SupportedPlatforms.MatlabOnline = true;
opts.MinimumMatlabRelease = "R2023a";

if ~isfolder(fileparts(outputFile))
    mkdir(fileparts(outputFile));
end

matlab.addons.toolbox.packageToolbox(opts);
fprintf("Toolbox packaged: %s\n", outputFile);
