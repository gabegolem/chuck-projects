TriOsc osc => ADSR env1 => dac;
SqrOsc osc2 => ADSR env2 => dac;

0.05 => osc.gain;
0.02 => osc2.gain; 

[0,4,7,12] @=> int major[];
[0,3,7,12] @=> int minor[];
[0,4,8,12] @=> int augmented[];
[0,3,6,12] @=> int diminished[];

[0, 4, 7, 11, 12] @=> int major7[];
[0, 3, 7, 10, 12] @=> int minor7[];
[0, 4, 7, 10, 12] @=> int dominant7[];
[0, 3, 6, 10, 12] @=> int halfdiminished7[];
[0, 3, 6, 9, 12] @=> int fulldiminished7[];

int chords[4][4];
major @=> chords[0];
minor @=> chords[1];
augmented @=> chords[2];
diminished @=> chords[3];

48 => int offset;
int position;
1::second => dur beat;
(beat / 4, beat / 4, 0, 1::ms) => env1.set;
(1::ms, beat / 8, 0, 1::ms) => env2.set;


fun void arpeggiate( int chord[], int position) {
    for (0 => int i; i < chord.cap(); i++) 
    {
        Std.mtof(chord[i] + offset + position) => osc.freq;
        1 => env1.keyOn;
        beat / chord.cap() => now;
    }
}

fun void arpeggiate2( int chord[], int position) {
    for (0 => int i; i < chord.cap(); i++) 
    {
        Std.mtof(chord[i] + offset + position) => osc.freq;
        1 => env1.keyOn;
        for (0 => int j; j < chord.cap(); j++)
        {
            Std.mtof(chord[j] + offset + position + 12) => osc2.freq;
            1 => env2.keyOn;
            beat / chord.cap() / 2 => now;
        }
    }
}

fun void randomMelody(int chord[], int position) {
    Math.random2(4, 6) => int octave;
    12 * octave => offset;
    for (0 => int i; i < 4; i++) {
        Math.random2(0, chord.cap() - 1) => int index;
        Std.mtof(chord[index] + offset + position + 12) => osc2.freq;
        1 => env2.keyOn;
        beat / chord.cap() => now;
    }
}




int chord[4];

while (true) {
    
    chords[Math.random2(0,chord.cap() - 1)] @=> chord;
    Math.random2(-8, 5) => position;
    
    spork ~ randomMelody(chord, position);
    spork ~ arpeggiate2(chord, position);
    
    beat => now;
}
