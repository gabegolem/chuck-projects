<<< "Samples and the SndBuf Ugen" >>>;

SndBuf guitar => dac;
.1 => dac.gain;

me.dir() + "gabeg/ChuckProjects/sounds_guitar.wav" => string filename;
filename => guitar.read;

-0.5 => guitar.rate;
guitar.samples() - 1 => guitar.pos;

5::second => now;

<<<filename>>>;

<<< guitar.samples() / 44100.0 >>>;

//guitar.samples() => guitar.pos; //Stops playback

for (0 => int i; i < 8; i++)
{
    guitar.samples() / 4 => guitar.pos;
    0.2::second => now;
}