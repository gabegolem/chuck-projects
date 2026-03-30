//MIDI
0 => int device;

MidiIn min;

MidiMsg msg;

if (!min.open(device)) me.exit();

<<< "MIDI Device ", min.num(), " -> ", min.name() >>>;


//Instrument Declarations
SqrOsc oscPad1 => NRev revPad => Pan2 panPad => ADSR envPad;
SawOsc oscPad2 => revPad => panPad => envPad;
TriOsc oscLead => NRev revLead => ADSR envLead => dac;

BRF brffilter;
LPF lpffilter;
HPF hpffilter;

Delay dPad1;
Delay dPad2;
Delay dLead;


//Scalable Values
RangedDur beat(0.6::second, 0.1::second, 2::second); //22
RangedFloat modulation(1.0, 0.0, 12.0); //30 up, 40 down, 21 to change

RangedFloat filterq1(.2, .05, .5);
RangedDur filterdur1(.5::ms, .1::ms, 5::ms);
RangedInt filterlow1(250, 1, 3000);
RangedInt filterhigh1(3000, 250, 5000);

RangedFloat filterq2(.2, .05, .5);
RangedDur filterdur2(.23::ms, .05::ms, 5::ms);
RangedInt filterlow2(100, 1, 4000);
RangedInt filterhigh2(4000, 100, 8000);

//Chord collection
36 => float offset; //C3
Chord chords[3];
new Chord([0,5,7,12,16,19,24]) @=> chords[0]; //Cadd4 - C3, F3, G3, C4, E4, G4, C5
new Chord([-3,7,9,16,21,24,28]) @=> chords[1]; //Am7 - A3, G3, A4, E4, A5, C5, E5
new Chord([2,6,9,11,14,18,21]) @=> chords[2];  //Bm7/D - D3, F#3, A3, B3, D4, F#4, A4

.05 => revPad.mix;
.5 => panPad.gain;

.25 => oscLead.gain;
.15 => revLead.mix;
(beat.value , beat.value / 2, .5, 1::ms) => envLead.set;

//Delay Lead
envLead => dLead => dac;
beat.value * 5 => dLead.max;
beat.value / 2.5 => dLead.delay;
0.6 => dLead.gain;
dLead => dLead;


//Delay Pad1&2
beat.value * 3.2 => dPad1.max => dPad2.max;
beat.value / 2 => dPad1.delay;
beat.value => dPad2.delay;
0.5 => dPad1.gain => dPad2.gain;
dPad1 => dPad2;
dPad2 => dPad1;


//set default for envelope and filter
(1::ms, beat.value * 4, 0, 1::ms) => envPad.set;
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
        
        beat.value / 3 => now;
    }
}

fun padVolume() {
    while (true) {
        
        min => now;
        
        while (min.recv(msg)) {
            <<< msg.data2, msg.data3 >>>;
            
            //Pad volume
            if (msg.data2 == 2) {
                msg.data3 * (0.035 / 127) => oscPad1.gain => oscPad2.gain;
            }
            
            //Lead Volume
            else if (msg.data2 == 3) {
                msg.data3 * (.25 / 127) => oscLead.gain;
            }
            
            //Beat Value
            else if (msg.data2 == 22) {
                (msg.data3 * (beat.max / 127)+ (beat.max / 127)) => beat.value;
            }
            
            //Modulation Value
            else if (msg.data2 == 21) {
                (msg.data3 * (modulation.max / 127)+ (modulation.max / 127)) => modulation.value;
            }
            
            //Modulate Up
            else if (msg.data2 == 30) {
                (offset + modulation.value) => offset;
            }
            
            //Modulate Down
            else if (msg.data2 == 40) {
                (offset - modulation.value) => offset;
            }
            
            
        }
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
        Math.random2(2, 5) * beat.value => now;
    }
}


Shred lead;
Shred pad;
Shred padVol;
Shred tempo;

fun void filterFunbrf() {
    BRF filter1;
    filterq1.value => filter1.Q;
    envPad => filter1 => dac;
    filter1 => dPad1 => dac.right;
    filter1 => dPad2 => dac.left;
    while(true)
    {
        for(filterhigh1.value => int i; i >= filterlow1.value; i--)
        {
            i => filter1.freq;
            filterdur1.value => now;            
        }        
        for(filterlow1.value => int j; j <= filterhigh1.value; j++)
        {
            j => filter1.freq;
            filterdur1.value => now;            
        }
    }
}

fun void filterFunlpf() {
    LPF filter2;
    filterq2.value => filter2.Q;
    envPad => filter2 => dac;
    filter2 => dPad1 => dac.right;
    filter2 => dPad2 => dac.left;
    while(true)
    {
        for(filterhigh2.value => int i; i >= filterlow2.value; i--)
        {
            i => filter2.freq;
            filterdur2.value => now;            
        }        
        for(filterlow2.value => int j; j <= filterhigh2.value; j++)
        {
            j => filter2.freq;
            filterdur2.value => now;            
        }
    }
}
spork ~ filterFunbrf();
spork ~ filterFunlpf();

int length;
while (true) {
    for (0 => int i; i < chords.cap(); i++) {
        spork ~ padVolume() @=> padVol;
        spork ~ spaceVibes(chords[i]) @=> lead;
        spork ~ spaceSing(chords[i]) @=> pad;
        Math.random2(10,10) => length;
        length::second => now;
        lead.exit();
        pad.exit();
        padVol.exit();
    }
}

    
//spork ~ filterFun(hpffilter, 8 , .Lead::ms, 75, 2000);


