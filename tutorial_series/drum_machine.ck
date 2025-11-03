<<< "Drum Machine" >>>;

.025 => dac.gain;

SndBuf kick => NRev kickRev => dac;
SndBuf snare => NRev snareRev => dac;
SndBuf closeHat => NRev closeHatRev => dac;
SndBuf openHat => NRev openHatRev => dac;
SndBuf clap => dac;


.15 => kickRev.mix;
.15 => snareRev.mix;
.15 => closeHatRev.mix;
.15 => openHatRev.mix;


SndBuf sounds[5];

kick @=> sounds[0];
snare @=> sounds[1];
closeHat @=> sounds[2];
openHat @=> sounds[3];
clap @=> sounds[4];

me.dir() + "14-drum-machine-sounds/" => string drumFolder;

drumFolder + "kick.wav" => string kickFilename;
drumFolder + "snare.wav" => string snareFilename;
drumFolder + "c-hat.wav" => string closeHatFilename;
drumFolder + "o-hat.wav" => string openHatFilename;
drumFolder + "clap.wav" => string clapFilename;

kickFilename => kick.read;
snareFilename => snare.read;
closeHatFilename => closeHat.read;
openHatFilename => openHat.read;
clapFilename => clap.read;

fun void silenceBuffers()
{
    for (0 => int i; i < sounds.cap(); i++)
    {
        sounds[i].samples() => sounds[i].pos;
    }
}

fun void Drum(int select, dur duration)
{
    if (select == 0)
    {
        0 => kick.pos;
        0 => closeHat.pos;
    }
    else if (select == 1)
    {
        0 => openHat.pos;
    }
    else if (select == 2)
    {
        0 => kick.pos;
        0 => closeHat.pos;
        0 => snare.pos;
    }
    duration => now;
    silenceBuffers();
}

.5::second => dur beat;

silenceBuffers();

while (true)
{
    Drum(0, beat / 2);
    Drum(1, beat / 2);
    Drum(2, beat / 2);
    Drum(1, beat / 2);
}
