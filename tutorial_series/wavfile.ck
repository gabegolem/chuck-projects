<<< ".wav file sample" >>>;

SinOsc osc1 => dac => WvOut waveout => blackhole;

"ChuckProjects/wavfiles/sinosc.wav" => waveout.wavFilename;

0.5 => osc1.gain;
440 => osc1.freq;

1::second => now;

