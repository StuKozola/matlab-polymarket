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
javac = findJavaTool("javac", "POLYMARKET_JAVAC");
jar = findJavaTool("jar", "POLYMARKET_JAR");

status = system(sprintf('%s --release 8 -d "%s" "%s"', quoteCommand(javac), classesRoot, sourceFile));
if status ~= 0
    error("polymarket:JavaBuildFailed", "javac failed while building the WebSocket helper.");
end

status = system(sprintf('%s --create --file "%s" -C "%s" .', quoteCommand(jar), jarFile, classesRoot));
if status ~= 0
    error("polymarket:JavaBuildFailed", "jar failed while packaging the WebSocket helper.");
end

fprintf("Built %s\n", jarFile);

function tool = findJavaTool(name, envName)
tool = string(getenv(envName));
if strlength(tool) > 0 && (isfile(tool) || tool == name)
    return
end

javaHome = string(getenv("JAVA_HOME"));
extension = "";
if ispc
    extension = ".exe";
end
if strlength(javaHome) > 0
    candidate = fullfile(javaHome, "bin", name + extension);
    if isfile(candidate)
        tool = string(candidate);
        return
    end
end

[status, output] = system("where " + name);
if status == 0
    matches = splitlines(strtrim(string(output)));
    matches = matches(strlength(matches) > 0);
    if ~isempty(matches)
        tool = matches(1);
        return
    end
end

candidates = [
    fullfile("C:\Program Files\Bookmap\jre\bin", name + extension)
    fullfile("C:\Program Files\Java", "jdk", "bin", name + extension)
    ];
for i = 1:numel(candidates)
    if isfile(candidates(i))
        tool = candidates(i);
        return
    end
end

tool = name;
end

function command = quoteCommand(tool)
tool = string(tool);
if contains(tool, filesep) || contains(tool, " ")
    command = """" + tool + """";
else
    command = tool;
end
end
