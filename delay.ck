TriOsc osc1 => ADSR env1 => NRev rev1 => dac;
TriOsc osc2 => ADSR env2 => dac;

Delay delay1;
delay1 => dac;
delay1 => delay1;

0.025 => osc1.gain;
0.1 => osc2.gain; 

0.3 => rev1.mix;

[0,4,7,12] @=> int major[];
[0,3,7,12] @=> int minor[];
[0,4,8,12] @=> int augmented[];
[0,3,6,12] @=> int diminished[];

[0, 4, 7, 11, 12] @=> int major7[];
[0, 3, 7, 10, 12] @=> int minor7[];
[0, 4, 7, 10, 12] @=> int dominant7[];
[0, 3, 6, 10, 12] @=> int halfdiminished7[];
[0, 3, 6, 9, 12] @=> int fulldiminished7[];

60 => int offset;
int position;
2::second => dur beat;

(1::ms, beat / 8, 0, 1::ms) => env1.set;
env1 => delay1;

beat => delay1.max;
beat / 8 => delay1.delay;
0.5 => delay1.gain;


fun void arpeggiate( int chord[], int position) {
    for (0 => int i; i < chord.cap(); i++) 
    {
        Std.mtof(chord[i] + offset + position) => osc1.freq;
        1 => env1.keyOn;
        beat / chord.cap() => now;
    }
}

while (true) {
    arpeggiate(minor, 0);
    arpeggiate(major, -4);
    arpeggiate(major, -2);
    arpeggiate(major, -5);
}
