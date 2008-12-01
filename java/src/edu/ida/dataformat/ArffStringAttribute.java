/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package edu.ida.dataformat;

/**
 *
 * @author mikio
 */
public class ArffStringAttribute implements ArffAttribute {

    public boolean parseAttribute(ArffFile arff, String name, String spec) {
        spec = spec.toLowerCase();
        if (spec.equals("string")) {
            arff.defineAttribute(name, "string", null);
            return true;
        }
        else
            return false;
    }

    public Object parseValue(ArffFile arff, String token) {
        return token;
    }

}
