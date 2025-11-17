@import "chord.ck"

SqrOsc oscPad1 => NRev revPad => Pan2 panPad => ADSR envPad;
SawOsc oscPad2 => revPad => panPad => envPad;
TriOsc oscLead => NRev revLead => ADSR envLead => dac;


BRF brffilter;
LPF lpffilter;
HPF hpffilter;

Delay dPad1;
Delay dPad2;
Delay dLead;

0.6::second => dur beat;

//Chord collection
36 => int offset; //C3
Chord chords[11];
new Chord([0,5,7,12,16,19,24]) @=> chords[0]; //Cadd4 - C3, F3, G3, C4, E4, G4, C5
new Chord([-3,7,9,16,21,24,28]) @=> chords[1]; //Am7 - A2, G3, A4, E4, A5, C5, E5
new Chord([-3,8,9,13,16,21,28]) @=> chords[2]; //AMaj7
new Chord([-4,4,8,14,16,23,28,32]) @=> chords[3]; //E7
new Chord([-4,-1,1,4,8,13,16,23,28]) @=> chords[4];//C#min7
new Chord([-3,1,6,9,13,16,21,25,28]) @=> chords[5]; //F#min7
new Chord([-2,1,6,10,16,18,22,28,30]) @=> chords[6];//F#7
new Chord([-1,3,6,11,15,22,27,30,34]) @=> chords[7];//BMaj7
new Chord([-1,2,6,9,14,21,23,26,33]) @=> chords[8];//Bmin7
new Chord([-6,-2,2,6,12,14,22,24,26,30]) @=> chords[9];//D7
new Chord([-5,-5,-1,6,11,14,19,23,30,35]) @=> chords[10]; //GMaj7
//new Chord([2,6,9,11,14,18,21]) @=> chords[2];  //Dadd6 - D3, F#3, A3, B3, D4, F#4, A4
//new Chord([-5,-1,2,6,7,11,14,18,19,23,26,30]) @=> chords[3]; //GMaj7 - G2, B2, D3, F#3, G3, B3, D4, F#4, G4, B5, D5, F#5
//new Chord([-6,-2,1,4,6,10,13,16,18,22,25,28]) @=> chords[4]; //F#7
//new Chord([-7,-3,0,4,5,9,12,16,17,21,24,28]) @=> chords[5]; //FMaj7
//new Chord([-7,-4,0,3,5,8,12,15,17,20,24,27]) @=> chords[6]; //Fm7 add9
//new Chord([-8,-5,-2,0,4,7,10,12,16,19,22,24]) @=> chords[7]; //CM7
//new Chord([-3,1,4,7,9,13,16,19,21,25,28,31]) @=> chords[8]; //A7
//new Chord([-3,0,3,6,9,12,15,18,21,24,27,30]) @=> chords[9]; //F#halfdim7
//new Chord([-8,-4,-1,3,4,8,11,15,16,20,23,27]) @=> chords[10]; //EM7

//Song parameters
15 => int minChordLength;
30 => int maxChordLength;

.05 => revPad.mix;
.5 => panPad.gain;

.25 => oscLead.gain;
.15 => revLead.mix;
(beat , beat / 2, .5, 1::ms) => envLead.set;

//Delay Lead
envLead => dLead => dac;
beat * 5 => dLead.max;
beat / 2.5 => dLead.delay;
0.6 => dLead.gain;
dLead => dLead;


//Delay Pad1&2
beat * 3.2 => dPad1.max => dPad2.max;
beat / 2 => dPad1.delay;
beat => dPad2.delay;
0.5 => dPad1.gain => dPad2.gain;
dPad1 => dPad2;
dPad2 => dPad1;


//set default for envelope and filter
(1::ms, beat * 4, 0, 1::ms) => envPad.set;
0.035 => oscPad1.gain => oscPad2.gain;

//Uses the passed filter, changing its q from low to high
fun void filterFun(FilterBasic filter, float q, dur duration, int low, int high)
{
    q => filter.Q;
    envPad => filter => dac;
    filter => dPad1 => dac.right;
    filter => dPad2 => dac.left;
    while(true)
    {
        for(high => int i; i >= low; i--)
        {
            i => filter.freq;
            duration => now;            
        }        
        for(low => int j; j <= high; j++)
        {
            j => filter.freq;
            duration => now;            
        }
    }
}

//Creates the pad
fun void spaceVibes(Chord chord)
{
    int randomPitch;
    while(true)
    {
        int pitches[];
        chord.getPitches() @=> pitches;
        pitches[Math.random2(0, pitches.cap() -1)] => randomPitch;
        Std.mtof(randomPitch + offset) => oscPad1.freq;
        Std.mtof(randomPitch + offset + 7) => oscPad2.freq;
        Math.random2f(-.75, .75) => panPad.pan;
        1 => envPad.keyOn;

        beat / 3 => now;
    }
}

//Creates the lead
fun void spaceSing(Chord chord) {
    int randomPitch;
    while (true)
    {
        int pitches[];
        chord.getPitches() @=> pitches;
        pitches[Math.random2(0,pitches.cap() -1)] => randomPitch;
        Std.mtof(randomPitch + offset + 12) => oscLead.freq;
        1 => envLead.keyOn;
        Math.random2(2, 5) * beat => now;
    }
}
        
        
Shred lead;
Shred pad;

spork ~ filterFun(brffilter, .2, .5::ms, 250, 3000);
spork ~ filterFun(lpffilter, .2, .23::ms, 100, 4000);
int length;

fun void testing() {
    while (true) {
        for (0 => int i; i < chords.cap(); i++) {
            spork ~ spaceVibes(chords[i]) @=> lead;
            spork ~ spaceSing(chords[i]) @=> pad;
            Math.random2(5,5) => length;
            length::second => now;
            lead.exit();
            pad.exit();
        }
    }
}

fun void main() {
    while (true) {
        for (0 => int i; i < chords.cap(); i++) {
            spork ~ spaceVibes(chords[i]) @=> lead;
            spork ~ spaceSing(chords[i]) @=> pad;
            Math.random2(minChordLength, maxChordLength) => length;
            length::second => now;
            lead.exit();
            pad.exit();
        }
    }
}

testing();
//spork ~ filterFun(hpffilter, 8 , .Lead::ms, 75, 2000);


