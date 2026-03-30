public class RangedFloat {
    float value;
    float min;
    float max;
    
    fun RangedFloat(float l, float h) {
        l => min;
        h => max;
    }
    
    fun RangedFloat(float v, float l, float h) {
        v => value;
        l => min;
        h => max;
    }
    
    fun float setvalue(float v) {v => value; return value;}
    fun float setmin(float l) {l => min; return min;}
    fun float setmax(float h) {h => max; return max;}
    
    fun float setvalue() {return value;}
    fun float setmin() {return min;}
    fun float setmax() {return max;}
}
