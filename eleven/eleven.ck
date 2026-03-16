@import "chord.ck"

//Song parameters
8 => int minChordLength; //Minimum beats a chord lasts for
16 => int maxChordLength; //Maximum beats a chord lasts for
0.6::second => dur beat;  //Length in seconds of beat

//Chord collection
36 => int offset; //C3
Chord chords[3];
new Chord([0,5,7,12,16,19,24]) @=> chords[0]; //Cadd4 - C3, F3, G3, C4, E4, G4, C5
new Chord([-3,7,9,16,21,24,28]) @=> chords[1]; //Am7 - A2, G3, A4, E4, A5, C5, E5
new Chord([-7,0,5,9,12,17,21,29]) @=> chords[2]; //F - F2, C3, F3, A3, C4, F4, A4, F5


//Pad

  //parameters
  .05 => float revPadMix;
  .0175 => float envPadGain;
  3.2 => float delayPadMaxMultiplier;
  0.5 => float delayPadGain;

SqrOsc oscPad1 => NRev revPad => Pan2 panPad => ADSR envPad;
SawOsc oscPad2 => revPad => panPad => envPad;

Delay dPad1;
Delay dPad2;

revPadMix => revPad.mix;
envPadGain => envPad.gain;

//Delay Pad1&2
delayPadMaxMultiplier * beat => dPad1.max => dPad2.max;
beat / 2 => dPad1.delay;
beat => dPad2.delay;
delayPadGain => dPad1.gain => dPad2.gain;
dPad1 => dPad2;
dPad2 => dPad1;

(1::ms, beat * 4, 0, 1::ms) => envPad.set; //Sets pad ADSR


//Lead

TriOsc oscLead => NRev revLead => ADSR envLead => dac;

Delay dLead;

.15 => revLead.mix; 
.25 => envLead.gain; //Gain for lead
(beat , beat / 2, .5, 1::ms) => envLead.set; //Sets lead ADSR

//Delay Lead
envLead => dLead => dac;
beat * 5 => dLead.max;
beat / 2.5 => dLead.delay;
0.6 => dLead.gain;
dLead => dLead;


//Filters
BRF brffilter;
LPF lpffilter;
HPF hpffilter;




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

fun void main() {
    while (true) {
        for (0 => int i; i < chords.cap(); i++) {
            spork ~ spaceVibes(chords[i]) @=> lead;
            spork ~ spaceSing(chords[i]) @=> pad;
            Math.random2(minChordLength, maxChordLength) => length;
            (beat * length) => now;
            lead.exit();
            pad.exit();
        }
    }
}

main();
//spork ~ filterFun(hpffilter, 8 , .Lead::ms, 75, 2000);


