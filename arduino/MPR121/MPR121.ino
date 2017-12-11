/* Témoignage, 2017
 *
 */

#include <Wire.h>
#include "Adafruit_MPR121.h"

// You can have up to 4 on one i2c bus but one is enough for testing!
Adafruit_MPR121 cap = Adafruit_MPR121();

// Keeps track of the last pins touched
// so we know when buttons are 'released'
uint16_t lasttouched = 0;
uint16_t currtouched = 0;

void setup() {
  Serial.begin(9600);

  while (!Serial) { // needed to keep leonardo/micro from starting too fast!
    delay(10);
  }
  
  Serial.println("Adafruit MPR121 Capacitive Touch sensor test"); 
  
  // Default address is 0x5A, if tied to 3.3V its 0x5B
  // If tied to SDA its 0x5C and if SCL then 0x5D
  if (!cap.begin(0x5A)) {
    Serial.println("MPR121 not found, check wiring?");
    while (1);
  }
  Serial.println("MPR121 found!");
}

void loop() {
  // Get the currently touched pads
  currtouched = cap.touched();
  
  for (uint8_t i=0; i<12; i++) {

    /***** TOUCHED *****/
    // it if *is* touched and *wasnt* touched before, alert!
    if ((currtouched & _BV(i)) && !(lasttouched & _BV(i)) ) {
      //Serial.print(i); Serial.println(" touched");
      if(i == 0){Serial.println("p");} //play
      else if(i == 1){Serial.println("r");} //record
      else if(i == 2){Serial.println("n");} //next track
      else if(i == 3){Serial.println("q");} //previous track
      else if(i == 4){Serial.println("o");} //undefine
      else if(i == 5){Serial.println("u");} //undefine
      else if(i == 6){Serial.println("s");} //undefine
    }
    
    /***** RELEASED *****/
    // if it *was* touched and now *isnt*, alert!
    // if (!(currtouched & _BV(i)) && (lasttouched & _BV(i)) ) {
    //   Serial.print(i); Serial.println(" released");
    // }
  }

  // reset our state
  lasttouched = currtouched;
}
