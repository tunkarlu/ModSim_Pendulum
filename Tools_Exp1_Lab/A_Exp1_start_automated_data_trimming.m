function main()
    ActPath = pwd;
    cd ../Data

    %Laden der Daten
    [FileName,PathName] = uigetfile('*.tdms','Select *.tdms data files','MultiSelect','on');
    cd(ActPath)
    
    Winkel_min = 1;    % minimale Auslenkung bis zu der der Zuschnitt erfolgt

    if ~isnumeric(FileName)
        if iscell(FileName)
            for i = 1:length(FileName)
                V1_Import_Pendel_tdms_Zuschneiden_auto(FileName{i}, PathName,Winkel_min);
            end
        else
            V1_Import_Pendel_tdms_Zuschneiden_auto(FileName, PathName,Winkel_min);
        end
    end

    clear FileName PathName i ActPath
end

function V1_Import_Pendel_tdms_Zuschneiden_auto(filename_tdms,pathname_tdms,winkel_min)

    ActPath = pwd;

    addpath([ActPath '\Import_tdms\v2p5'])
    addpath([ActPath '\Import_tdms\v2p5\tdmsSubfunctions'])

    if ~isnumeric(filename_tdms)
        Data = TDMS_getStruct(fullfile(pathname_tdms,filename_tdms));

        %Extraktion Messkanäle
        ClusterNamen = fields(Data);
        Index = strfind(ClusterNamen,'Cluster');

        Zaehler = 0;

        for i = 1:length(Index)
            if Index{i} == 1
                eval(['DatenNamen = fields(Data.'  ClusterNamen{i} ');'])
                for j = 1:length(DatenNamen)
                    if ((strcmp(DatenNamen(j),'name') == 0) && (strcmp(DatenNamen(j),'Props') == 0))
                        eval([DatenNamen{j} ' = Data.' ClusterNamen{i} '.' DatenNamen{j} '.data;'])
                        if Zaehler == 0
                            eval(['DatenLaenge = length(Data.' ClusterNamen{i} '.' DatenNamen{j} '.data);'])
                            Zaehler = 1;
                        end
                    end
                end
            end
        end

        clear Data ClusterNamen Index Zaehler i j DatenLaenge DatenNamen

        %Zuschneiden der Daten (alles vor erstem Maximum abschneiden)
        Zeit_orig = Zeit;
        Amplitude_orig = Amplitude;

        Amp_max = max(Amplitude);
        Index_Amp_max = find(Amplitude == Amp_max,1);
        Grenzwert = 0.8*Amp_max;
        Index_Start = find(Amplitude > Grenzwert,1);
        Zeit(1:Index_Start) = [];
        Amplitude(1:Index_Start) = [];

        Index_Stop = find(Amplitude < Grenzwert,1);

        Poly_Ord = 4;
        p = polyfit(Zeit(1:Index_Stop),Amplitude(1:Index_Stop),Poly_Ord);
        Zeit_poly = Zeit(1:Index_Stop);
        Amplitude_poly = polyval(p,Zeit(1:Index_Stop));
        Index = find(Amplitude_poly == max(Amplitude_poly),1);
        Amplitude(1:Index) = [];
        Zeit(1:Index) = [];

        clear Amp_max Index_Amp_max Grenzwert Index_Start Index_Stop Poly_Ord p Amplitude_poly Zeit_poly Index Fig

        %Auswertung der Daten hinsichtlich des auftretenden Rauschens (FFT)
        T = mean(diff(Zeit));                   % Abtastintervall [s]
        Fs = 1/T;                               % Abtastfrequenz [Hz]
        L = length(Zeit);                       % Anzahl Messwerte
        if mod(L,2) == 1                        % Prüfung ob gerade Anzahl an Messwerten
            t = Zeit(1:end-1);                  % Zeitvektor
            Y = fft(Amplitude(1:end-1));        % FFT des Amplitudensignals 
            L = length(t);                      % gerade Anzahl Messwerte
        else
            t = Zeit;                           % Zeitvektor
            Y = fft(Amplitude);                 % FFT des Amplitudensignals 
        end

        %Berechnung des Amplitudenspektrums und der Zugehörigen Frequenz
        P2 = abs(Y/L);
        P1 = P2(1:L/2+1);
        P1(2:end-1) = 2*P1(2:end-1);
        f = Fs*(0:(L/2))/L;

        %Suchen der Grundfrequenz
        Amp_sort = sort(P1,'descend');
        Amp_Grund = Amp_sort(1);
        Index = find(P1==Amp_Grund,1);
        f_Grund = f(Index);
        T_Grund = 1/f_Grund;

        clear Fs L t Y L P1 P2 f Amp_sort Amp_Grund Index f_Grund

        %Bestimmung der maximalen Amplitude
        Amp_max = max(Amplitude);

        %Bestimmung der Nulldurchgänge
        Wechsel_VZ = sign(Amplitude);
        %Erkennen der steigenden Flanken im Eingangssignal
        Indizes_st_Flanken = find(diff(Wechsel_VZ) > 0.5);
        %Prüfen ob erste erkannte steigende Flanke tatsächlich eine steigende Flanke ist
        i = 0;
        while true
            i = i + 1;
            Pruefwert = Amplitude(Indizes_st_Flanken(i) + round(T_Grund/(T*4)));
            if Pruefwert < 0.5*Amp_max
                Indizes_st_Flanken(i) = 0;
            else
                Indizes_st_Flanken_0 = find(Indizes_st_Flanken == 0);
                Indizes_st_Flanken(Indizes_st_Flanken_0) = [];
                break
            end
        end
        clear i Wechsel_VZ Pruefwert Indizes_st_Flanken_0 Amp_max

        % Entfernen von Toggle-Effekten in Flankenerkennung durch Signalstörungen    
        for i = 2:length(Indizes_st_Flanken)
            delta_T = Zeit(Indizes_st_Flanken(i))-Zeit(Indizes_st_Flanken(i-1));
            if delta_T < 0.6*T_Grund
                Indizes_st_Flanken(i) = Indizes_st_Flanken(i-1);
            end
        end
        Indizes_st_Flanken = sort(unique(Indizes_st_Flanken));
        clear delta_T i T T_Grund

        %Letzte Amplitude finden
        Zaehler = length(Indizes_st_Flanken);
        while true
            Letzte_Amp = max(Amplitude(Indizes_st_Flanken(Zaehler-1):Indizes_st_Flanken(Zaehler)));
            Index_letzte_Amp = Indizes_st_Flanken(Zaehler-1) + find(Amplitude(Indizes_st_Flanken(Zaehler-1):Indizes_st_Flanken(Zaehler)) == Letzte_Amp,1);
            if Letzte_Amp >= winkel_min
                break
            else
                Zaehler = Zaehler - 1;
                if Zaehler < 1
                    break
                end
            end
        end
        % Zuschneiden der Signale
        Zeit = Zeit(1:Index_letzte_Amp);
        Amplitude = Amplitude(1:Index_letzte_Amp);

        %Plotten zur Überprüfung
        Schrifftgroesse = 14;
        Fig = figure;
        set(Fig,'Name',filename_tdms,'Units','normalized','Position',[0 0.05 1 0.85])
        Achse = axes;
        Achse.FontSize = Schrifftgroesse;
        Achse.XLabel.String = 'time [s]';
        Achse.XLabel.FontSize = Schrifftgroesse;
        Achse.YLabel.String = 'angle [°]';
        Achse.XLabel.FontSize = Schrifftgroesse;
        Achse.XGrid = 'on';
        Achse.YGrid = 'on';
        Achse.Box = 'on';
        Achse.NextPlot = 'add';
        Linie_orig = line(Achse,Zeit_orig,Amplitude_orig);
        Linie_save = line(Achse,Zeit,Amplitude,'Color','r','LineWidth',2);
        %Linie_poly = line(Achse,Zeit_poly,Amplitude_poly,'Color',[0 0.5 0],'LineStyle',':','LineWidth',2);
        
        %Legende
        Legendentext{1} = 'measured data';
        Legendentext{2} = 'trimmed data';
        Legendentext{3} = 'fitted polynomial';
        Legende = legend(Achse,'show');
        Legende.String = Legendentext;
        Legende.Location = 'north';
        Legende.Orientation = 'horizontal';
        Legende.FontSize = Schrifftgroesse;
        
        uiwait(Fig)

        clear Zeit_orig Amplitude_orig Letzte_Amp Index_letzte_Amp Indizes_st_Flanken

        %korrigieren der Zeitachse
        Zeit = Zeit - Zeit(1);
        Zeit(end) = round(Zeit(end),3); % um Vielfaches der SimStepSize zu erreichen
        Time = Zeit;
        %Ablegen der zugeschnittenen Daten als mat-File
        File = strrep(filename_tdms,'.tdms','.mat');
        save(fullfile(pathname_tdms,File),'Time','Amplitude')
    end

    clear filename_tdms pathname_tdms ActPath
end