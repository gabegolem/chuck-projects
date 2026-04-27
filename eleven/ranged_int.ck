public class RangedInt {
    int value;
    int min;
    int max;
    
    fun RangedInt(int l, int h) {
        l => min;
        h => max;
    }
    
    fun RangedInt(int v, int l, int h) {
        v => value;
        l => min;
        h => max;
    }
    
    fun int setvalue(int v) {
        ((v * ((max - min) $ float / 127)) + min) $ int => value;
        <<<value>>>;
        return value;
    }
    fun int setmin(int l) {l => min; return min;}
    fun int setmax(int h) {h => max; return max;}
    
    fun int setvalue() {return value;}
    fun int setmin() {return min;}
    fun int setmax() {return max;}
}