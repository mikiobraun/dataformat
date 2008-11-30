/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package edu.ida.dataformat;

/**
 *
 * @author mikio
 */
public interface ArffAttribute {

    /** Parse an attribute definition. If it doesn't match, return false,
     * otherwise true
     */
    public boolean parseAttribute(ArffFile arff, String name, String spec);

    /** Parse a value in the data section. */
    public Object parseValue(String token);
}
