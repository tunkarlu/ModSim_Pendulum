[File,Path] = uigetfile('*.mat','Choose Matlab datafiles');
if ~isnumeric(File)
    load(fullfile(Path,File))
    Time = Time';
    Amplitude = Amplitude';
    Time(end) = round(Time(end),3);
end