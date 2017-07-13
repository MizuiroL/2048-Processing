import ddf.minim.*;
import ddf.minim.effects.*;

int dimWindow = 500;                                                             //Dimensione della finestra
int numSqr = 4;                                                                  //Numero di quadrati per lato (di base è 4)
int dimSqr = dimWindow / numSqr;                                                 //La dimensione dei quadrati varia in modo inversamente proporzionale al numero dei quadrati
int numBase = 2;
int i, h, j;
int[][] mat = new int[numSqr][numSqr];                                           //La matrice in cui si trovano i numeri visualizzati
boolean gener = false, somma = false, click = false;
int numGen;                                                                      //Serve nell'algoritmo dopo per generare un numero in posizione casuale
boolean up = false, down = false, left = false, right = false;                   //Quando un tasto verrà cliccato viene messo a vero la variabile corrispondente
int score=0, scene=0;                                                            //Punteggio e scena (0=reset variabili, 1=menu principale, 2=gioco, 3=schermata fine gioco)

PFont clearSans;                                                                 //Lo stesso font che ha il 2048 originale
Minim minim;                                                                     //Carica il file audio
AudioPlayer song;

void setup(){
  size(dimWindow+100, dimWindow+250);                                            //dimWindow è la dimensione della matrice, il resto dello spazio serve per il testo
  //frameRate(10);
  clearSans = loadFont("ClearSans-Bold-48.vlw");                                 //Carica il font
  textFont(clearSans);
  minim = new Minim(this);                                                       //Roba per riprodurre in loop l'audio
  song = minim.loadFile("loop.wav");
  song.loop();
}

void draw(){
  background(#EADBCE);                                                           //Il colore dello sfondo è simile a quello dell'area di gioco, ma più chiaro

  if(scene==0){                                                                  //Non viene visualizzato nulla ma tutte le variabili vengono resettate per poter iniziare il gioco
    score=0;
    clearMat();                                                                  //Rimette a 0 ogni elemento della matrice
    gener=false;                                                                 //Una volta partito il gioco verrà generato un numero perché gener sarà di nuovo falso
    scene++;
  }
  
  if(scene==1){                                                                  //Schermata del titolo
    writeText();                                                                 //Questa funzione ogni volta si chiede a sua volta qual è la scena
    if(click){                                                                   //Il gioco parte al click del mouse
      scene++;
      click=false;
    }
  }
  
  if(scene==2){                                                                  //Il gioco vero e proprio
    drawMat();                                                                   //Disegna l'area di gioco
    writeText();                                                                 //Scrive il testo della scena 2
    if (fineGioco()) scene++;                                                    //La funzione fineGioco controlla ad ogni frame se ci sono mosse possibili (se non ci sono finisce il gioco)
    if(gener==false) generateNum();                                              //Se gener è falso significa che deve essere generato un altro numero in posizione casuale
        
    if(up == true){                                                              //Per ogni tasto cliccato (WASD) viene chiamata la funzione corrispondente
      up();
      up = false;
    }
    if(down == true){
      down();
      down = false;
    }
    if(left == true){
      left();
      left = false;
    }
    if(right == true){
      right();
      right = false;
    }
  }
  
  if(scene==3){                                                                  //Nella scena di fine gioco resta l'area di gioco com'era prima e viene stampato il testo
    drawMat();
    writeText();
    if(click){                                                                   //Al click del mouse si ritorna nella schermata del titolo
      scene=0;
      click=false;
    }
  }
}
  
void clearMat(){                                                                 //Mette ogni elemento della matrice a 0
  for(i=0; i<numSqr; i++){
    for(h=0; h<numSqr; h++) mat[i][h] = 0;
  }
}

void drawMat(){
  stroke(#BBADA0); strokeWeight(100/(numSqr*2));                                 //Spessore e colore del bordo della matrice
  for(i=0; i<numSqr; i++){
    for(h=0; h<numSqr; h++){
      if(mat[i][h]==0) fill(#D3C6BA);                                            //Ogni numero ha un colore diverso
      if(mat[i][h]==numBase) fill(#F5F5F5);                                      //Ho usato numBase e non i numeri veri e propri così da andare bene anche se numBase non dovesse essere 2
      if(mat[i][h]==numBase*2) fill(#F5F5DC);                                    //Ho trovato l'esadecimale di ogni colore su Wikipedia
      if(mat[i][h]==numBase*4) fill(#FFA07A);
      if(mat[i][h]==numBase*8) fill(#FF7F50);
      if(mat[i][h]==numBase*16) fill(#FF6347);
      if(mat[i][h]==numBase*32) fill(#FF0000);
      if(mat[i][h]==numBase*64) fill(#FFF060);
      if(mat[i][h]==numBase*128) fill(#F0E050);
      if(mat[i][h]==numBase*256) fill(#F0E010);
      if(mat[i][h]==numBase*512) fill(#F0D000);
      if(mat[i][h]==numBase*1024) fill(#F0C000);
      if(mat[i][h]>=numBase*2048) fill(0);
      rect(dimSqr*h+50, dimSqr*i+100, dimSqr, dimSqr);                           //Disegna effettivamente la tabella
    }
  }
}

void writeText(){
  if(scene==1){                                                                  
    fill(#776E65);
    textAlign(CENTER, CENTER);
    textSize(72);
    text("2048", width/2, height/2-100);
    textSize(36);
    text("Premi il mouse per iniziare", width/2, height/2);
    textAlign(LEFT, CENTER);
    textSize(24);
    text("Luca Donzelli", 0, height-50);
  }
  
  textAlign(CENTER, CENTER);
  fill(#776E65);
  textSize(48);
  
  text("Score: "+score, width/2, dimWindow+175);                                 //Il punteggio è l'unico testo a comparire in ogni scena
  if(scene==2) text("2048", width/2, 50);
  if(scene==3){
    text("Hai perso!", width/2, 50);
    textSize(30);
    text("Premi il mouse per tornare al menu", width/2, dimWindow+230);
  }
  
  for(i=0; i<numSqr; i++){
    for(h=0; h<numSqr; h++){
      if(mat[i][h] <= numBase*2) fill(#776E65);                                  //numBase e numBase*2 saranno scuri, mentre gli altri numeri chiari
      else fill(#F9F6F2);
      if(mat[i][h] < 100) textSize(200/numSqr);                                  //Modifica leggermente la dimensione per farla stare in un quadrato
      if(mat[i][h] > 100 && mat[i][h] < 1000) textSize(180/numSqr);
      if(mat[i][h] > 1000) textSize(150/numSqr);
      if(mat[i][h] != 0) text(mat[i][h], dimSqr*h + dimSqr/2 + 50, dimSqr*i + dimSqr/2 + 100);  //Stampa il numero se è diverso da 0, il numero viene centrato nel quadrato
    }
  }
}

void generateNum(){                                                              //Genera un numBase in posizione casuale
  for(i=0; i<numSqr && !gener; i++){
    for(h=0; h<numSqr && !gener; h++){
      if(mat[i][h]==0){
        numGen = (int)random(0, numSqr*numSqr-1-(i*numSqr)-h);                   //Se l'elemento della matrice in cui si trovano gli indici è 0 viene generato un numero
        if(numGen == 0){                                                         //Se questo numero è 0 viene inserito il numBase in quella posizione
          mat[i][h] = numBase;                                                   //Ho realizzato la formula in modo che sicuramente venga inserito un numero in una posizione (al massimo l'ultimo)
          gener = true;                                                          //E in modo cbe si adattasse ad ogni dimensione della tabella
          score = score + numBase;                                               //Gener diventa true così non verrà generato un altro numero
        }                                                                        //Lo score viene aumentato di numBase
      }
    }
  }
}

void keyReleased(){                                                              //Legge quale tasto è stato premuto
  if(key == 'w' || key == 'W') up = true;
  if(key == 's' || key == 'S') down = true;
  if(key == 'a' || key == 'A') left = true;
  if(key == 'd' || key == 'D') right = true;
}

void up(){                                                                       //Per ogni direzione, il programma:
  for(i=0; i<numSqr; i++){
    for(h=0; h<numSqr; h++){
      if(mat[i][h]>0 && i>0){
        j = 1;
        somma = false;
        do{
          if(mat[i-j][h]==0){                                                    //Calcola e fa ogni spostamento possibile
            mat[i-j][h] = mat[i-j+1][h];
            mat[i-j+1][h] = 0;
            gener = false;
          }
          else if(mat[i-j][h] == mat[i-j+1][h] && !somma){                       //E somma in caso ci siano due numeri uguali, la booleana somma servirebbe ad evitare doppie somme (4 2 2 diventa 4 4 e non 8), ogni tanto non funziona per ragioni sconosciute ma i nostri esperti sono a lavoro per risolvere
            mat[i-j][h] = mat[i-j][h]*2;
            mat[i-j+1][h] = 0;
            gener = false;
            somma = true;
            score = score + mat[i-j][h];
          }
          j++;
        }while(i-j>=0);                                                          //Non ricordo precisamente come funziona ma quel j è parecchio importante
        somma = false;
      }
    }
  }
}

void down(){
  for(i=numSqr-1; i>=0; i--){
    for(h=0; h<numSqr; h++){
      if(mat[i][h]>0 && i<numSqr-1){
        j = 1;
        somma = false;
        do{
          if(mat[i+j][h]==0){
            mat[i+j][h] = mat[i+j-1][h];
            mat[i+j-1][h] = 0;
            gener = false;
          }
          else if(mat[i+j][h] == mat[i+j-1][h] && !somma){
            mat[i+j][h] = mat[i+j][h]*2;
            mat[i+j-1][h] = 0;
            gener = false;
            somma = true;
            score = score + mat[i+j][h];
          }
          j++;
         }while(i+j<numSqr);
         somma = false;
      }
    }
  }
}

void left(){
  for(i=0; i<numSqr; i++){
    for(h=0; h<numSqr; h++){
      if(mat[i][h]>0 && h>0){
        j = 1;
        somma = false;
        do{
          if(mat[i][h-j]==0){
            mat[i][h-j] = mat[i][h-j+1];
            mat[i][h-j+1] = 0;
            gener = false;
          }
          else if(mat[i][h-j] == mat[i][h-j+1] && !somma){
            mat[i][h-j] = mat[i][h-j]*2;
            mat[i][h-j+1] = 0;
            gener = false;
            somma = true;
            score = score + mat[i][h-j];
          }
          j++;
         }while(h-j>=0);
         somma = false;
      }
    }
  }
}

void right(){
  for(i=0; i<numSqr; i++){
    for(h=numSqr-1; h>=0; h--){
      if(mat[i][h]>0 && h<numSqr-1){
        j = 1;
        somma = false;
        do{
          if(mat[i][h+j]==0){
            mat[i][h+j] = mat[i][h+j-1];
            mat[i][h+j-1] = 0;
            gener = false;
          }
          else if(mat[i][h+j] == mat[i][h+j-1] && !somma){
            mat[i][h+j] = mat[i][h+j]*2;
            mat[i][h+j-1] = 0;
            gener = false;
            somma = true;
            score = score + mat[i][h+j];
          }
          j++;
         }while(h+j<numSqr);
         somma = false;
      }
    }
  }
}

void mouseReleased(){
  click=true;
}

boolean fineGioco(){                                                             //Controlla se ci sono alcune mosse fattibili
  for(i=0; i<numSqr; i++){
    for(h=0; h<numSqr; h++){
      if(mat[i][h] == 0) return false;                                           //Se almeno una casella è vuota è possibile fare una mossa, quindi il gioco non finisce
    }
  }
  for(i=0; i<numSqr; i++){                                                       //Questo ciclo viene effettuato solo se tutte le caselle sono piene
    for(h=0; h<numSqr; h++){
      if(i>0){
        if(mat[i][h] == mat[i-1][h]) return false;                               //Se è possibile fare una somma il gioco non finisce
      }
      if(i<numSqr-1){
        if(mat[i][h] == mat[i+1][h]) return false;
      }
      if(h>0){
        if(mat[i][h] == mat[i][h-1]) return false;
      }
      if(h<numSqr-1){
        if(mat[i][h] == mat[i][h+1]) return false;
      }
    }
  }
  return true;                                                                   //Il programma arriverà a questo punto solo se non è possibile fare somme, quindi il gioco finisce
}
