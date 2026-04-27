@import "chord.ck"


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


//General Ranged Values
RangedDur beat(0.6::second, 0.001::second, 2::second); //22
RangedFloat modulation(1.0, 0.0, 12.0); //30 up, 40 down, 21 to change

//Pad Ranged Values
RangedFloat oscpadgain(.035, 0, .1);
RangedInt padmodulation(0, -12, 12);
RangedInt padbeatmult(1, 1, 16);

RangedFloat oscleadgain(.25,0,.5);
RangedInt leadmodulation(0, -12, 12);
RangedInt leadbeatmult(1,1,16);

//Filter Ranged Values
RangedFloat filterq1(.2, .05, 2);
RangedDur filterdur1(.5::ms, .1::ms, 1::second);
RangedInt filterlow1(250, 1, 3000);
RangedInt filterhigh1(3000, 250, 5000);

RangedFloat filterq2(.2, .05, 1000);
RangedDur filterdur2(.23::ms, .05::ms, 1::second);
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

oscleadgain.value => oscLead.gain;
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
1 => int currentFilter;
oscpadgain.value => oscPad1.gain => oscPad2.gain;


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
            <<<i>>>;
            i => filter.freq;
            duration => now;            
        }        
        for(low => int j; j <= high; j++)
        {
            <<<j>>>;
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

Shred brf_shred;
Shred lpf_shred;
Shred hpf_shred;

0 => int brf_toggle;
0 => int lpf_toggle;
0 => int hpf_toggle;


fun padVolume() {
    while (true) {
        
        min => now;
      
        
        while (min.recv(msg)) {
            <<< msg.data2, msg.data3 >>>;
            
            //Pad volume
            if (msg.data2 == 3) {
                oscpadgain.setvalue(msg.data3) => oscPad1.gain => oscPad2.gain;
            }
            
            //Lead Volume
            else if (msg.data2 == 2) {
                oscleadgain.setvalue(msg.data3) => oscLead.gain;
            }
            
            //Beat Value
            else if (msg.data2 == 22) {
                beat.setvalue(msg.data3);
            }
            
            //Modulation Value
            else if (msg.data2 == 21) {
                modulation.setvalue(msg.data3);
            }
            
            //Modulate Up
            else if (msg.data2 == 30) {
                (offset + modulation.value) => offset;
            }
            
            //Modulate Down
            else if (msg.data2 == 40) {
                (offset - modulation.value) => offset;
            }
            
            else if (msg.data2 == 26) {
                (1 => currentFilter);
            }
            
            else if (msg.data2 == 36) {
                (2 => currentFilter);
            }
    
            else if (msg.data2 == 17) {
                if (currentFilter == 1) {
                    filterq1.setvalue(msg.data3) => filterq1.value;
                } else {
                    filterq2.setvalue(msg.data3) => filterq2.value;
                }
            }
            else if (msg.data2 == 20) {
                padmodulation.setvalue(msg.data3) => padmodulation.value;

            }
            else if (msg.data2 == 19) {
                leadmodulation.setvalue(msg.data3) => leadmodulation.value;
            }
            else if (msg.data2 == 29) {
                for (0 => int i; i < chords.size(); i++) {
                    chords[i].modulate(leadmodulation);
                }
            }
            else if (msg.data2 == 39) {
                for (0 => int i; i < chords.size(); i++) {
                    chords[i].modulate(padmodulation);
                }
            }
            else if (msg.data2 == 47 && msg.data3 == 127 && brf_toggle == 0) {
                spork ~ filterFunbrf() @=> brf_shred;
                1 => brf_toggle;
            }
            else if (msg.data2 == 47 && brf_toggle == 1 && msg.data3 == 127) {
                brf_shred.exit();
                0 => brf_toggle;
            }
            else if (msg.data2 == 45 && lpf_toggle == 0 && msg.data3 == 127) {
                spork ~ filterFunlpf() @=> lpf_shred;
                1 => lpf_toggle;
            }
            else if (msg.data2 == 45 && lpf_toggle == 1 && msg.data3 == 127) {
                lpf_shred.exit();
                0 => lpf_toggle;
            }
            else if (msg.data2 == 48 && hpf_toggle == 0 && msg.data3 == 127) {
                spork ~ filterFunhpf() @=> hpf_shred;
                    1 => hpf_toggle;
            } 
            else if (msg.data2 == 48 && hpf_toggle == 1 && msg.data3 == 127) {
                    hpf_shred.exit();
                    0 => hpf_toggle;
            }
            else if (msg.data2 == 46 && lpf_toggle == 0 && brf_toggle == 0 && msg.data3 == 127) {
                spork ~ filterFunbrf() @=> brf_shred;
                spork ~ filterFunlpf() @=> lpf_shred;
                1 => brf_toggle;
                1 => lpf_toggle;
            } 
            else if (msg.data2 == 46 && msg.data3 == 127 && lpf_toggle == 1 && brf_toggle == 1) {
                0 => lpf_toggle;
                0 => brf_toggle;
                brf_shred.exit();
                lpf_shred.exit();
            }
            else if (msg.data2 == 5) {
                filterdur1.setvalue(msg.data3) => filterdur1.value;
            }
            else if (msg.data2 == 6) {
                filterdur2.setvalue(msg.data3) => filterdur2.value;
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

fun void filterFunhpf() {
    HPF filter3;
    8 => filter3.Q;
    envPad => filter3 => dac;
    filter3 => dPad1 => dac.right;
    filter3 => dPad2 => dac.left;
    while(true)
    {
        for(2000 => int i; i >= 75; i--)
        {
            i => filter3.freq;
            .2::ms => now;            
        }        
        for(75 => int j; j <= 2000; j++)
        {
            j => filter3.freq;
            .2::ms => now;            
        }
    }
}

int length;
spork ~ padVolume() @=> padVol;
while (true) {
    for (0 => int i; i < chords.cap(); i++) {
        spork ~ spaceVibes(chords[i]) @=> lead;
        spork ~ spaceSing(chords[i]) @=> pad;
        Math.random2(7,15) => length;
        length::second => now;
        lead.exit();
        pad.exit();     
    }
     
}


