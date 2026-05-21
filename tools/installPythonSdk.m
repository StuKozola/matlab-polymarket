%% installPythonSdk Install the optional official Polymarket Python SDK.
% Uses MATLAB's configured Python executable.

environment = pyenv;
pythonExe = string(environment.Executable);
if strlength(pythonExe) == 0
    error("polymarket:PythonUnavailable", ...
        "Configure MATLAB Python with pyenv before installing py-clob-client-v2.");
end

command = sprintf('"%s" -m pip install --upgrade py-clob-client-v2', pythonExe);
status = system(command);
if status ~= 0
    error("polymarket:PythonSdkInstallFailed", ...
        "pip failed while installing py-clob-client-v2.");
end

fprintf("Installed py-clob-client-v2 into %s\n", pythonExe);

