<<< "Filters and Shreds" >>>;

SqrOsc osc1 => NRev rev => Pan2 pan => ADSR env1;
SawOsc osc2 => rev => pan => env1;
TriOsc osc3 => NRev rev3 => ADSR env3 => dac;


BRF brffilter;
LPF lpffilter;
HPF hpffilter;

Delay d1;
Delay d2;
Delay d3;

0.6::second => dur beat;

.05 => rev.mix;
.5 => pan.gain;

.25 => osc3.gain;
.15 => rev3.mix;
(beat , beat / 2, .5, 1::ms) => env3.set;
env3 => d3 => dac;
beat * 5 => d3.max;
beat / 2.5 => d3.delay;
0.4 => d3.gain;
d3 => d3;


//set delay timing
beat * 3.2 => d1.max => d2.max;
beat /2 => d1.delay;
beat => d2.delay;
0.5 => d1.gain => d2.gain;
d1 => d2;
d2 => d1;

//set pitch collection
[0,7,12,16,19,24, 5] @=> int pitches[];
36 => int offset;

//set default for envelope and filter
(1::ms, beat * 4, 0, 1::ms) => env1.set;
0.015 => osc1.gain => osc2.gain;


fun void filterFun(FilterBasic filter, float q, dur duration, int low, int high)
{
    q => filter.Q;
    env1 => filter => dac;
    filter => d1 => dac.right;
    filter => d2 => dac.left;
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

fun void spaceVibes()
{
    int randomPitch;
    while(true)
    {
        pitches[Math.random2(0,pitches.cap() -1)] => randomPitch;
        Std.mtof(randomPitch + offset) => osc1.freq;
        Std.mtof(randomPitch + offset + 7) => osc2.freq;
        Math.random2f(-.75, .75) => pan.pan;
        1 => env1.keyOn;

        beat / 3 => now;
    }
}

fun void spaceSing() {
    int randomPitch;
    while (true)
    {
        pitches[Math.random2(0,pitches.cap() -1)] => randomPitch;
        Std.mtof(randomPitch + offset + 12) => osc3.freq;
        1 => env3.keyOn;
        Math.random2(2, 5) * beat => now;
    }
}
        
        

spork ~ filterFun(brffilter, .2, .5::ms, 250, 3000);
spork ~ filterFun(lpffilter, .2, .23::ms, 100, 4000);
spork ~ spaceVibes();
spork ~ spaceSing();
while (true)
{
    beat => now;
}
//spork ~ filterFun(hpffilter, 8 , .3::ms, 75, 2000);


