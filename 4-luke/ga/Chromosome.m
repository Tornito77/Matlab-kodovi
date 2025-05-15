classdef Chromosome
    properties
        firstGene    % Od  400 do 5100
        secondGene   % Od 12.0 do 19.0 s korakom 0.1
        thirdGene    % Od 0 do 25
        fitness      % Vrijednost fitnessa
    end

    methods
        function obj = Chromosome()
            obj.firstGene = randi([400, 5100]);
            obj.secondGene = 12 + randi([0, 70]) * 0.1;
            obj.thirdGene = randi([0, 25]);
            obj.fitness = 0;
        end

        function obj = calculateFitness(obj)
            obj.fitness = obj.fitnessFunction(obj.firstGene, obj.secondGene, obj.thirdGene);
        end

        function fit = fitnessFunction(~, first, second, third)

              kb1  = first;
              %kb1 = 1825;
              %fprintf('Skladišni kapacitet: %d\n', kb1);

              v = second;
              %v = 16.4;
              %fprintf('Brzina (cv): %f\n', v);

              godinaStarosti = third;
              %godinaStarosti = 19;

              Vst = Chromosome.vozarinaPremaTEU(kb1); % Funkcija, iz tablice

              qg = 0.17;  % kg/kWh

              file = 'vrijednostBroda.txt';
              Kcb = Chromosome.dohvatiKapitalnuVrijednost(file, kb1, godinaStarosti); % iz .txt datoteke
              %fprintf('Kapitalna cijena broda: %d\n', Kcb);


              D = Chromosome.deplasmanPoTEU(kb1);            % deplasman
              %fprintf('Deplasman: %d\n', D);
              D23 = D^(2.0/3);
              %fprintf('D 2/3: %f\n', D23);
              kA = Chromosome.konstantaAdmiralitetaPremaTEU(kb1);
              %fprintf('Konstanta admiraliteta: %f\n', kA);
              kp1 = Chromosome.koeficijentPremaTEU(kb1);
              %fprintf('KP1: %f\n', kp1);
              kp2 = Chromosome.kp2PremaTEUpremaStarosti(kb1, godinaStarosti);
              %fprintf('KP2: %f\n', kp2);
              kp3 = Chromosome.kp3PremaTEUpremaStarosti(kb1, godinaStarosti);
              %fprintf('KP3: %f\n', kp3);

              %% PRIHODI %%
              Dl = 2210;           % milja
              %fprintf('Duljina putovanja: %d\n', Dl);

              kolicinaTereta2luke = [];  % inicijalizacija vektora
              kolicinaTereta2luke(end+1) = 1500;  % teret između dvije luke
              kolicinaTereta2luke(end+1) = 1950;  % teret između dvije luke
              kolicinaTereta2luke(end+1) = 2130;  % teret između dvije luke
              % kolicinaTereta2luke(end+1) = 650; % ako dodaješ više luka

              delta = [];  % inicijalizacija rezultujućeg vektora
              for i = 1:length(kolicinaTereta2luke)
                  delta(end+1) = kolicinaTereta2luke(i) / kb1;
              end

              %fprintf('Delta: %d\n', delta);

              duljinaUMiljama1 = 973;
              duljinePutovanja2Luka = {};
              duljinePutovanja2Luka{end+1} = duljinaUMiljama1 / v / 24;  % u danima
              duljinaUMiljama1 = 1036;
              duljinePutovanja2Luka{end+1} = duljinaUMiljama1 / v / 24;  % u danima
              duljinaUMiljama1 = 201;
              duljinePutovanja2Luka{end+1} = duljinaUMiljama1 / v / 24;  % u danima
              % Ako ima više dionica:
              % duljinaUMiljama2 = 400;
              % duljinePutovanja2Luka{end+1} = duljinaUMiljama2 / v / 24;

              % Računanje lambde
              lambda = [];
              for i = 1:length(duljinePutovanja2Luka)
                  lambda(end+1) = duljinePutovanja2Luka{i} / (Dl / v / 24);
              end
              %fprintf('Lambda: %d\n', lambda);

              sumaProduktaOmjeraDuljineKolicine = 0;

              for i = 1:length(lambda)
                  sumaProduktaOmjeraDuljineKolicine = sumaProduktaOmjeraDuljineKolicine + delta(i) * lambda(i);
              end
              %fprintf('Suma produkta omjera duljine (delta) i kolicine (lambda): %f\n', sumaProduktaOmjeraDuljineKolicine);

              obrtajKontejnera = 4050;
              prihodiUkupno = Vst * obrtajKontejnera * sumaProduktaOmjeraDuljineKolicine;
              %fprintf('Prihodi: %f\n', prihodiUkupno);
              %% PRIHODI %%

              %% TROŠKOVI %%
              prviDioTroskoviTAS = 1500 + 1230 + 1340 + 1400 + 0;

              cg = 0.62;  % cijena goriva pomoćnog motora ($/kg)
              cp = 0.85;  % cijena goriva pomoćnog kotla ($/kg)

              % Pretpostavlja se da su qg, v, D23, kA i Dl već definirani u prethodnom kodu

              trosakGoriva = (24 * (qg * cg * v^3 * D23 / kA) + 24 * (0.05 * qg * cp * v^3 * D23 / kA)) * Dl / 24 / v;
              troskoviPlovidbeUkupno = prviDioTroskoviTAS + trosakGoriva;

              %fprintf('Trošak plovidbe: %f\n', troskoviPlovidbeUkupno);
              %fprintf('     Trošak TAŠ: %f\n', prviDioTroskoviTAS);
              %fprintf('     Trošak goriva: %f\n', trosakGoriva);

              % Inicijalizacija niza s taksama
              ti = [];  % inicijalizacija praznog niza (vektora)

              % Dodavanje za svaku luku
              ti(end+1) = 0.21 + 0.24 + 0.05;
              ti(end+1) = 0.19 + 0.20 + 0.07;
              ti(end+1) = 0.22 + 0.21 + 0.065;
              % Proračun zbroja svih taksi
              prvaZagradaTroskovi = sum(ti);
              % Množenje sa D
              prvaZagradaTroskovi = prvaZagradaTroskovi * D;
              % Ispis rezultata
              % %fprintf('Prva zagrada troškovi: %f\n', prvaZagradaTroskovi);

              % Manipulativni trošak prekrcaja (tpti)
              tpti = [];
              tpti(end+1) = 1.2;
              tpti(end+1) = 0.9;
              tpti(end+1) = 1.35;

              % LNI naknada za korištenje obale
              lni = [];
              lni(end+1) = 0.5;
              lni(end+1) = 0.51;
              lni(end+1) = 0.54;

              omjerTeretIskrcaniPoLuci = [ ...
                  0.00, ...
                  300.00 / kb1, ...
                  400.00 / kb1, ...
                  520.00 / kb1 ...
              ];

              omjerTeretUkrcaniPoLuci = [ ...
                  1500.00 / kb1, ...
                  750.00 / kb1, ...
                  580.00 / kb1, ...
                  0.00 / kb1 ...
              ];

              % Suma zagrada
              sumaZagrada = 0;
              for i = 1:length(tpti)  % MATLAB koristi indekse od 1, a ne od 0 kao Java
                  tpti1 = tpti(i);
                  lni1 = lni(i);
                  omjerTeretIskrcaniPoLuci1 = omjerTeretIskrcaniPoLuci(i);
                  omjerTeretUkrcaniPoLuci1 = omjerTeretUkrcaniPoLuci(i);

                  sumaZagrada = sumaZagrada + ((tpti1 + lni1) * (omjerTeretIskrcaniPoLuci1 + omjerTeretUkrcaniPoLuci1));
              end

              % Druga zagrada troškovi
              drugaZagradaTroskovi = sumaZagrada * kb1;

              % Definiranje tmi (vrijeme manevre u danima)
              tmi = [ ...
                  2.5 / 24, ...
                  4.5 / 24, ...
                  3.0 / 24, ...
                  3.5 / 24 ...
              ];
              % Ukupno vrijeme manevre
              ukupnoVrijemeManovre = sum(tmi); % MATLAB ima funkciju sum() koja sabira sve elemente u vektoru

              % dL1i - čekanje na vez u danima
              dL1i = [ ...
                  1.00 / 24, ...
                  2.00 / 24, ...
                  1.50 / 24, ...
                  2.00 / 24 ...
              ];

              % dL2i korisno vrijeme boravka u danima
              dL2i = [ ...
                  0.00 / 24, ...
                  16.00 / 24, ...
                  20.00 / 24, ...
                  12.00 / 24 ...
              ];

              % Suma dL (dL1i + dL2i)
              sumaDl = sum(dL1i + dL2i);

              % Parametri
              vManovre = 8;  % Brzina manevre
              % Treća zagrada troškovi
              trecaZagradaTroskovi = (24 * qg * cg * (vManovre^3) * D23 / kA * ukupnoVrijemeManovre + 0.05 * 24 * qg * cg * (vManovre^3) * D23 / kA) * sumaDl;

              % Ukupni trošak broda u luci
              troskoviBrodaULuciUkupno = prvaZagradaTroskovi + drugaZagradaTroskovi + trecaZagradaTroskovi;

              % Ispis rezultata
              %fprintf('Trošak broda u luci: %.2f\n', troskoviBrodaULuciUkupno);
              %fprintf('     Troškovi (lučke takse, sigurnost plovidbe, peljarenje): %.2f\n', prvaZagradaTroskovi);
              %fprintf('     Troškovi manipulacije: %.2f\n', drugaZagradaTroskovi);
              %fprintf('     Troškovi goriva u luci: %.2f\n', trecaZagradaTroskovi);

              % Prva zagrada
              prvaZagradaOperativa = kp1 + kp2 * D + kp3 * D23;

              % Druga zagrada: prihvat broda u luci i otprema + iskrcavanje
              dlp = 0.0833;  % vrijeme prihvata broda i otpreme
              dll = 0.993;   % iskrcavanje
              drugaZagradaOperativa_dlp_dll = dlp + dll;

              % Treći dio: vrijeme plovidbe
              treciDio_Dl24v = Dl / 24 / v;

              % Ukupni trošak operative
              troskoviOperativeUkupno = prvaZagradaOperativa * (drugaZagradaOperativa_dlp_dll + treciDio_Dl24v);
              %fprintf('Trošak operative: %.2f\n', troskoviOperativeUkupno);

              sviTroskovi = (troskoviBrodaULuciUkupno + troskoviOperativeUkupno + troskoviPlovidbeUkupno);
              %fprintf('Svi troškovi: %.2f\n', sviTroskovi);

              %% TROŠKOVI %%

              ekonomicnost = prihodiUkupno / (troskoviBrodaULuciUkupno + troskoviOperativeUkupno + troskoviPlovidbeUkupno);
              %fprintf('Ekonomičnost: %.4f\n', ekonomicnost);

              Tgva = godinaStarosti;    % broj godina otpisivanja broda
              Vtb = 25;                 % vijek trajanja broda
              Csz = 400;                % vrijednost broda kao staro željezo ($/tona)
              treciDioFormule = drugaZagradaOperativa_dlp_dll + treciDio_Dl24v;
              KapitalnaVrijednostBroda = (Kcb - Tgva * Kcb / Vtb + D * Csz) * 1.05;
              %fprintf('      Kapitalna cijena broda: %.2f\n', Kcb);
              %fprintf('      Amortizacija: %.2f\n', Tgva * Kcb / Vtb);
              %fprintf('      Vrijednost broda staro željezo: %.2f\n', D * Csz);
              %fprintf('Kapitalna vrijednost broda: %.2f\n', KapitalnaVrijednostBroda);

              dobit = prihodiUkupno - troskoviBrodaULuciUkupno - troskoviOperativeUkupno - troskoviPlovidbeUkupno;
              rentabilnost = dobit / (KapitalnaVrijednostBroda * treciDioFormule);
              %fprintf('Dobit: %.2f\n', dobit);
              %fprintf('Rentabilnost: %.6f\n', rentabilnost);

              bcp = 16;  % broj članova posade

              % Produktivnost broda
              produktivnost = (prihodiUkupno - troskoviBrodaULuciUkupno - troskoviOperativeUkupno - troskoviPlovidbeUkupno) / (bcp * (dlp + kb1 * dll + treciDioFormule));

              sviTroskovi = troskoviBrodaULuciUkupno + troskoviOperativeUkupno + troskoviPlovidbeUkupno;

              %%fprintf('Produktivnost: %.6f\n', produktivnost);
              %%fprintf('Prihodi - troškovi: %.2f\n', prihodiUkupno - sviTroskovi);
              %%fprintf('Produktivnost po članu posade po danu određenog putovanja: %.6f\n', ...
              %        (prihodiUkupno - sviTroskovi) / bcp / ((Dl / v / 24) + drugaZagradaOperativa_dlp_dll));
              %%fprintf('Trošak po prevezenom TEU: %.6f\n', (prihodiUkupno - sviTroskovi) / ukupnoPrevezeniTeret);
              %%fprintf('Vrijeme plovidbe (u danima): %.2f\n', (Dl / v / 24));
              %%fprintf('Trošak operative (po danu): %.2f\n', troskoviOperativeUkupno / ((Dl / v / 24) + sumaDl));

              if kb1 < 2130
                  rentabilnost = -10;
              elseif rentabilnost < 0.001
                  rentabilnost = 0.001;
              elseif rentabilnost > 0.006
                  rentabilnost = 0.006;
              end
              rentabilnost = (rentabilnost - 0.001) / 0.005;

              if ekonomicnost < 1
                  ekonomicnost = 1;
              elseif ekonomicnost > 3
                  ekonomicnost = 3;
              end
              ekonomicnost = (ekonomicnost - 1) / 2;

              if produktivnost < 4
                  produktivnost = 4;
              elseif produktivnost > 9
                  produktivnost = 9;
              end
              produktivnost = (produktivnost - 4) / 5;

              ocjena = rentabilnost * 0.6 + ekonomicnost * 0.2 + produktivnost * 0.2;
              fit = ocjena;


        end

  end

    methods(Static)
        function Vst = vozarinaPremaTEU(kb1)
            if kb1 < 800
                Vst = 245;
            elseif kb1 >= 800 && kb1 < 1000
                Vst = 238;
            elseif kb1 >= 1000 && kb1 < 1200
                Vst = 222;
            elseif kb1 >= 1200 && kb1 < 1600
                Vst = 215;
            elseif kb1 >= 1600 && kb1 < 2000
                Vst = 211;
            elseif kb1 >= 2000 && kb1 < 2500
                Vst = 198;
            elseif kb1 >= 2500 && kb1 < 3000
                Vst = 182;
            elseif kb1 >= 3000 && kb1 < 3500
                Vst = 172;
            elseif kb1 >= 3500 && kb1 < 4000
                Vst = 164;
            elseif kb1 >= 4000 && kb1 < 4500
                Vst = 158;
            elseif kb1 >= 4500 && kb1 < 5100
                Vst = 153;
            elseif kb1 >= 5100
                Vst = 150;
            else
                Vst = 0;
            end
        end

        function vrijednost = dohvatiKapitalnuVrijednost(fileName, kb1, godinaStarosti)

          % Učitavanje cijele tablice kao tekst
          fid = fopen(fileName, 'r');
          if fid == -1
              error('Ne mogu otvoriti datoteku: %s', fileName);
          end

          % Prvi redak -> godine
          prviRed = fgetl(fid);
          colHeaders = strsplit(strtrim(prviRed), ',');
          godine = str2double(colHeaders(2:end));
          %%%fprintf('godine: %d\n', godine);

          vrijednost = 60;

          % Inicijalizacija
          kapaciteti = [];
          vrijednosti = [];

          % Parsiranje ostatka redova
          while ~feof(fid)
              linija = fgetl(fid);
              if ischar(linija)
                  data = strsplit(strtrim(linija), ',');
                  kapaciteti(end+1) = str2double(data{1});
                  redVrijednosti = str2double(data(2:end));
                  vrijednosti = [vrijednosti; redVrijednosti];
              end
          end
          fclose(fid);

          %%%fprintf('kapaciteti: %d\n', kapaciteti);
          %%%fprintf('vrijednosti: %d\n', vrijednosti);

          % Provjera postoji li traženi kb1 i godina
          kap = Chromosome.kapacitetTEUzaCijenu(kb1);
          idxKapacitet = find(kapaciteti == kap);
          idxGodina = find(godine == godinaStarosti);

          if isempty(idxKapacitet)
              error('Kapacitet %d nije pronađen u tablici.', kap);
          end
          if isempty(idxGodina)
              error('Godina starosti %d nije pronađena u tablici.', godinaStarosti);
          end

          % Dohvati vrijednost
          vrijednost = vrijednosti(idxKapacitet, idxGodina);

      end

      function kap = kapacitetTEUzaCijenu(kb1)
            if kb1 < 800
                kap = 400;
            elseif kb1 >= 800 && kb1 < 1000
                kap = 800;
            elseif kb1 >= 1000 && kb1 < 1200
                kap = 1000;
            elseif kb1 >= 1200 && kb1 < 1600
                kap = 1200;
            elseif kb1 >= 1600 && kb1 < 2000
                kap = 1600;
            elseif kb1 >= 2000 && kb1 < 2500
                kap = 2000;
            elseif kb1 >= 2500 && kb1 < 3000
                kap = 2500;
            elseif kb1 >= 3000 && kb1 < 3500
                kap = 3000;
            elseif kb1 >= 3500 && kb1 < 4000
                kap = 3500;
            elseif kb1 >= 4000 && kb1 < 4500
                kap = 4000;
            elseif kb1 >= 4500 && kb1 < 5100
                kap = 4500;
            elseif kb1 >= 5100
                kap = 5100;
            else
                kap = 0;
            end
        end

        function deplasman = deplasmanPoTEU(kb1)
            if kb1 < 400
                deplasman = 9517;
            elseif kb1 >= 400 && kb1 < 800
                deplasman = 9517 + (kb1 - 400) * (15206 - 9517) / 400;
            elseif kb1 >= 800 && kb1 < 1000
                deplasman = 15206 + (kb1 - 800) * (19403 - 15206) / 200;
            elseif kb1 >= 1000 && kb1 < 1200
                deplasman = 19403 + (kb1 - 1000) * (22338 - 19403) / 200;
            elseif kb1 >= 1200 && kb1 < 1600
                deplasman = 22338 + (kb1 - 1200) * (27552 - 22338) / 400;
            elseif kb1 >= 1600 && kb1 < 2000
                deplasman = 27552 + (kb1 - 1600) * (32892 - 27552) / 400;
            elseif kb1 >= 2000 && kb1 < 2500
                deplasman = 32892 + (kb1 - 2000) * (44569 - 32892) / 500;
            elseif kb1 >= 2500 && kb1 < 3000
                deplasman = 44569 + (kb1 - 2500) * (50595 - 44569) / 500;
            elseif kb1 >= 3000 && kb1 < 3500
                deplasman = 50595 + (kb1 - 3000) * (58637 - 50595) / 500;
            elseif kb1 >= 3500 && kb1 < 4000
                deplasman = 58637 + (kb1 - 3500) * (68650 - 58637) / 500;
            elseif kb1 >= 4000 && kb1 < 5100
                deplasman = 68650 + (kb1 - 4000) * (77551 - 68650) / 500;
            elseif kb1 >= 5100
                deplasman = 77551;
            else
                deplasman = 0;
            end
        end

        function konstanta = konstantaAdmiralitetaPremaTEU(kb1)
            if kb1 < 400
                konstanta = 350;
            elseif kb1 >= 400 && kb1 < 800
                konstanta = 350;
            elseif kb1 >= 800 && kb1 < 1000
                konstanta = 450;
            elseif kb1 >= 1000 && kb1 < 1200
                konstanta = 450;
            elseif kb1 >= 1200 && kb1 < 1600
                konstanta = 450;
            elseif kb1 >= 1600 && kb1 < 2000
                konstanta = 450;
            elseif kb1 >= 2000 && kb1 < 2500
                konstanta = 500;
            elseif kb1 >= 2500 && kb1 < 3000
                konstanta = 500;
            elseif kb1 >= 3000 && kb1 < 3500
                konstanta = 550;
            elseif kb1 >= 3500 && kb1 < 4000
                konstanta = 550;
            elseif kb1 >= 4000 && kb1 < 4500
                konstanta = 575;
            elseif kb1 >= 4500
                konstanta = 625;
            else
                konstanta = 0;
            end
        end


        function koef = koeficijentPremaTEU(kb1)
          if kb1 < 1000
              koef = 1500;
          elseif kb1 < 1600
              koef = 2000;
          elseif kb1 < 2000
              koef = 2500;
          elseif kb1 < 3000
              koef = 3000;
          elseif kb1 < 4000
              koef = 3500;
          elseif kb1 < 5100
              koef = 4000;
          else
              koef = 5000;
          end
      end

      function kp2 = kp2PremaTEUpremaStarosti(kb1, godinaStarosti)
          if kb1 < 600
              if godinaStarosti >= 0 && godinaStarosti < 5
                  kp2 = 2.63;
              elseif godinaStarosti < 10
                  kp2 = 2.35;
              elseif godinaStarosti < 15
                  kp2 = 2.00;
              elseif godinaStarosti < 20
                  kp2 = 2.03;
              elseif godinaStarosti < 25
                  kp2 = 2.05;
              else
                  kp2 = 2.09;
              end
          elseif kb1 < 800
              if godinaStarosti >= 0 && godinaStarosti < 5
                  kp2 = 1.98;
              elseif godinaStarosti < 10
                  kp2 = 1.77;
              elseif godinaStarosti < 15
                  kp2 = 1.51;
              elseif godinaStarosti < 20
                  kp2 = 1.54;
              elseif godinaStarosti < 25
                  kp2 = 1.59;
              else
                  kp2 = 1.62;
              end
          elseif kb1 < 1000
              if godinaStarosti >= 0 && godinaStarosti < 5
                  kp2 = 1.62;
              elseif godinaStarosti < 10
                  kp2 = 1.45;
              elseif godinaStarosti < 15
                  kp2 = 1.23;
              elseif godinaStarosti < 20
                  kp2 = 1.25;
              elseif godinaStarosti < 25
                  kp2 = 1.29;
              else
                  kp2 = 1.34;
              end
          elseif kb1 < 1200
              if godinaStarosti >= 0 && godinaStarosti < 5
                  kp2 = 1.39;
              elseif godinaStarosti < 10
                  kp2 = 1.24;
              elseif godinaStarosti < 15
                  kp2 = 1.06;
              elseif godinaStarosti < 20
                  kp2 = 1.09;
              elseif godinaStarosti < 25
                  kp2 = 1.13;
              else
                  kp2 = 1.15;
              end
          elseif kb1 < 1500
              if godinaStarosti >= 0 && godinaStarosti < 5
                  kp2 = 1.22;
              elseif godinaStarosti < 10
                  kp2 = 1.09;
              elseif godinaStarosti < 15
                  kp2 = 0.90;
              elseif godinaStarosti < 20
                  kp2 = 0.92;
              elseif godinaStarosti < 25
                  kp2 = 0.96;
              else
                  kp2 = 0.98;
              end
          elseif kb1 < 2000
              if godinaStarosti >= 0 && godinaStarosti < 5
                  kp2 = 1.04;
              elseif godinaStarosti < 10
                  kp2 = 0.93;
              elseif godinaStarosti < 15
                  kp2 = 0.79;
              elseif godinaStarosti < 20
                  kp2 = 0.81;
              elseif godinaStarosti < 25
                  kp2 = 0.85;
              else
                  kp2 = 0.88;
              end
          elseif kb1 < 2500
              if godinaStarosti >= 0 && godinaStarosti < 5
                  kp2 = 0.85;
              elseif godinaStarosti < 10
                  kp2 = 0.76;
              elseif godinaStarosti < 15
                  kp2 = 0.62;
              elseif godinaStarosti < 20
                  kp2 = 0.74;
              elseif godinaStarosti < 25
                  kp2 = 0.79;
              else
                  kp2 = 0.82;
              end
          elseif kb1 < 3000
              if godinaStarosti >= 0 && godinaStarosti < 5
                  kp2 = 0.73;
              elseif godinaStarosti < 10
                  kp2 = 0.65;
              elseif godinaStarosti < 15
                  kp2 = 0.56;
              elseif godinaStarosti < 20
                  kp2 = 0.60;
              elseif godinaStarosti < 25
                  kp2 = 0.63;
              else
                  kp2 = 0.68;
              end
          elseif kb1 < 3500
              if godinaStarosti >= 0 && godinaStarosti < 5
                  kp2 = 0.64;
              elseif godinaStarosti < 10
                  kp2 = 0.58;
              elseif godinaStarosti < 15
                  kp2 = 0.49;
              elseif godinaStarosti < 20
                  kp2 = 0.53;
              elseif godinaStarosti < 25
                  kp2 = 0.57;
              else
                  kp2 = 0.60;
              end
          elseif kb1 < 4000
              if godinaStarosti >= 0 && godinaStarosti < 5
                  kp2 = 0.57;
              elseif godinaStarosti < 10
                  kp2 = 0.52;
              elseif godinaStarosti < 15
                  kp2 = 0.43;
              elseif godinaStarosti < 20
                  kp2 = 0.47;
              elseif godinaStarosti < 25
                  kp2 = 0.52;
              else
                  kp2 = 0.55;
              end
          elseif kb1 < 4500
              if godinaStarosti >= 0 && godinaStarosti < 5
                  kp2 = 0.53;
              elseif godinaStarosti < 10
                  kp2 = 0.47;
              elseif godinaStarosti < 15
                  kp2 = 0.40;
              elseif godinaStarosti < 20
                  kp2 = 0.44;
              elseif godinaStarosti < 25
                  kp2 = 0.49;
              else
                  kp2 = 0.53;
              end
          elseif kb1 < 5100
              if godinaStarosti >= 0 && godinaStarosti < 5
                  kp2 = 0.48;
              elseif godinaStarosti < 10
                  kp2 = 0.43;
              elseif godinaStarosti < 15
                  kp2 = 0.37;
              elseif godinaStarosti < 20
                  kp2 = 0.42;
              elseif godinaStarosti < 25
                  kp2 = 0.45;
              else
                  kp2 = 0.48;
              end
          else
              if godinaStarosti >= 0 && godinaStarosti < 5
                  kp2 = 0.44;
              elseif godinaStarosti < 10
                  kp2 = 0.39;
              elseif godinaStarosti < 15
                  kp2 = 0.33;
              elseif godinaStarosti < 20
                  kp2 = 0.35;
              elseif godinaStarosti < 25
                  kp2 = 0.39;
              else
                  kp2 = 0.43;
              end
          end
      end



      function koef = kp3PremaTEUpremaStarosti(kb1, godinaStarosti)
          if kb1 < 600
              koef = Chromosome.starostKoef([1.05, 1.20, 1.45, 2.09, 3.03, 3.91], godinaStarosti);
          elseif kb1 < 800
              koef = Chromosome.starostKoef([0.88, 1.02, 1.14, 2.07, 2.99, 3.87], godinaStarosti);
          elseif kb1 < 1000
              koef = Chromosome.starostKoef([0.74, 0.80, 0.96, 2.01, 2.96, 3.83], godinaStarosti);
          elseif kb1 < 1200
              koef = Chromosome.starostKoef([0.65, 0.69, 0.84, 1.98, 2.93, 3.79], godinaStarosti);
          elseif kb1 < 1500
              koef = Chromosome.starostKoef([0.55, 0.62, 0.75, 1.94, 2.90, 3.76], godinaStarosti);
          elseif kb1 < 2000
              koef = Chromosome.starostKoef([0.48, 0.55, 0.66, 1.92, 2.88, 3.72], godinaStarosti);
          elseif kb1 < 2500
              koef = Chromosome.starostKoef([0.40, 0.46, 0.53, 1.81, 2.84, 3.69], godinaStarosti);
          elseif kb1 < 3000
              koef = Chromosome.starostKoef([0.35, 0.45, 0.59, 1.77, 2.80, 3.64], godinaStarosti);
          elseif kb1 < 3500
              koef = Chromosome.starostKoef([0.32, 0.36, 0.44, 1.73, 2.77, 3.61], godinaStarosti);
          elseif kb1 < 4000
              koef = Chromosome.starostKoef([0.28, 0.33, 0.47, 1.70, 2.73, 3.59], godinaStarosti);
          elseif kb1 < 4500
              koef = Chromosome.starostKoef([0.27, 0.31, 0.36, 1.65, 2.68, 3.55], godinaStarosti);
          elseif kb1 < 5100
              koef = Chromosome.starostKoef([0.25, 0.28, 0.33, 1.62, 2.65, 3.53], godinaStarosti);
          else
              koef = Chromosome.starostKoef([0.23, 0.26, 0.31, 1.60, 2.63, 3.50], godinaStarosti);
          end
      end

      function value = starostKoef(values, godinaStarosti)
          if godinaStarosti >= 0 && godinaStarosti < 5
              value = values(1);
          elseif godinaStarosti >= 5 && godinaStarosti < 10
              value = values(2);
          elseif godinaStarosti >= 10 && godinaStarosti < 15
              value = values(3);
          elseif godinaStarosti >= 15 && godinaStarosti < 20
              value = values(4);
          elseif godinaStarosti >= 20 && godinaStarosti < 25
              value = values(5);
          else
              value = values(6);
          end
      end



  end
end
