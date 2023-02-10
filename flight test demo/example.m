%% PRZYKŁAD OBRÓBKI DANYCH
% MICHAŁ SŁOMIANY

% Przykładowy skrypt z funkcjami ułatwiającymi pracę z danymi zebranymi
% z Matlaba mobile

% Dane zapisywane są w postaci TIMETABLE, czyli tabeli zawierającej
% TIMESTAMP oraz wyniki pomiarów. Nazwy poszczególnych zmiennych to:
% - Acceleration - przyśpieszenia
% - Orientation - kąty orientacji przestrzennej
% - AngularVelocity - przyśpieszenia kątowe
% - Position - dane z GPS (wysokość, pozycja geo, prędkość etc.)
% Pierwsze trzy są próbkowane z częstotliwością użytkownika, POSITION z
% częstotliwością 1 Hz

%% Wczytywanie danych
% Matlab zapisuje wszystko w pliku .MAT, więc należy go wczytać używając
% funkcji 

load nazwa_pliku.mat;

% Wszystkie tablice zostaną wczytane jako oddzielne zmienne, nie w ramach
% jednej struktury

%% Zmiana czasu

% Pierwsza rzecz przy pracy z danymi to zmiana timestampu. Domyślnie
% zapisywany jest w postaci YY-MM-DD-HH-MM-SS. Bardziej zależy nam, żeby
% timestamp był w sekundach od 0, czyli początku pomiarów. Dzięki temu, że 
% pomiary są w zmiennej typu timetable bardzo łatwo jest to zrobić.
% Zmieniamy właściwości wszystkich zmiennych w sposób (na przykładzie
% zmiennej acceleration):

% Najpierw zmieniamy początkowy timestamp na 0 sekund. Należy użyć funkcji
% seconds(), ponieważ jest to zmienna typu DURATION, nie zwykła wartość.
Acceleration.Properties.StartTime = seconds(0);

% Następnie ustawiamy częstotliwość próbkowania dla całej tablicy, zadajemy
% wartość w Hz
Acceleration.Properties.SampleRate = 50;

%% Wycinanie interesujących danych
% Gdy chcemy pracować na konkretnym odcinku danych, np tylko tym
% zawierającym oscylacje, można w łatwy sposób stworzyć nową tablicę
% wyłącznie z interesującymi nas danymi. Najpierw definiujemy początek i
% koniec odpowiedniego fragmentu:

xbeg = seconds(377);
xend = seconds(446);

% Następnie używany funkcji TIMERANGE do stworzenia zakresu czasu:

S = timerange(xbeg,xend);

% I na koniec wycinamy odpowiedni fragment i przypisujemy go (bądź nie) do
% nowej zmiennej

osc = Position(S,:);


%% Zmiana częstotliwości próbkowania
% Można interpolować próbki np. wysokości z GPS tak, aby miały
% częstotliwość próbkowania jak pomiary z IMU. Na przykładzie powyższego
% wyciętego fragmentu, resamplowanie wyciętego fragmentu tablicy Position
% (dane z GPS)

% SPLINE jest wybranym typem interpolacji
osc = retime(osc,'regular','spline','SampleRate',50);

%% Filtrowanie danych 
% Dane z np. akcelerometru są mocno zaszumione. W celu wygładzenia danych
% można użyć funkcji SMOOTHDATA. Ważne, jest ona dostępna tylko dla
% zmiennych typu TIMETABLE.

% Do tablicy Acceleration dopisujemy nową kolumnę Xs, czyli wygładzone
% przyśpieszenia w osi X. LOESSS i SMOOTHINGFACTOR to opcje funkcji
% zadawane przez użytkownika.
Acceleration.Xs = smoothdata(Acceleration.X,"loess","SmoothingFactor",.4);

%% Podsumowanie
% Największe zalety TIMETABLE są takie, że można operować w osi X używając
% po prostu zmiennej czasu w sekundach a nie indeksów tabeli. Poza tym 
% Matlab oferuje przydatny zestaw funkcji do pracy z takimi zmiennymi, jak 
% np. możliwość automatycznego odnajdywania ekstremów lokalnych. 

% https://www.mathworks.com/help/matlab/timetables.html

%% MICHAŁ SŁOMIANY
%  https://www.supercluster.it/
%  2022