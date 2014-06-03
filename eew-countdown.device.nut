// WS2812 "Neopixel" LED Driver
// Copyright (C) 2014 Electric Imp, inc.
//
// Uses SPI to emulate 1-wire
// http://learn.adafruit.com/adafruit-neopixel-uberguide/advanced-coding


// This class requires the use of SPI257, which must be run at 7.5MHz
// to support neopixel timing.
// If you have errant flashing pixels, try running at 3750 kHz instead.
const SPICLK = 7500; // kHz
// const SPICLK = 3750; // kHz

// const PALETTE = 0; // Colors matching Shakemap 
const PALETTE = 1; // Morgan's color palette with more resolution at lower intensities

// This is used for timing testing only
us <- hardware.micros.bindenv(hardware);

wakehandle <- 0; // keep track of the next imp.wakeup handle, so we can cancel if changing effects

class NeoPixels {

    // This class uses SPI to emulate the newpixels' one-wire protocol.
    // This requires one byte per bit to send data at 7.5 MHz via SPI.
    // These consts define the "waveform" to represent a zero or one
    ZERO = 0xC0;
    ONE = 0xF8;
    BYTESPERPIXEL = 24;

    // when instantiated, the neopixel class will fill this array with blobs to
    // represent the waveforms to send the numbers 0 to 255. This allows the blobs to be
    // copied in directly, instead of being built for each pixel - which makes the class faster.
    bits = null;
    // Like bits, this blob holds the waveform to send the color [0,0,0], to clear pixels faster
    clearblob = blob(12);

    // private variables passed into the constructor
    spi = null; // imp SPI interface (pre-configured)
    frameSize = null; // number of pixels per frame
    frame = null; // a blob to hold the current frame

    // _spi - A configured spi (MSB_FIRST, 7.5MHz)
    // _frameSize - Number of Pixels per frame
    constructor(_spi, _frameSize) {
        this.spi = _spi;
        this.frameSize = _frameSize;
        this.frame = blob(frameSize*BYTESPERPIXEL + 1);
        this.frame[frameSize*BYTESPERPIXEL] = 0;

        // prepare the bits array and the clearblob blob
        initialize();

        clearFrame();
        writeFrame();
    }

    // fill the array of representative 1-wire waveforms.
    // done by the constructor at instantiation.
    function initialize() {
        // fill the bits array first
        bits = array(256);
        for (local i = 0; i < 256; i++) {
            local valblob = blob(BYTESPERPIXEL / 3);
            valblob.writen((i & 0x80) ? ONE:ZERO,'b');
            valblob.writen((i & 0x40) ? ONE:ZERO,'b');
            valblob.writen((i & 0x20) ? ONE:ZERO,'b');
            valblob.writen((i & 0x10) ? ONE:ZERO,'b');
            valblob.writen((i & 0x08) ? ONE:ZERO,'b');
            valblob.writen((i & 0x04) ? ONE:ZERO,'b');
            valblob.writen((i & 0x02) ? ONE:ZERO,'b');
            valblob.writen((i & 0x01) ? ONE:ZERO,'b');
            bits[i] = valblob;
        }

        // now fill the clearblob
        for(local j = 0; j < BYTESPERPIXEL; j++) {
            clearblob.writen(ZERO, 'b');
        }

    }

    // sets a pixel in the frame buffer
    // but does not write it to the pixel strip
    // color is an array of the form [r, g, b]
    function writePixel(p, color) {
        frame.seek(p*BYTESPERPIXEL);
        // red and green are swapped for some reason, so swizzle them back
        frame.writeblob(bits[color[1]]);
        frame.writeblob(bits[color[0]]);
        frame.writeblob(bits[color[2]]);
    }

    // Clears the frame buffer
    // but does not write it to the pixel strip
    function clearFrame() {
        frame.seek(0);
        for (local p = 0; p < frameSize; p++) frame.writeblob(clearblob);
    }

    // writes the frame buffer to the pixel strip
    // ie - this function changes the pixel strip
    function writeFrame() {
        spi.write(frame);
    }
}


// Copyright (c) 2013 Electric Imp
// This file is licensed under the MIT License
// http://opensource.org/licenses/MIT


// -------------------------------------------------------------------------
// Notes for Piezo Buzzer
const NOTE_REST = 0
const NOTE_B0 = 31
const NOTE_C1 = 33
const NOTE_CS1 = 35
const NOTE_D1 = 37
const NOTE_DS1 = 39
const NOTE_E1 = 41
const NOTE_F1 = 44
const NOTE_FS1 = 46
const NOTE_G1 = 49
const NOTE_GS1 = 52
const NOTE_A1 = 55
const NOTE_AS1 = 58
const NOTE_B1 = 62
const NOTE_C2 = 65
const NOTE_CS2 = 69
const NOTE_D2 = 73
const NOTE_DS2 = 78
const NOTE_E2 = 82
const NOTE_F2 = 87
const NOTE_FS2 = 93
const NOTE_G2 = 98
const NOTE_GS2 = 104
const NOTE_A2 = 110
const NOTE_AS2 = 117
const NOTE_B2 = 123
const NOTE_C3 = 131
const NOTE_CS3 = 139
const NOTE_D3 = 147
const NOTE_DS3 = 156
const NOTE_E3 = 165
const NOTE_F3 = 175
const NOTE_FS3 = 185
const NOTE_G3 = 196
const NOTE_GS3 = 208
const NOTE_A3 = 220
const NOTE_AS3 = 233
const NOTE_B3 = 247
const NOTE_C4 = 262
const NOTE_CS4 = 277
const NOTE_D4 = 294
const NOTE_DS4 = 311
const NOTE_E4 = 330
const NOTE_F4 = 349
const NOTE_FS4 = 370
const NOTE_G4 = 392
const NOTE_GS4 = 415
const NOTE_A4 = 440
const NOTE_AS4 = 466
const NOTE_B4 = 494
const NOTE_C5 = 523
const NOTE_CS5 = 554
const NOTE_D5 = 587
const NOTE_DS5 = 622
const NOTE_E5 = 659
const NOTE_F5 = 698
const NOTE_FS5 = 740
const NOTE_G5 = 784
const NOTE_GS5 = 831
const NOTE_A5 = 880
const NOTE_AS5 = 932
const NOTE_B5 = 988
const NOTE_C6 = 1047
const NOTE_CS6 = 1109
const NOTE_D6 = 1175
const NOTE_DS6 = 1245
const NOTE_E6 = 1319
const NOTE_F6 = 1397
const NOTE_FS6 = 1480
const NOTE_G6 = 1568
const NOTE_GS6 = 1661
const NOTE_A6 = 1760
const NOTE_AS6 = 1865
const NOTE_B6 = 1976
const NOTE_C7 = 2093
const NOTE_CS7 = 2217
const NOTE_D7 = 2349
const NOTE_DS7 = 2489
const NOTE_E7 = 2637
const NOTE_F7 = 2794
const NOTE_FS7 = 2960
const NOTE_G7 = 3136
const NOTE_GS7 = 3322
const NOTE_A7 = 3520
const NOTE_AS7 = 3729
const NOTE_B7 = 3951
const NOTE_C8 = 4186
const NOTE_CS8 = 4435
const NOTE_D8 = 4699
const NOTE_DS8 = 4978

// -------------------------------------------------------------------------
// This timer class may be out of date. For the latest version see the electricimp/examples github repository.
// 
class timer {

    cancelled = false;
    paused = false;
    running = false;
    callback = null;
    interval = 0;
    params = null;
    send_self = false;
    static timers = [];

    // -------------------------------------------------------------------------
    constructor(_params = null, _send_self = false) {
        params = _params;
        send_self = _send_self;
        timers.push(this); // Prevents scoping death
    }

    // -------------------------------------------------------------------------
    function _cleanup() {
        foreach (k,v in timers) {
            if (v == this) return timers.remove(k);
        }
    }
    
    // -------------------------------------------------------------------------
    function update(_params) {
        params = _params;
        return this;
    }

    // -------------------------------------------------------------------------
    function set(_duration, _callback) {
        assert(running == false);
        callback = _callback;
        running = true;
        imp.wakeup(_duration, alarm.bindenv(this))
        return this;
    }

    // -------------------------------------------------------------------------
    function repeat(_interval, _callback) {
        assert(running == false);
        interval = _interval;
        return set(_interval, _callback);
    }

    // -------------------------------------------------------------------------
    function cancel() {
        cancelled = true;
        return this;
    }

    // -------------------------------------------------------------------------
    function pause() {
        paused = true;
        return this;
    }

    // -------------------------------------------------------------------------
    function unpause() {
        paused = false;
        return this;
    }

    // -------------------------------------------------------------------------
    function alarm() {
        if (interval > 0 && !cancelled) {
            imp.wakeup(interval, alarm.bindenv(this))
        } else {
            running = false;
            _cleanup();
        }

        if (callback && !cancelled && !paused) {
            if (!send_self && params == null) {
                callback();
            } else if (send_self && params == null) {
                callback(this);
            } else if (!send_self && params != null) {
                callback(params);
            } else  if (send_self && params != null) {
                callback(this, params);
            }
        }
    }
}


// -------------------------------------------------------------------------
class Tone {
    pin = null;
    playing = null;
    wakeup = null;

    constructor(_pin) {
        this.pin = _pin;
        this.playing = false;
    }
    
    function isPlaying() {
        return playing;
    }
    
    function play(freq, duration = null) {
        if (playing) stop();
        
        freq *= 1.0;
        pin.configure(PWM_OUT, 1.0/freq, 1.0);
        pin.write(0.5);
        playing = true;
        
        if (duration != null) {
            wakeup = timer().set(duration, stop.bindenv(this));
        }
    }
    
    function stop() {
        if (wakeup != null){
            wakeup.cancel();
            wakeup = null;
        } 
        
        pin.write(0.0);
        playing = false;
    }
}


// -------------------------------------------------------------------------
class Song {
    tone = null;
    song = null;
    
    currentNote = null;
    
    wakeup = null;
    
    constructor(_tone, _song) {
        this.tone = _tone;
        this.song = _song;

        this.currentNote = 0;
    }
    
    // Plays the song frmo the start
    function Restart() {
        Stop();
        Play();
    }
    
    // Plays song from current position
    function Play() {
        if (currentNote < song.len()) {
            tone.play(song[currentNote].note, 1.0/song[currentNote].duration);
            wakeup = timer().set(1.0/song[currentNote].duration + 0.01, Play.bindenv(this));
            currentNote++;
        }
    }
    
    // Stops playing, and saves position
    function Pause() {
        tone.stop();
        if (wakeup != null) {
            wakeup.cancel();
            wakeup = null;
        }
    }
    
    // Stops playing and resets position
    function Stop() {
        Pause();
        currentNote = 0;
    }
}



/* RUNTIME STARTS HERE -------------------------------------------------------*/

const NUMPIXELS = 24;
const DELAY = 1.000;
const TIMER = 20;

spi <- hardware.spi257;
spi.configure(MSB_FIRST, SPICLK);
pixelStrip <- NeoPixels(spi, NUMPIXELS);

pixels <- [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]
currentPixel <- 0;
pAdd <- 1;
seconds <- 10;

seconds = seconds - 1;

function colorForMMI(MMI, PALETTE) {
// Returns RGB color for a given MMI intensity
// Supports ShakeMap color pallete (PALETTE=0) or Morgan's colors (PALETTE=1)
    local brightness=1;
    
    local color = null; local  color0 = null; local  color1 = null;
      switch (MMI % 10) {
        case 1:
            color0 = [0 0 brightness*255]; color1 = [0 0 brightness*255]; 
            break;
        case 2:
            color0 = [0 0 brightness*255]; color1 = [0 brightness*255 0]; 
            break;
        case 3:
            color0 = [0 0 brightness*255]; color1 = [brightness*75 brightness*255 0]; 
            break;
        case 4:
            color0 = [brightness*75 brightness*75 brightness*255]; color1 = [brightness*200 brightness*255 0]; 
            break;
        case 5:
            color0 = [0 brightness*255 0]; color1 = [brightness*255 brightness*255 0]; 
            break;
        case 6:
            color0 = [brightness*255 brightness*255 0]; color1 = [brightness*255 brightness*64 0]; 
            break;
        case 7:
            color0 = [brightness*255 brightness*127 brightness*80]; color1 = [brightness*255 brightness*32 0]; 
            break; 
        case 8:
            color0 = [brightness*200 brightness*120 0]; color1 = [brightness*255 0 0]; 
            break;
        case 9:
            color0 = [brightness*255 0 0]; color1 = [brightness*255 0 0]; 
            break;
        default:
            color0 = [brightness*255 0 0]; color1 = [brightness*255 0 0]; 
            break;
      }
    
    if (PALETTE == 1) {
        color = color1;
    } else {
        color = color0;
    }
    return color;
}

function initialFlash(MMI) {
// Initial LED flash & music when new EEW message is received

    local brightness = 1;
    local color = colorForMMI(MMI, PALETTE);
    
    // Piezo Buzzer Sounds
    if (MMI<=5) {
        Piezo <- Tone(hardware.pin9);
        music <- Song(Piezo, Coin);
        music.Play();
    }
    if (MMI>5) {
        Piezo <- Tone(hardware.pin9);
        music <- Song(Piezo, GameOver);
        music.Play();
    }
    
    // LED flash
    for (local i=0; i<3; i++) {
        for(local pixel = 0; pixel < NUMPIXELS; pixel++) {
            if (i==0) {
                pixelStrip.writePixel(pixel,[brightness*255 brightness*255 brightness*255]);
            }  else {
                pixelStrip.writePixel(pixel,color);
            }
        }
        pixelStrip.writeFrame();
        imp.sleep(0.1);
        for(local pixel = 0; pixel < NUMPIXELS; pixel++) {
            pixelStrip.writePixel(pixel,[0 0 0]);
        }
        pixelStrip.writeFrame();
        imp.sleep(0.1);
    }
}


function countdown(countdownDelay,MMI,type) {
    // Display countdown to S-wave arrival
    
    local brightness=1;
    server.log("countdown called with numLitPixels = "+numLitPixels);

    if (numLitPixels<24) {
        local green = 0;
        if (type>0) green=5;
        pixelStrip.writePixel(numLitPixels,[0 green 0]);
    }

    for(local pixel = 0; pixel < numLitPixels; pixel++) {
        local color = colorForMMI(MMI, PALETTE);
        pixelStrip.writePixel(pixel,color);
    }

    pixelStrip.writeFrame();
    numLitPixels = numLitPixels-1;
    wakehandle = imp.wakeup(countdownDelay, function() {countdown(countdownDelay,MMI,type)});

    if (numLitPixels == -1) {  // End of countdown
        imp.cancelwakeup(wakehandle);

        // Begin post-earthquake animation
        server.log("Starting Post-Earthquake Animation");
        animationIndex <- 0;
        local flag = 0;
        postEarthquakeAnimation(MMI, flag);
    }

}

// *** EEW message received from agent *** -------------------------------------------------------*/
agent.on("count", function(data) {

    local seconds = data[0];
    local MMI = data[1];
    local type = data[2];
    local countdownDelay = null;

    if (wakehandle) { imp.cancelwakeup(wakehandle); }
    if (type==-1) { // cancel event
        imp.cancelwakeup(wakehandle);
        pixels <- [0,1,2,3,4,5];
        currentPixel <- 5;
        animationIndex <- 0;
        server.log("Starting rainbow animation")
        rainbowSwirl();
    }
    else { 
        if (numLitPixels == NUMPIXELS) {
            initialFlash(MMI); // Only call initial flash if not interrupting countdown()
            countdownDelay = (seconds-0.6)/NUMPIXELS.tofloat();
        } else {
            countdownDelay = seconds/NUMPIXELS.tofloat();
        }
        numLitPixels <- NUMPIXELS;
        countdown(countdownDelay,MMI,type); 
    }

});

function defaultAnimation() {
// Default animation between EEW messages
    numLitPixels <- NUMPIXELS;

    // schedule refresh
    local animationRefreshPeriod = 1;
    wakehandle = imp.wakeup((animationRefreshPeriod), function() {defaultAnimation()}.bindenv(this));


    for (local i=0; i<NUMPIXELS; i++) {
        local randColors = [math.rand()%10 math.rand()%10 math.rand()%10]
        while (randColors[0]<2 && randColors[1]<2 && randColors[2]<2) { // Avoid pixels that are too dim
            randColors = [math.rand()%10 math.rand()%10 math.rand()%10]
        }
        pixelStrip.writePixel(i,randColors);
    }
    pixelStrip.writeFrame();

}

function postEarthquakeAnimation(MMI, flag) {
// Animation to display after S wave arrival

   animationIndex = animationIndex+1;
   local duration = MMI * 30;

   for(local pixel = 0; pixel < NUMPIXELS; pixel++) {
       pixelStrip.writePixel(pixel,[0 0 0]);
   }
   pixelStrip.writeFrame();
   local factor = (1.0 - (animationIndex/(duration*1.25)));
   local amp = math.rand()%(MMI+3)*factor;
   for (local j=0; j<amp; j++) {
       local br = 25*factor;
       if (flag == 0) pixelStrip.writePixel(j,[br,0,0]);
       local k = 23 - j;
       if (flag == 1) pixelStrip.writePixel(k,[br,0,0]);
   }
   pixelStrip.writeFrame();
   if (flag ==0) {
       flag = 1;
   } else {
       flag = 0;
   }

   if (animationIndex<duration) {
       wakehandle = imp.wakeup(0.03, function() {postEarthquakeAnimation(MMI, flag)});
   } else {
       // End of post-earthquake animation, go back to default animation
       server.log("Starting Default Animation");
       defaultAnimation();
   }
}

function rainbowSwirl() { 
// All-clear rainbow animation for event cancellations
    animationIndex = animationIndex+1;
    local numberLoops = 3*NUMPIXELS;
    local pAdd=1;
    
    for(local pixel = 0; pixel < NUMPIXELS; pixel++) {
        pixelStrip.writePixel(pixel,[0 0 0]);
    }
    pixelStrip.writeFrame();
  
    local brightness=0.05;
    pixelStrip.writePixel(pixels[0], [brightness*255, 0, 0])
    pixelStrip.writePixel(pixels[1], [brightness*255, brightness*128, 0])
    pixelStrip.writePixel(pixels[2], [brightness*255, brightness*255, 0])
    pixelStrip.writePixel(pixels[3], [0, brightness*255, brightness*128])
    pixelStrip.writePixel(pixels[4], [0, 0, brightness*255])
    pixelStrip.writePixel(pixels[5], [brightness*128, 0, brightness*255])
  
  
    pixelStrip.writeFrame();
    //if (currentPixel >= NUMPIXELS-1) pAdd = -1;  // To reverse direction
    if (currentPixel >= NUMPIXELS-1) currentPixel = currentPixel-NUMPIXELS; // To keep going clockwise
    if (currentPixel <= 0) pAdd = 1;
    currentPixel += pAdd;
  
    for (local i = 0; i < 5; i++)  pixels[i] = pixels[i+1];
    pixels[5] = currentPixel;
  
    if (animationIndex<numberLoops) {
        wakehandle = imp.wakeup(0.1, function() {rainbowSwirl()});
    } else {
        // End of rainbow animation, return to default animation
        server.log("Starting Default Animation");
        defaultAnimation();
    }
} 

// Piezo Buzzer Songs
// 1 = full note, 2 = half note, 4 = quarter note, ...
// NOTE: a brief rest has been added to the start of each song - otherwise buzzer "hangs" on first note
// TODO: Figure out how to prevent delay before start of piezo buzzer song
Coin <- [{note = NOTE_REST, duration = 64},{note = NOTE_B5, duration = 16},{note = NOTE_E6, duration = 2}];
OneUp <- [{note = NOTE_REST, duration = 64},{note = NOTE_REST,note = NOTE_E5, duration = 8},{note = NOTE_G5, duration = 8},{note = NOTE_E6, duration = 8},{note = NOTE_C6, duration = 8},{note = NOTE_D6, duration = 8},{note = NOTE_G7, duration = 8}];
GameOver <- [{note = NOTE_REST, duration = 64},{note = NOTE_C5, duration = 8},{note = NOTE_REST, duration = 4},{note = NOTE_G4, duration = 8},{note = NOTE_REST, duration = 4},{note = NOTE_E4, duration = 2},{note = NOTE_A4, duration = 3},{note = NOTE_B4, duration = 3},{note = NOTE_A4, duration = 3},{note = NOTE_GS4, duration = 2},{note = NOTE_AS4, duration = 2},{note = NOTE_GS4, duration = 2},{note = NOTE_G4, duration = 0.75}];

// Imp start-up: Play "one-up" noise and begin default animation
Piezo <- Tone(hardware.pin9);
music <- Song(Piezo, OneUp);
music.Play();
defaultAnimation();

