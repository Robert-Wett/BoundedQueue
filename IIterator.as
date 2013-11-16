/*
 *  IIterator Interface - The interface for a collection iterator.
 *
 *  Copyright (c) 2013, Jay Wettlaufer. (Used by permission.)
 */

package com.bqueue.flex.util {
    
    /**
     *  The <code>IIterator</code> interface defines the interface for an iterator over 
     *  a collection of objects.  (Modeled after the Java <code>Iterator</code> interface
     *  for familiarity.)
     *
     *  <p><b>Note:</b> Classes implementing this interface must implement all required
     *                  methods, and throw the documented exceptions for optional 
     *                  methods not implemented.</p>
     *
     *  @see LinkedList 
     *  @see ListIterator 
     *  @see ICollection
     *
     */
    public interface IIterator { 

        /**
         *  <code>true</code> if the iteration has more elements; <code>false</code>
         *  otherwise.  Guarantees a call to the <code>next()</code> method will 
         *  return an element if <code>true</code>.
         *
         *  <p><b>Note:</b> For collections that allow traversal of an ordered set of
         *                  elements in reverse, this method will 
         *                  generally return the previous element in the collection (logically the 
         *                  "next" element when moving backwards through the collection.)</p>
         *
         *  @return <code>true</code> if the iteration has more elements.
         */
        function hasNext() : Boolean;
        
        /**
         *  Returns the next element in the iteration sequence.  The first call
         *  to <code>next()</code> returns the first element in the iteration.
         *
         *  @return The next element in the iteration. (<b>Note:</b> You must
         *          catch the <code>RangeError</code> exception to determine 
         *          when the iterator is past the end of the list.) 
         *
         *  @throws  <code>RangeError</code> if there are no more elements
         *          in the iteration.
         */
        function next() : *;    
        
        /**
         *  Removes the underlying collection item (e.g., a linked list node) referenced by the iterator.
         *
         *  @return <code>true</code> if the referenced object is removed. <code>false</code> if 
         *          <code>next()</code> method has not been called (i.e., the iterator has no
         *          reference point), or if the iterator is past the end of the underlying 
         *          collection after the last call to the <code>next()</code> method.
         *
         *  @throws  <code>IllegalOperationError</code> if the iterator implementing this interface
         *          does not support the remove operation.
         */
        function remove() : Boolean;
    }
}
