/* Témoignage, 2017
 *
 */

import processing.serial.*;
import ddf.minim.*;

Serial myPort;

Minim minim;
AudioInput in;
AudioRecorder recorder;

public static final int NUM_WAVS = 8;
AudioPlayer[] player = new AudioPlayer[NUM_WAVS];

int[] previous_track = new int[10];

int countname;
int name = 000000;

//int file_name = 0;
int current_player = 0;

String val;

void setup() {
  size(512, 200, P2D);

  minim = new Minim(this);
  in = minim.getLineIn(Minim.STEREO, 2048);
  
  newFile(); //Change file name

  for (int i = 0; i < NUM_WAVS; i++) {
    player[i] = minim.loadFile("file/0"+i+".wav");
  }

  textFont(createFont("SanSerif", 12));

  try {
    String portName = "/dev/cu.usbserial-00002014"; //port name where the adafruit metro mini is connected
    myPort = new Serial(this, portName, 9600);
    myPort.clear(); // clear buffer
    myPort.bufferUntil('\n'); // don't generate a serialEvent() until you get a newline (\n) byte
  } 
  catch(Exception e) {
    //if no Adafruit metro mini connected
    println("No Adafruit metro mini connected");
  }
}

void draw() {
  background(0); 
  stroke(255);

  /*************************************/

  gui(player, current_player);

  /*************************************/
  
  //à voir en fonciton du nombre total pistes
  text(current_player+1+"/"+NUM_WAVS, 480, 180 );

  if (player[current_player].position() == player[current_player].length()) {
    previous_track();
    player[current_player].rewind();
    player[current_player].play();
  }
}

void gui(AudioPlayer[] audioplayer, int current_track){
  if (!audioplayer[current_track].isPlaying()) {
    for (int i = 0; i < in.bufferSize() - 1; i++) {
      line(i, 50 + in.left.get(i)*50, i+1, 50 + in.left.get(i+1)*50);
      line(i, 150 + in.right.get(i)*50, i+1, 150 + in.right.get(i+1)*50);
    }
  } else {
    for (int i = 0; i < audioplayer[current_track].bufferSize() - 1; i++) {
      float x1 = map( i, 0, audioplayer[current_track].bufferSize(), 0, width );
      float x2 = map( i+1, 0, audioplayer[current_track].bufferSize(), 0, width );
      line( x1, 50 + audioplayer[current_track].left.get(i)*50, x2, 50 + audioplayer[current_track].left.get(i+1)*50 );
      line( x1, 150 + audioplayer[current_track].right.get(i)*50, x2, 150 + audioplayer[current_track].right.get(i+1)*50 );
    }
  }
  
  //Display audioplayer Controls
  if ( audioplayer[current_track].isPlaying() ) {
    text("Press 'p' to pause playback.", 10, 180 );
  } else {
    text("Press 'p' to start playback.", 10, 180 );
  }
  
  // draw a line to show where in the song playback is currently located
  float posx = map(audioplayer[current_track].position(), 0, audioplayer[current_track].length(), 0, width);
  stroke(0, 200, 0);
  line(posx, 0, posx, height);
  
  //Display Recorder Output
  if (recorder.isRecording()) {
    text("Currently recording... Press 'r' to stop and save", 5, 15);
  } else {
    text("Press 'r' to record", 5, 15);
  }
}

void keyReleased() {
  if ( key == 'r' ) {
    record_sound();
  }

  if ( key == 'p' ) {
    play();
  }

  if (keyCode == LEFT) {
    next_track();
  } else if (keyCode == RIGHT) {
    previous_track();
  }
}

void newFile() {
  countname = name+1;
  //countname = int(random(0,NUM_WAVS));
  recorder = minim.createRecorder(in, "file/0" + countname + ".wav", true);
}

void serialEvent (Serial myPort) {
  String inString = myPort.readStringUntil('\n');  // get the ASCII string
  if (inString != null) {  // if it's not empty
    inString = trim(inString);  // trim off any whitespace
    try {
      val = inString;
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

void play() {

  /*
  if(current_audioplayer == 0){ // 0 = testimony // 1 = recorded testimony
   
   } else {
   
   }
   
   select_audioplayer = int(random(0,1));
   
   if(select_audioplayer == 0){ // 0 = testimony // 1 = recorded testimony
   
   } else {
   
   }
   
   */

  if ( player[current_player].isPlaying() ) {
    player[current_player].pause();
    //player[current_player].rewind();
    //player[current_player].play();
  } else if (player[current_player].position() == player[current_player].length()) {
    player[current_player].rewind();
    player[current_player].play();
  } else {
    //player_controller();
    player[current_player].play();
  }
}

void next_track() {
  if (current_player == 0) {
    current_player = NUM_WAVS-1;
  } else {
    current_player--;
  }
}

void previous_track() {
  if (current_player+1 == NUM_WAVS) {
    current_player=0;
  } else {
    current_player++;
  }
}

void record_sound() {
  if (recorder.isRecording()) {
    recorder.endRecord();
    recorder.save();

    //TODO reload 
    player[countname] = minim.loadFile("file/0"+countname+".wav");

    name++; //change the file name, everytime +1
    println("Done saving.");
    println(name);//check the name
  } else {
    newFile();
    recorder.beginRecord();
  }
}

void stop() {
  // always close Minim audio classes when you are done with them
  in.close();
  minim.stop();
  super.stop();
}