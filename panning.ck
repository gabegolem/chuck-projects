<<< "Panning and Randomization" >>>;

TriOsc osc1  => ADSR env1 => NRev rev => Pan2 pan => dac;
env1 => Delay delay[2];

.15 => rev.mix;

0.5::second => dur beat;
(1::ms, beat/8, 0, 1::ms) => env1.set;
0.3 => osc1.gain;

1.0 => pan.pan;
.05 => pan.gain;


[0,4,7] @=> int major[];
[0,3,7] @=> int minor[];
[0,3,6] @=> int diminished[];


[major, major, minor, minor, diminished] @=> int chords[][];

48 => int offset;
int position;

float panValue;
int chord[];

fun void arpeggiate( int chord[], int position) {
    
    for (0 => int i; i < chord.cap(); i++) 
    {
        for (-1.0 => float j; j <= 1.0; 0.1 +=> j)
        {
            Std.mtof(chord[i] + offset + position) => osc1.freq;
            1 => env1.keyOn;
            beat / 4 => now;
        }
    }
}

fun void randomArpeggiate() {
    
    chords[Math.random2(0, chords.cap() - 1)] @=> chord;
    
    for (0 => int i; i < chord.cap(); i++) 
    {    
        Math.random2f(-.75, .75) => panValue => pan.pan;
        for (-1.0 => float j; j <= 1.0; 0.5 +=> j)
        {
            Math.random2(0, 4) * 12 => position;
            beat / Math.random2(2, 16) => env1.decayTime;
            <<< "panValue: ", panValue>>>;
            <<< "chord: ", chord>>>;
            Std.mtof(chord[i] + offset + position) => osc1.freq;
            1 => env1.keyOn;
            beat / 4 => now;
        }
    }
}

while (true) {
    randomArpeggiate();
}
