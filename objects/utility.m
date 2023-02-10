classdef utility
    %UTILITYOBJ Pomocnicze funkcje pozwalające na usprawnienie pracy
    %   ze skryptem

    properties
        config = [0 0 0]; %print %close %next
    end

    methods
        %% Konstruktor
        function obj = utility(varargin)
            if nargin > 0
                obj.config = [varargin{1} varargin{2} varargin{3}];
            end
        end
        %% Zakończenie skryptu
        function [] = endscript(obj)
            if obj.config(1) ~= 0
                temp = dbstack();
                for i=1:length(findobj('type','figure'))
                    name = [temp(2).name '_' num2str(i)];
                    figure(i);
                    exportgraphics(gcf,[name '.png'],'Resolution',300);
                end
            end
            if obj.config(2) ~= 0
                close all
            end
            if obj.config(3) ~=0
                temp = dbstack();
                number = temp(2).name(end);
                number = str2double(number);
                number = 1 + number;
                name = [temp(2).name(1:end-1) num2str(number) '.m'];
                try
                    run(name);
                catch
                    warning('Next script not found!')
                end
            end
        end
    end

    methods(Static)
        %% Inicjalizacja
        function [] = init(varargin)
            %INIT Funkcja inicjalizująca
            %   Reset workspace'u i obiektów graficznych
            evalin("base",'clear')
            clc
            clf
            close all
            reset(groot)
            %   Formatowanie wykresów
            if (nargin == 0)
                set(groot,'defaultFigureWindowState','normal'); % figura
                set(groot,'defaultFigurePosition',[0 0 1000 500])
                set(groot,'defaultAxesXGrid','on','defaultAxesYGrid','on','defaultAxesNextPlot','add'); % wykres
                set(groot,'defaultAxesTickLabelInterpreter','latex','defaultAxesLabelFontSizeMultiplier',1.1); % osie
                set(groot,'defaultAxesTitleFontSizeMultiplier',1.5,'defaultTextInterpreter','latex'); % tytuł
                set(groot,'defaultAxesColorOrder',[0 0 0]); % kolor
                set(groot,'defaultLegendInterpreter','latex')% legenda
                set(groot,'defaultLegendFontSize', 50); 
                set(groot,'defaultAxesFontSizeMode','manual','defaultAxesFontSize',12);
            end
        end
    end
end

