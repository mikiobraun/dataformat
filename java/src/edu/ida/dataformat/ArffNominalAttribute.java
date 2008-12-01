/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package edu.ida.dataformat;

/**
 *
 * @author mikio
 */
public class ArffNominalAttribute implements ArffAttribute {

    public boolean parseAttribute(ArffFile arff, String name, String spec) {
        if (spec.charAt(0) == '{' && spec.charAt(spec.length() - 1) == '}') {
            spec = spec.substring(1, spec.length() - 1);
            spec = spec.trim();
            arff.defineAttribute(name, "nominal", spec.split("\\s*,\\s*"));
            return true;
        } else {
            return false;
        }
    }

    public Object parseValue(ArffFile arff, String token) {
        Object[] datum = new Object[arff.getNumberOfAttributes()];

        if (!isNominalValueValid(arff, name, tokens[i])) {
            throw new ArffFileParseError(lineno, "Undefined nominal value \"" +
                    tokens[i] + "\" for field " + name + ".");
        }
        datum[i] = tokens[i];
    }

    private boolean isNominalValueValid(ArffFile arff, String name, String token) throws ArffFileParseError {
        String[] values = arff.getAttributeData().get(name);
        boolean found = false;
        for (int t = 0; t < values.length; t++) {
            if (values[t].equals(token)) {
                found = true;
            }
        }
        return found;
    }

}
