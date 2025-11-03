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
36 => int offset;
Chord chords[4];
new Chord([0,5,7,12,16,19,24]) @=> chords[0]; //Cadd4 - C3, F3, G3, C4, E4, G4, C5
new Chord([-3,7,9,16,21,24,28]) @=> chords[1]; //Am7 - A3, G3, A4, E4, A5, C5, E5
new Chord([2,6,9,11,14,18,21]) @=> chords[2];  //B7 - D3, F#3, A3, B3, D4, F#4, A4
new Chord([0]) @=> chords[3];


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
while (true) {
    for (0 => int i; i < chords.cap(); i++) {
        spork ~ spaceVibes(chords[i]) @=> lead;
        spork ~ spaceSing(chords[i]) @=> pad;
        Math.random2(10,10) => length;
        length::second => now;
        lead.exit();
        pad.exit();
    }
}
//spork ~ filterFun(hpffilter, 8 , .Lead::ms, 75, 2000);


