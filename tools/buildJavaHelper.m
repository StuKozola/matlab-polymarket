%% buildJavaHelper Build the packaged Java WebSocket helper.
% Run from the repository root.

repoRoot = fileparts(fileparts(mfilename("fullpath")));
sourceRoot = fullfile(repoRoot, "java");
outputRoot = fullfile(repoRoot, "build", "java");
classesRoot = fullfile(outputRoot, "classes");
jarFile = fullfile(repoRoot, "lib", "polymarket-java-helper.jar");

if ~isfolder(classesRoot)
    mkdir(classesRoot);
end
if ~isfolder(fileparts(jarFile))
    mkdir(fileparts(jarFile));
end

sourceFile = fullfile(sourceRoot, "com", "polymarket", "WebSocketConnection.java");
javac = "javac";
jar = "jar";

status = system(sprintf('"%s" -d "%s" "%s"', javac, classesRoot, sourceFile));
if status ~= 0
    error("polymarket:JavaBuildFailed", "javac failed while building the WebSocket helper.");
end

status = system(sprintf('"%s" --create --file "%s" -C "%s" .', jar, jarFile, classesRoot));
if status ~= 0
    error("polymarket:JavaBuildFailed", "jar failed while packaging the WebSocket helper.");
end

fprintf("Built %s\n", jarFile);

