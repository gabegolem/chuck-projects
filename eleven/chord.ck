@import "ranged_float.ck"
@import "ranged_dur.ck"
@import "ranged_int.ck"

public class Chord {
    int m_pitches[];
    
    fun Chord(int pitches[]) {
        pitches @=> m_pitches;
    }
    
    fun void modulate(RangedInt thing) {
        for (0 => int i; i < m_pitches.size(); i++) {
            thing.value + m_pitches[i] => m_pitches[i];
        }
    }
    
    fun int[] getPitches() {return m_pitches;}
    fun void setPitches(int pitches[]) {pitches @=> m_pitches;}
}