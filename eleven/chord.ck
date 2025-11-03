public class Chord {
    int m_pitches[];
    
    fun Chord(int pitches[]) {
        pitches @=> m_pitches;
    }
    
    fun void print()
    {
        <<<"Worked">>>;
    }
    
    fun int[] getPitches() {return m_pitches;}
    fun void setPitches(int pitches[]) {pitches @=> m_pitches;}
}