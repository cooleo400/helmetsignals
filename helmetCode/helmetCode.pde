#include "LPD8806.h"
#include "SPI.h"

// Example to control LPD8806-based RGB LED Modules in a strip

/*****************************************************************************/
#define BRAKETHRESHOLD        350
#define BRAKETIMETHRESHOLD    200
// Choose which 2 pins you will use for output.
// Can be any valid output pins.
int dataPin = 1;   
int clockPin = 5;

int readPin1 = 6;   
int readPin2 = 7;
int readPin3 = 8;

const int cPin = 11;
const int dPin = 6;

// Set the first variable to the NUMBER of pixels. 32 = 32 pixels in a row
// The LED strips are 32 LEDs per meter but you can extend/cut the strip
LPD8806 strip = LPD8806(64, dataPin, clockPin);

// you can also use hardware SPI, for ultra fast writes by leaving out the
// data and clock pin arguments. This will 'fix' the pins to the following:
// on Arduino 168/328 thats data = 11, and clock = pin 13
// on Megas thats data = 51, and clock = 52 
//LPD8806 strip = LPD8806(32);
int start = 0;

int prevX = 0;
int currentX = 0;

int cState = 0;
int dState = 0;

int cState1 = 0;
int cState2 = 0;
int cState3 = 0;

long brakeTime = 0;

uint32_t none = strip.Color(0,0,0);
uint32_t red = strip.Color(255,0,0);
uint32_t amber = strip.Color(255,191,0);
uint32_t green = strip.Color(0,255,0);

void setup() {
  
  Serial.begin(9600);
  // Start up the LED strip
  strip.begin();

  // Update the strip, to start they are all 'off'
  strip.show();
  
  pinMode(cPin, INPUT); 
  pinMode(dPin, INPUT);
  
   pinMode(readPin1, INPUT); 
   pinMode(readPin2, INPUT);
   pinMode(readPin3, INPUT); 
}


void loop() {

cState1 = digitalRead(readPin1);
cState2 = digitalRead(readPin2);
cState3 = digitalRead(readPin3);

  if(cState3 == HIGH){
    Serial.println("cstate 3 high");
    brakeLights(red,100);
  } else if (cState1 == HIGH){
    Serial.println("cstate 1 high");
    chaseBlinkerLeft(amber, 100);
  } else if(cState2 == HIGH) {
    Serial.println("cstate 2 high");
	chaseBlinkerRight(amber, 100);
  } else {
    //Serial.println("All low");
    hideAll();
  }
}

// fill the dots one after the other with said color
// good for testing purposes
//void colorWipe(uint32_t c, uint8_t wait) {
//  int i;
//  
//  for (i=0; i < strip.numPixels(); i++) {
//      strip.setPixelColor(i, c);
//      strip.show();
//      delay(wait);
//  }
//}

// Chase a dot down the strip
//// good for testing purposes
void colorChase(uint32_t c, uint8_t wait) {
  int i;
  
  for (i=0; i < strip.numPixels(); i++) {
    strip.setPixelColor(i, 0);  // turn all pixels off
  } 
  
  for (i=0; i < strip.numPixels(); i++) {
      strip.setPixelColor(i, c);
      if (i == 0) { 
        strip.setPixelColor(strip.numPixels()-1, 0);
      } else {
        strip.setPixelColor(i-1, 0);
      }
      strip.show();
      delay(wait);
  }
}

void triColorChase(uint32_t c1,uint32_t c2, uint32_t c3, uint8_t pxStart, uint8_t pxEnd, uint8_t wait){
  int i;
  
  for (i=pxStart; i < pxEnd; i++) {
    strip.setPixelColor(i, 0);  // turn all pixels off
  } 
  
  for (i=pxStart; i < pxEnd; i++) {
      
      if (i == pxStart) { 
        strip.setPixelColor(i, c1);
        strip.setPixelColor(pxEnd-1,c2);
        strip.setPixelColor(pxEnd-2,c3);
        strip.setPixelColor(pxEnd-3,0);
      } else if(i == pxStart+1) {
        strip.setPixelColor(i, c1);
        strip.setPixelColor(i-1, c2);
        strip.setPixelColor(pxEnd-1,c3);
        strip.setPixelColor(pxEnd-2,0);
      } else if(i == pxStart+2){
        strip.setPixelColor(i, c1);
        strip.setPixelColor(i-1, c2);
        strip.setPixelColor(i-2, c3);
        strip.setPixelColor(pxEnd-1,0);
      } else {
        strip.setPixelColor(i, c1);
        strip.setPixelColor(i-1, c2);
        strip.setPixelColor(i-2, c3);
        strip.setPixelColor(i-3, 0);
      }
      
      strip.show();
      delay(wait);
  }
}

/* Helper functions */
//Input a value 0 to 384 to get a color value.
//The colours are a transition r - g -b - back to r

void chaseBlinkerLeft(uint32_t c, uint32_t wait){
	int i;
	int j = 7;

	for (i=0; i < 8; i++) {
		strip.setPixelColor(i, 0);  // turn all pixels off
	} 
	
	for (i=0; i < 4; i++) {
		
	  strip.setPixelColor(i, c);
	  strip.setPixelColor(j, c);
	  if (i == 0) { 
		strip.setPixelColor(3, 0); //bottom left
		strip.setPixelColor(4, 0); //top left
	  } else {
		strip.setPixelColor(i-1, 0);
		strip.setPixelColor(j+1, 0);
	  }
	  strip.show();
	  delay(wait);
	  
	  j--;
	}
}

void chaseBlinkerRight(uint32_t c, uint32_t wait){
	int i;
	int j = 23;

	for (i=16; i < 23; i++) {
		strip.setPixelColor(i, 0);  // turn all pixels off
	} 
	
	for (i=16; i < 20; i++) {
		
	  strip.setPixelColor(i, c);
	  strip.setPixelColor(j, c);
	  if (i == 16) { 
		strip.setPixelColor(19, 0); //top right
		strip.setPixelColor(20, 0); //bottom right
	  } else {
		strip.setPixelColor(i-1, 0);
		strip.setPixelColor(j+1, 0);
	  }
	  strip.show();
	  delay(wait);
	  
	  j--;
	}
}

void leftTurn(uint32_t c,uint8_t wait){
   leftBlinkBottom(c);
   leftBlinkTop(c);
     strip.show(); 
	delay(wait);
}

void rightTurn(uint32_t c,uint8_t wait){
  rightBlinkBottom(c);
  rightBlinkTop(c);
   strip.show(); 
   delay(wait);
}

void brakeLights(uint32_t c,uint8_t wait){
  stopLightLeft(c);
  stopLightRight(c);
    strip.show();
	delay(wait);
}

void leftBlinkBottom(uint32_t c){
  for (int i=0; i < 4; i++) {
    strip.setPixelColor(i, c);
  }
}
void leftBlinkTop(uint32_t c){
  for (int i=4; i < 8; i++) {
    strip.setPixelColor(i, c);
  }
}

void stopLightLeft(uint32_t c){
   for (int i=8; i < 12; i++) {
    strip.setPixelColor(i, c);
  }
  strip.setPixelColor(1, c);
  strip.setPixelColor(2, c);
  strip.setPixelColor(5, c);
  strip.setPixelColor(6, c);
}
void stopLightRight(uint32_t c){
   for (int i=12; i < 16; i++) {
    strip.setPixelColor(i, c);
  }
  strip.setPixelColor(17, c);
  strip.setPixelColor(18, c);
  strip.setPixelColor(21, c);
  strip.setPixelColor(22, c);
}

void rightBlinkTop(uint32_t c){
  for (int i=16; i < 20; i++) {
    strip.setPixelColor(i, c);
  }
}
void rightBlinkBottom(uint32_t c){
  for (int i=20; i < 24; i++) {
    strip.setPixelColor(i, c);
  }
}

void hideAll(){
 for (int i=0; i < strip.numPixels(); i++) {
    strip.setPixelColor(i, 0);
 }
	strip.show();
}

// Create a 24 bit color value from R,G,B
uint32_t Color(byte r, byte g, byte b)
{
  uint32_t c;
  c = r;
  c <<= 8;
  c |= g;
  c <<= 8;
  c |= b;
  return c;
}
