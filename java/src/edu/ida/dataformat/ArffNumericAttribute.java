/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package edu.ida.dataformat;

/**
 *
 * @author mikio
 */
public class ArffNumericAttribute implements ArffAttribute {

    public boolean parseAttribute(ArffFile arff, String name, String spec) {
        spec = spec.toLowerCase();
        if (spec.equals("real") || spec.equals("numeric") || spec.equals("integer")) {
            arff.defineAttribute(name, "numeric", null);
            return true;
        } else {
            return false;
        }
    }

    public String toString() {
        return "numeric";
    }

    public Object parseValue(String token) {
        return Double.parseDouble(token);
    }
}
