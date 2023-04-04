close all
clear all
clc
warning off all

clases = input("No. de clases:");
numrepre = input("No. de representantes por clase:");
dispX = input("¿Cuanta dispersion quieres en x?");
dispY = input("¿Cuanta dispersion quieres en y?");

media = zeros(1, 2.*clases);
ConjuntodeDatos = zeros(2,numrepre,clases);

for i = 1:clases
    
    cenX = input("Centro X para la clase:");
    cenY = input("Centro Y para la clase");
    
    cx = (randn(1,numrepre)+cenX)*dispX;
    cy = (randn(1,numrepre)+cenY)*dispY;

    Unionx_y= vertcat(cx,cy);
    ConjuntodeDatos(:,:,i)= Unionx_y;
    media(i) = mean(cx);
    media(i+clases) = mean(cy);
    
    figure(1)
    plot(cx(1,:),cy(1,:),'.','MarkerSize',25,'DisplayName', strcat('Clase ',num2str(i)))
    grid on
    hold on
    legend show
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Hacemoselcalculodelasdistancias%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
persona = 0;
bandera = 'S';
while bandera == 'S'
    persona = persona + 1;
    valor=0;
    ux = input('Ingrese X de la nueva persona: ');
    uy = input('Ingrese Y de la nueva persona: ');
    tipoDistancia = input('¿Que criterio de desiciones quieres? \n 1.Mahalanobi \n 2.Euclideana \n 3.Maxima Probabilidad');
    text(ux,uy,cellstr(num2str(persona)),'FontSize',15);

    if tipoDistancia == 1 
        [valor,disMahalanobi] = Mahalanobi(ux,uy,media,ConjuntodeDatos,clases);
        disMahalanobi
         fprintf("Pertenece a la facultad: %d\n",valor);
    elseif tipoDistancia == 2      
        [valor,disEuclideana]=Euclideana(ux,uy,media,clases);
        disEuclideana
         fprintf("Pertenece a la facultad: %d\n",valor);

    elseif tipoDistancia == 3
        [valor,disMaxProb,sepuede, probabilidades] = MaximaProbabilidad(ux,uy,media,ConjuntodeDatos,clases);  
        if sepuede== 0
             probabilidades
             disMaxProb
             fprintf("Pertenece a la facultad: %d\n",valor);
         else
             fprintf("Muy lejos");
        end   
    end

    prompt = "\nQuisiera ingresar otro? S/N: ";
    bandera = input(prompt,"s");
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%Matriz de confucion
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%555


fprintf("Matriz de confusion");
matrizConfusionMaha = zeros(clases,clases);
matrizConfusionEuclideana = zeros(clases,clases);
matrizConfusionMaxProba = zeros(clases,clases);
pruebasPorClase = round(numrepre);
pruebas = zeros(4,pruebasPorClase*clases);

for i = 1:clases
    for j = 1:pruebasPorClase
        pruebas(1, j+(i-1)*pruebasPorClase) = i;
        [pruebas(2, j+(i-1)*pruebasPorClase),rand]= Mahalanobi(ConjuntodeDatos(1,j,i),ConjuntodeDatos(2,j,i),media,ConjuntodeDatos,clases);
        [pruebas(3, j+(i-1)*pruebasPorClase),rand]= Euclideana(ConjuntodeDatos(1,j,i),ConjuntodeDatos(2,j,i),media,clases);
        [pruebas(4, j+(i-1)*pruebasPorClase),rand,sepuede,probabilidades]= MaximaProbabilidad(ConjuntodeDatos(1,j,i),ConjuntodeDatos(2,j,i),media,ConjuntodeDatos,clases);
    end
end

for i=1:pruebasPorClase*clases
    matrizConfusionMaha(pruebas(1,i), pruebas(2,i)) = matrizConfusionMaha(pruebas(1,i), pruebas(2,i))+1;
    matrizConfusionEuclideana(pruebas(1,i), pruebas(3,i)) = matrizConfusionEuclideana(pruebas(1,i), pruebas(3,i))+1;
    matrizConfusionMaxProba(pruebas(1,i), pruebas(4,i)) = matrizConfusionMaxProba(pruebas(1,i), pruebas(4,i))+1;
end

lineaprinmaha=0;
lineaprinEuclideana=0;
lineaprinMaxProb=0;

porclasemaha = zeros(clases);
porclaseeuclide = zeros(clases);
porclaseMaxProb = zeros(clases);

for i=1:clases
    lineaprinEuclideana = lineaprinEuclideana + matrizConfusionEuclideana(i,i);
    lineaprinmaha = lineaprinmaha + matrizConfusionMaha(i,i);
    lineaprinMaxProb = lineaprinMaxProb + matrizConfusionMaxProba(i,i);
    
    porclaseeuclide(i) = (matrizConfusionEuclideana(i,i)*100)/numrepre;
    porclasemaha(i)= (matrizConfusionMaha(i,i)*100)/numrepre;
    porclaseMaxProb(i) =(matrizConfusionMaxProba(i,i)*100)/numrepre;
end

acuracymaha= (lineaprinmaha*100)/(numrepre*clases);
acuracyeuclideana= (lineaprinEuclideana*100)/(numrepre*clases);
acuracyMaxProb = (lineaprinMaxProb*100)/(numrepre*clases);

fprintf("Matriz de confusion de Mahalanobi")
matrizConfusionMaha
fprintf("presion de ");
acuracymaha
porclasemaha

fprintf("Matriz de confusion de Euclideana")
matrizConfusionEuclideana
fprintf("con precision de");
acuracyeuclideana
porclaseeuclide

fprintf("Matriz de confusion de Maxima Probabilidad")
matrizConfusionMaxProba
fprintf("con precision de");
acuracyMaxProb
porclaseMaxProb



disp("Fin de proceso")
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Funcion Mahalanobi %%%%%%%%%%%%%
function [valor,disMahalanobi] = Mahalanobi(ux,uy,media,ConjuntodeDatos,clases)
    disMahalanobi = zeros(1,clases);
    for i = 1:clases
         uxmedia = ux-media(i);
         uymedia = uy-media(i+clases);
         matrizper = horzcat(uxmedia,uymedia);
         covarianza = cov(ConjuntodeDatos(:,:,i)','omitrows');
         disMahalanobi(i) = matrizper*covarianza*matrizper';  
     end
    minimo = min(min(disMahalanobi));
    valor = find(disMahalanobi==minimo);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Funcion Euclideana %%%%%%%%%%%%%

function [valor,disEuclideana] = Euclideana(ux,uy,media,clases)
    disEuclideana= zeros(1,clases);
    for i = 1:clases
        disEuclideana(i) = sqrt((ux-media(i))^2 + (uy-media(i+clases))^2);
    end
    minimo=min(min(disEuclideana));
    valor=find(disEuclideana==minimo);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Funcion MaxProba %%%%%%%%%%%%%
function [valor, prob,sepuede, probabilidades] = MaximaProbabilidad(ux,uy,media,ConjuntodeDatos,clases)
    probabilidades = zeros(1,clases);
    prob = zeros(1,clases);
    sumaa =0;
    sepuede =1;
    for i = 1:clases
         uxmedia = ux-media(i);
         uymedia = uy-media(i+clases);

         matrizper = horzcat(uxmedia,uymedia);
         covarianzatraspuesta= cov(ConjuntodeDatos(:,:,i)','omitrows');
         covarianza = cov(ConjuntodeDatos(:,:,i)','omitrows');
         determinante = (det(covarianza))^(1/2);
         disMaha= matrizper*covarianzatraspuesta*matrizper';

         probabilidades(i) = (1/(((2*pi)^(clases/2))*determinante))* (exp((-1/2)*disMaha));
 
         sumaa = sumaa + probabilidades(i); 
    end
        if sumaa > 0
            for i = 1:clases
                prob(i) = ((probabilidades(i)/sumaa)*100);
            end
             maximo =max(max(prob));
             valor = find(prob==maximo);
             sepuede =0;
        else
            [valor,dis]=Euclideana(ux,uy,media,clases);
            suma = sum(dis);
            for i = 1:clases
                prob(i) = ((dis(i)/suma)*100);
            end
        end
    
 
end

