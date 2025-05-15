populationSize = 3000;
generations = 20;

population(1, populationSize) = Chromosome();

for i = 1:populationSize
    chromosome = Chromosome();
    chromosome = chromosome.calculateFitness();
    population(i) = chromosome;
end

bestAll = [];

for i = 1:generations

    best = population(1);
    for j = 2:length(population)
        if population(j).fitness > best.fitness
            best = population(j);
        end
    end

    if ~isempty(bestAll)
        if best.fitness > bestAll.fitness
            bestAll = Chromosome();
            bestAll.firstGene = best.firstGene;
            bestAll.secondGene = best.secondGene;
            bestAll.thirdGene = best.thirdGene;
            bestAll.fitness = best.fitness;
        end
    else
        bestAll = Chromosome();
        bestAll.firstGene = best.firstGene;
        bestAll.secondGene = best.secondGene;
        bestAll.thirdGene = best.thirdGene;
        bestAll.fitness = best.fitness;
    end

    fprintf('Generacija %d najbolji fitness: %f\n', i, best.fitness);

    %population = evolvePopulation(population);  % moraš imati ovu funkciju
    newPopulation(1, populationSize) = Chromosome();
    counter = 0;

    while counter < populationSize
        counter = counter + 1;
        % Selektiraj dva roditelja nasumično
        idx1 = randi(populationSize);
        idx2 = randi(populationSize);
        parent1 = population(idx1);
        parent2 = population(idx2);

        % Križanje (placeholder - implementirati kasnije)
        child = Chromosome();
        if rand() > 0.5
            child.firstGene = parent1.firstGene;
        else
            child.firstGene = parent2.firstGene;
        end

        if rand() > 0.5
            child.secondGene = parent1.secondGene;
        else
            child.secondGene = parent2.secondGene;
        end

        if rand() > 0.5
            child.thirdGene = parent1.thirdGene;
        else
            child.thirdGene = parent2.thirdGene;
        end

        % Mutacija (placeholder - implementirati kasnije)
        if rand() < 0.1
            child.firstGene = randi([400, 5100]);
        end
        if rand() < 0.1
            child.secondGene = 12 + randi([0, 70]) * 0.1;
        end
        if rand() < 0.1
            child.thirdGene = randi([0, 25]);
        end

        % Izračunaj fitness
        child = child.calculateFitness();

        % Usporedba s postojećim kromosomom
        current = population(counter);
        if child.fitness > current.fitness
            newPopulation(counter) = child;
        else
            newPopulation(counter) = current;
        end
    end

    % Izračunaj medijan fitnessa
    fitnessValues = zeros(1, numel(newPopulation));
    for j = 1:populationSize
        fitnessValues(j) = newPopulation(j).fitness;
    end
    fitnessMedian = median(fitnessValues);

    % Zamjena kromosoma ispod medijana novima
    for j = 1:populationSize
        if newPopulation(j).fitness < fitnessMedian
            newChrom = Chromosome();
            newChrom = newChrom.calculateFitness();
            newPopulation(j) = newChrom;
        end
    end

    % Ažuriraj populaciju
    population = newPopulation;
end

fprintf('Najbolji od svih fitness: %f\n', bestAll.fitness);

kb1  = bestAll.firstGene;
%kb1 = 1825;
fprintf('Skladišni kapacitet: %d\n', kb1);

v = bestAll.secondGene;
%v = 16.4;
fprintf('Brzina (cv): %f\n', v);

godinaStarosti = bestAll.thirdGene;
%godinaStarosti = 19;
fprintf('Godina starosti: %d\n', godinaStarosti);

Vst = Chromosome.vozarinaPremaTEU(kb1); % Funkcija, iz tablice
fprintf('Vozarina: %d\n', Vst);

qg = 0.17;  % kg/kWh

file = 'vrijednostBroda.txt';
Kcb = Chromosome.dohvatiKapitalnuVrijednost(file, kb1, godinaStarosti); % iz .txt datoteke
fprintf('Kapitalna cijena broda: %d\n', Kcb);


D = Chromosome.deplasmanPoTEU(kb1);            % deplasman
fprintf('Deplasman: %d\n', D);
D23 = D^(2.0/3);
fprintf('D 2/3: %f\n', D23);
kA = Chromosome.konstantaAdmiralitetaPremaTEU(kb1);
fprintf('Konstanta admiraliteta: %f\n', kA);
kp1 = Chromosome.koeficijentPremaTEU(kb1);
fprintf('KP1: %f\n', kp1);
kp2 = Chromosome.kp2PremaTEUpremaStarosti(kb1, godinaStarosti);
fprintf('KP2: %f\n', kp2);
kp3 = Chromosome.kp3PremaTEUpremaStarosti(kb1, godinaStarosti);
fprintf('KP3: %f\n', kp3);

%% PRIHODI %%
Dl = 2210;           % milja
fprintf('Duljina putovanja: %d\n', Dl);

kolicinaTereta2luke = [];  % inicijalizacija vektora
kolicinaTereta2luke(end+1) = 1500;  % teret između dvije luke
kolicinaTereta2luke(end+1) = 1950;  % teret između dvije luke
kolicinaTereta2luke(end+1) = 2130;  % teret između dvije luke
% kolicinaTereta2luke(end+1) = 650; % ako dodaješ više luka

delta = [];  % inicijalizacija rezultujućeg vektora
for i = 1:length(kolicinaTereta2luke)
    delta(end+1) = kolicinaTereta2luke(i) / kb1;
end

fprintf('Delta: %d\n', delta);

duljinaUMiljama1 = 973;
duljinePutovanja2Luka = {};
duljinePutovanja2Luka{end+1} = duljinaUMiljama1 / v / 24;  % u danima
duljinaUMiljama1 = 1036;
duljinePutovanja2Luka{end+1} = duljinaUMiljama1 / v / 24;  % u danima
duljinaUMiljama1 = 201;
duljinePutovanja2Luka{end+1} = duljinaUMiljama1 / v / 24;  % u danima


% Računanje lambde
lambda = [];
for i = 1:length(duljinePutovanja2Luka)
    lambda(end+1) = duljinePutovanja2Luka{i} / (Dl / v / 24);
end
fprintf('Lambda: %d\n', lambda);

sumaProduktaOmjeraDuljineKolicine = 0;

for i = 1:length(lambda)
    sumaProduktaOmjeraDuljineKolicine = sumaProduktaOmjeraDuljineKolicine + delta(i) * lambda(i);
end
fprintf('Suma produkta omjera duljine (delta) i kolicine (lambda): %f\n', sumaProduktaOmjeraDuljineKolicine);

obrtajKontejnera = 4050;
prihodiUkupno = Vst * obrtajKontejnera * sumaProduktaOmjeraDuljineKolicine;
fprintf('Prihodi: %f\n', prihodiUkupno);
%% PRIHODI %%

%% TROŠKOVI %%
prviDioTroskoviTAS = 1500 + 1230 + 1340 + 1400 + 0;

cg = 0.62;  % cijena goriva pomoćnog motora ($/kg)
cp = 0.85;  % cijena goriva pomoćnog kotla ($/kg)

% Pretpostavlja se da su qg, v, D23, kA i Dl već definirani u prethodnom kodu

trosakGoriva = (24 * (qg * cg * v^3 * D23 / kA) + 24 * (0.05 * qg * cp * v^3 * D23 / kA)) * Dl / 24 / v;
troskoviPlovidbeUkupno = prviDioTroskoviTAS + trosakGoriva;

fprintf('Trošak plovidbe: %f\n', troskoviPlovidbeUkupno);
fprintf('     Trošak TAŠ: %f\n', prviDioTroskoviTAS);
fprintf('     Trošak goriva: %f\n', trosakGoriva);

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
% fprintf('Prva zagrada troškovi: %f\n', prvaZagradaTroskovi);

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
sumaDl = sum(dL1i + dL2i); % Sabiranje odgovarajućih elemenata iz dL1i i dL2i i njihovo sumiranje

% Parametri
vManovre = 8;  % Brzina manevre
% Treća zagrada troškovi
trecaZagradaTroskovi = (24 * qg * cg * (vManovre^3) * D23 / kA * ukupnoVrijemeManovre + 0.05 * 24 * qg * cg * (vManovre^3) * D23 / kA) * sumaDl;

% Ukupni trošak broda u luci
troskoviBrodaULuciUkupno = prvaZagradaTroskovi + drugaZagradaTroskovi + trecaZagradaTroskovi;

% Ispis rezultata
fprintf('Trošak broda u luci: %.2f\n', troskoviBrodaULuciUkupno);
fprintf('     Troškovi (lučke takse, sigurnost plovidbe, peljarenje): %.2f\n', prvaZagradaTroskovi);
fprintf('     Troškovi manipulacije: %.2f\n', drugaZagradaTroskovi);
fprintf('     Troškovi goriva u luci: %.2f\n', trecaZagradaTroskovi);

% Prva zagrada
prvaZagradaOperativa = kp1 + kp2 * D + kp3 * D23;

% Druga zagrada: prihvat broda u luci i otprema + iskrcavanje
dlp = 0.0833;  % vrijeme prihvata broda i otpreme
dll = 0.993;   % iskrcavanje
drugaZagradaOperativa_dlp_dll = sumaDl;

% Treći dio: vrijeme plovidbe
treciDio_Dl24v = Dl / 24 / v;

% Ukupni trošak operative
troskoviOperativeUkupno = prvaZagradaOperativa * (drugaZagradaOperativa_dlp_dll + treciDio_Dl24v);
fprintf('Trošak operative: %.2f\n', troskoviOperativeUkupno);

sviTroskovi = (troskoviBrodaULuciUkupno + troskoviOperativeUkupno + troskoviPlovidbeUkupno);
fprintf('Svi troškovi: %.2f\n', sviTroskovi);

%% TROŠKOVI %%

ekonomicnost = prihodiUkupno / (troskoviBrodaULuciUkupno + troskoviOperativeUkupno + troskoviPlovidbeUkupno);
fprintf('Ekonomičnost: %.4f\n', ekonomicnost);

Tgva = godinaStarosti;    % broj godina otpisivanja broda
Vtb = 25;   % vijek trajanja broda
Csz = 400;  % vrijednost broda kao staro željezo ($/tona)
treciDioFormule = drugaZagradaOperativa_dlp_dll + treciDio_Dl24v;
KapitalnaVrijednostBroda = (Kcb - Tgva * Kcb / Vtb + D * Csz) * 1.05;
fprintf('      Kapitalna cijena broda: %.2f\n', Kcb);
fprintf('      Amortizacija: %.2f\n', Tgva * Kcb / Vtb);
fprintf('      Vrijednost broda staro željezo: %.2f\n', D * Csz);
fprintf('Kapitalna vrijednost broda: %.2f\n', KapitalnaVrijednostBroda);

dobit = prihodiUkupno - troskoviBrodaULuciUkupno - troskoviOperativeUkupno - troskoviPlovidbeUkupno;
rentabilnost = dobit / (KapitalnaVrijednostBroda * treciDioFormule);
fprintf('Dobit: %.2f\n', dobit);
fprintf('Rentabilnost: %.6f\n', rentabilnost);

ukupnoPrevezeniTeret = 4050;
bcp = 16;  % broj članova posade

% Produktivnost broda
produktivnost = (prihodiUkupno - troskoviBrodaULuciUkupno - troskoviOperativeUkupno - troskoviPlovidbeUkupno) / (bcp * (dlp + kb1 * dll + treciDioFormule));

sviTroskovi = troskoviBrodaULuciUkupno + troskoviOperativeUkupno + troskoviPlovidbeUkupno;

fprintf('Produktivnost: %.6f\n', produktivnost);
fprintf('Prihodi - troškovi: %.2f\n', prihodiUkupno - sviTroskovi);
fprintf('Produktivnost po članu posade po danu određenog putovanja: %.6f\n', ...
        (prihodiUkupno - sviTroskovi) / bcp / ((Dl / v / 24) + drugaZagradaOperativa_dlp_dll));
fprintf('Trošak po prevezenom TEU: %.6f\n', sviTroskovi / ukupnoPrevezeniTeret);
fprintf('Vrijeme plovidbe (u danima): %.2f\n', (Dl / v / 24));
fprintf('Trošak operative (po danu): %.2f\n', troskoviOperativeUkupno / ((Dl / v / 24) + sumaDl));

