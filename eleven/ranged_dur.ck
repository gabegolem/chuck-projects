public class RangedDur {
    dur value;
    dur min;
    dur max;
    
    fun RangedDur(dur l, dur h) {
        l => min;
        h => max;
    }
    
    fun RangedDur(dur v, dur l, dur h) {
        v => value;
        l => min;
        h => max;
    }
    
    fun dur setvalue(float v) {
        v * ((max - min) / 127) + min => value;
        <<<value>>>;
        return value;
    }
    fun dur setmin(dur l) {l => min; return min;}
    fun dur setmax(dur h) {h => max; return max;}
    
    fun dur setvalue() {return value;}
    fun dur setmin() {return min;}
    fun dur setmax() {return max;}
}