/* Témoignage, 2017
 * Update: 08/01/18
 *
 * play again the recorded file when recording just finich
 *
 * V2
 * Written by Bastien DIDIER
 *
 */

import processing.serial.*;
import ddf.minim.*;

Serial myPort;

Minim minim;
AudioInput in;
AudioRecorder recorder;
int recorder_countname = 0;
int stop_recording = 60*25;

int[] current_track = {0,0}; //Get current_track on specific audioplayer => current_track[current_audioplayer]
int select_audioplayer = int(random(0,2));
int current_audioplayer = select_audioplayer;
boolean play = false;

/*––––––––––––––––––––––––––––––––––––––––
    AUDIO PLAYER PRE-RECORDED TESTIMONY
–––––––––––––––––––––––––––––––––––––––––*/
public static final String[] testimony = {"aide.mp3","annonce-entourage.mp3","apprendre-la-maladie.mp3","apres-traitement.mp3","attente.mp3","commencement-peinture.mp3","faire-confiance.mp3","forces-cachees.mp3","peindre.mp3","remission.mp3","ressources.mp3","temoigner-pour-les-autres.mp3"};
public static final int nb_testimony = testimony.length; // number of pre-recorded testimony
public static final String testimony_directory = "file/testimony/";
AudioPlayer[] testimony_player = new AudioPlayer[nb_testimony];

/*––––––––––––––––––––––––––––––––––––––––––––––––
    AUDIO PLAYER EMPTY SPACE FOR NEW TESTIMONY
–––––––––––––––––––––––––––––––––––––––––––––––––*/
public static final int nb_recorded_testimony = 40; //total space for recorded testimony
int current_nb_recorded_testimony = 0;
public static final String recorded_testimony_directory = "file/recorded_testimony/";
AudioPlayer[] recorded_testimony_player = new AudioPlayer[nb_recorded_testimony]; // => 0.wav > 39.wav [0,39]

void setup(){
  size(512, 200, P2D);
  frameRate(25);
  
  minim = new Minim(this);
  in = minim.getLineIn(Minim.STEREO, 2048);
  
  textFont(createFont("SanSerif", 12));
  
  /*–––––––––––––––––––––––––––––––––––––––––––––––––––
      load empty space for recorded testimony files
  ––––––––––––––––––––––––––––––––––––––––––––––––––––*/
  for(int i=0; i<nb_recorded_testimony; i++){
    String[] lines = loadStrings(recorded_testimony_directory+str(i)+".wav");
    if (lines == null){
      //print exception
    } else {
      current_nb_recorded_testimony++;
    }
  }
  
  if(current_nb_recorded_testimony != nb_recorded_testimony){
    recorder_countname = current_nb_recorded_testimony;
  }
  
  //Load Recorded Testimony files
  for (int i = 0; i < current_nb_recorded_testimony; i++) {
   recorded_testimony_player[i] = minim.loadFile(recorded_testimony_directory+str(i)+".wav");
  }
  
  newFile(); //Set new file for recording
  
  /*––––––––––––––––––––––––––––––––––––––––
      load pre-recorded testimony files
  –––––––––––––––––––––––––––––––––––––––––*/
  for (int i = 0; i < nb_testimony; i++) {
   testimony_player[i] = minim.loadFile(testimony_directory+testimony[i]);
  }
  
  play(); //lancer la lecture quand l'app se lance
  
  try {
    String portName = "/dev/cu.usbserial-00002014"; //port name where the adafruit metro mini is connected
    myPort = new Serial(this, portName, 9600);
    myPort.clear(); // clear buffer
    myPort.bufferUntil('\n'); // don't generate a serialEvent() until you get a newline (\n) byte
  } 
  catch(Exception e) {
    //if no Adafruit metro mini connected
    println("Adafruit metro mini not connected");
  }
}

void newFile() {
  recorder = minim.createRecorder(in, recorded_testimony_directory+recorder_countname+".wav", true);
  recorder_countname++;
}

void draw(){
  background(0); 
  stroke(255);

  //gui((AudioPlayer[]) current audioplayer, (int) current track)
  if(select_audioplayer == 0){
    if ( testimony_player[current_track[0]].isPlaying() ) {
      gui(testimony_player, current_track[0]);
    } else {
      gui(testimony_player, current_track[0]);
    }
  } else {
    if ( recorded_testimony_player[current_track[1]].isPlaying() ) {
      gui(recorded_testimony_player, current_track[1]);
    } else {
      gui(recorded_testimony_player, current_track[1]);
    }
  }
  
  //println(testimony_player[current_track[0]].position()+"/"+testimony_player[current_track[0]].length());
  if(testimony_player[current_track[0]].position() > testimony_player[current_track[0]].length()-350){
    next_track();
  } else if(recorded_testimony_player[current_track[1]].position() == recorded_testimony_player[current_track[1]].length()){
    next_track();
  }
  
  if(previous == true){
    if(delay_previous_tracks < max_delay_previous_tracks){
      delay_previous_tracks++;
    } else {
      previous = false;
    }
  }
  
  if (recorder.isRecording()) {
    time++;
  }
  
  if(recorder.isRecording() && time > stop_recording){
    record_sound();
  }
}

void play() {
  if(select_audioplayer == 0){
    //PRE-RECORDED
    if ( testimony_player[current_track[0]].isPlaying() ) {
      testimony_player[current_track[0]].pause();
      play = false;
    } else if(testimony_player[current_track[0]].position() == testimony_player[current_track[0]].length()){
      testimony_player[current_track[0]].rewind();
      testimony_player[current_track[0]].play();
      play = true;
    } else {  
      testimony_player[current_track[0]].play();
      play = true;
    }
  } else {
    //RECORDED
    if ( recorded_testimony_player[current_track[1]].isPlaying() ) {
      recorded_testimony_player[current_track[1]].pause();
      play = false;
    } else if(recorded_testimony_player[current_track[1]].position() == recorded_testimony_player[current_track[1]].length()){
      recorded_testimony_player[current_track[1]].rewind();
      recorded_testimony_player[current_track[1]].play();
      play = true;
    }else{
      recorded_testimony_player[current_track[1]].play();
      play = true;
    }
  }
}

void next_track() {
  if(play == true){
    testimony_player[current_track[0]].pause();
    testimony_player[current_track[0]].rewind();
    recorded_testimony_player[current_track[1]].pause();
    recorded_testimony_player[current_track[1]].rewind();
  }
  
  select_audioplayer = int(random(0,2)); //choose btw 0 & 1

  if(select_audioplayer == 0){
    if (current_track[0]+1 == nb_testimony) {
      current_track[0] = 0;
    } else {
      current_track[0]++;
    }
  } else {
    if (current_track[1]+1 == current_nb_recorded_testimony) {
      current_track[1]=0;
    } else {
      current_track[1]++;
    }
  }
  
  if(play == true){
    //select_audioplayer = int(random(0,2));
    play();
  }
}

int max_delay_previous_tracks = 50;
int delay_previous_tracks = 50;
boolean previous = false;

void previous_track() {
  if(play == true && delay_previous_tracks == 50){
    testimony_player[current_track[0]].rewind();
    recorded_testimony_player[current_track[1]].rewind();
    delay_previous_tracks = 0;
    previous = true;
    return;  
  }
 
  if (delay_previous_tracks < max_delay_previous_tracks){
    testimony_player[current_track[0]].pause();
    recorded_testimony_player[current_track[1]].pause();
    testimony_player[current_track[0]].rewind();
    recorded_testimony_player[current_track[1]].rewind();
    
    select_audioplayer = int(random(0,2)); //choose btw 0 & 1
    if(select_audioplayer == 0){
      if (current_track[0] == 0) { // +1 ?
        current_track[0] = nb_testimony-1;
      } else {
        current_track[0]--;
      }
    } else {
      if (current_track[1] == 0) {
        current_track[1] = current_nb_recorded_testimony-1;
      } else {
        current_track[1]--;
      }
    }
  }
  
  if(play == true){
    play();
  }
}

int time = 0;
void record_sound() {
  if(play == true){
    play();
    testimony_player[current_track[0]].rewind();
    recorded_testimony_player[current_track[1]].rewind();
  }
  
  if (recorder.isRecording()) {
    recorder.endRecord();
    recorder.save();

    //TODO check countname && reload
    //recorded_testimony_player[countname] = minim.loadFile(recorded_testimony_directory+recorder_countname+".wav");

    println("Done saving.");
    
    newFile();
    
  } else {
    recorder.beginRecord();
    time = 0;
  }
}

void gui(AudioPlayer[] audioplayer, int gui_current_track){
  
  // draw audio spectrum
  if (!audioplayer[gui_current_track].isPlaying()) {
    for (int i = 0; i < in.bufferSize() - 1; i++) {
      line(i, 50 + in.left.get(i)*50, i+1, 50 + in.left.get(i+1)*50);
      line(i, 150 + in.right.get(i)*50, i+1, 150 + in.right.get(i+1)*50);
    }
  } else {
    for (int i = 0; i < audioplayer[gui_current_track].bufferSize() - 1; i++) {
      float x1 = map( i, 0, audioplayer[gui_current_track].bufferSize(), 0, width );
      float x2 = map( i+1, 0, audioplayer[gui_current_track].bufferSize(), 0, width );
      line( x1, 50 + audioplayer[gui_current_track].left.get(i)*50, x2, 50 + audioplayer[gui_current_track].left.get(i+1)*50 );
      line( x1, 150 + audioplayer[gui_current_track].right.get(i)*50, x2, 150 + audioplayer[gui_current_track].right.get(i+1)*50 );
    }
  }
  
  //Display audioplayer Controls
  textAlign(LEFT);
  if ( audioplayer[gui_current_track].isPlaying() ) {
    text("Press 'p' to pause playback.", 10, 180 );
  } else {
    text("Press 'p' to start playback.", 10, 180 );
  }
  
  // draw a line to show where in the song playback is currently located
  float posx = map(audioplayer[gui_current_track].position(), 0, audioplayer[gui_current_track].length(), 0, width);
  stroke(0, 200, 0);
  line(posx, 0, posx, height);
  
  //Display Recorder Output
  if (recorder.isRecording()) {
    text("Currently recording... Press 'r' to stop and save", 5, 15);
  } else {
    text("Press 'r' to record", 5, 15);
  }
  
  //Total Recorded Track
  int total_recorded_track = current_nb_recorded_testimony+nb_testimony;
  textAlign(RIGHT);
  text(current_track[0]+current_track[1]+1+"/"+total_recorded_track, 500, 180 );
}

void keyReleased() {
  if ( key == 'r' ) {
    record_sound();
  }
  if ( key == 'p' ) {
    play();
  }
  if (keyCode == RIGHT) {
    next_track();
  } else if (keyCode == LEFT) {
    previous_track();
  }
}

void serialEvent (Serial myPort) {
  String inString = myPort.readStringUntil('\n');  // get the ASCII string
  if (inString != null) {  // if it's not empty
    inString = trim(inString);  // trim off any whitespace
    try {
      String val = inString;
      switch(val) {
      case "p": //Play sound
        play();
        break; 
      case "r": //Record sound
        record_sound();
        break;
      case "n": //Next Track
        next_track();
        break;
      case "q": //Previous Track
        previous_track();
        break;
      default :
        println("No command found");
        break;
      }
    } 
    catch(Exception e) {
      //e.printStackTrace();
    }
  }
}

void stop() {
  // always close Minim audio classes when you are done with them
  in.close();
  minim.stop();
  super.stop();
}