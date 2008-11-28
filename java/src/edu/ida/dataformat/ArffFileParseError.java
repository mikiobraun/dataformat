/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package edu.ida.dataformat;

/**
 * A parse error in an ArffFile.
 *
 * Constructs an error message including the line number.
 *
 * @author Mikio L. Braun, mikio@cs.tu-berlin.de
 */
public class ArffFileParseError extends Exception {

    /** Construct a new ArffFileParseErrro object. */
    public ArffFileParseError(int lineno, String string) {
        super("Parse error line " + lineno + ": " + string);
    }

}
