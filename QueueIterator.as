package com.bqueue.flex.util {  
    
    import flash.errors.IllegalOperationError;
    /*
     *  Note: This class wraps a ListIterator as a composite object, but does not expose all of its methods.
     *        This is done to preserve the ability to use another data structure other than a list and not
     *        to expose the "resetToNode()" method which is not required in this case.  (Originally before
     *        switching to the current LinkedList implementation, this was a standalone iterator implementation
     *        and not a "pass-through" implementation.)
     */
    
    /**
     * The <code>QueueIterator</code> class implements an iterator specific to queues using <code>LinkedList</code> objects
     * as their backing store. For example a call to the <code>BoundedQueue.getIterator()</code> method
     * will return an iterator of this type. 
     * 
     *
     * <h6> Example Usage: </h6>
     * 
     * <listing>
import com.bqueue.util.QueueIterator;
import com.bqueue.util.BoundedQueue;
     
var queue  : BoundedQueue = new BoundedQueue(String, 4);
var names1 : Array        = new Array("Abed", "Berry", "Carl", "Dick");
var names2 : Array        = new Array("Earl", "Fred",  "Gary", "Herb");
var iter   : QueueIterator;
var i      : int;
     
for (i = 0; i &lt; names1.size; i++)
    queue.put(names1[i]);
iter = queue.getIterator();
trace(iter.data);  // Traces "null" to the console.
while(iter.hasNext()) {
    iter.next();
    name += (iter.data + ", ");
}           
trace(name.substr(0, name.size - 2)); // Traces "Abed, Berry, Carl, Dick" to the console.
trace(iter.hasNext());                  // Traces "false" to the console.
iter.start();
trace(iter.hasNext());                  // Traces "true" to the console.
     
i = 0;
while(iter.hasNext()) {
    iter.next();
    iter.data = names2[i];
    i++;
}
iter.start();
name = "";
while(iter.hasNext()) {
    iter.next();
    name += (iter.data + ", ");
}   
trace(name.substr(0, name.size - 2)); // Traces "Earl, Fred, Gary, Herb" to the console.
     
iter = queue.getIterator(false);        // Start at the tail and iterate backwards.
name = "";
while(iter.hasNext()) {
    iter.next();
    name += (iter.data + ", ");
}
trace(name.substr(0, name.size - 2)); // Traces "Herb, Gary, Fred, Earl" to the console.
     * </listing>
     * 
     * @see com.bqueue.flex.util.IIterator
     * @see com.bqueue.flex.util.QueueIterator
     * @see com.bqueue.flex.util.BoundedQueue#getIterator()
     * 
     * @author Robert Wettlaufer
     */
    public class QueueIterator implements IIterator {
        
        private var _iterator          : ListIterator;
        
        /**
         * Constructs a <code>QueueIterator</code> object for a specified <code>LinkedList</code> object 
         * that will start at <code>startIndex</code> and iterate forward through each entry if the 
         * <code>forward</code> parameter is <code>true</code>, backwards if <code>false</code>.  
         * 
         * @param list The <code>LinkedList</code> for the iterator to traverse.
         * @param forward The direction to traverse the list.  <code>true</code> for forward and
         *                <code>false</code> for backward.
         * @param startIndex The starting position in the list.
         * 
         * @throws <code>ArgumentError</code> if <code>list</code> is <code>null</code> or 
         *         <code>startIndex</code> is invalid. 
         */
        public function QueueIterator(list       : LinkedList,
                                      forward    : Boolean = true,
                                      startIndex : Number  = 0)
        {
            if (list == null)
                throw new ArgumentError("'list' parameter cannot be null.");
            _iterator = new ListIterator(list, forward, startIndex);
        }
        
        /**
         *  The data value for the last element returned by the <code>next()</code> method.
         *  This method can be used to access/change the data associated with the last-referenced node.
         *  The value of this property will be <code>null</code> if any of the following conditions are met:
         *  <ul>
         *      <li>The backing list is empty</li>
         *      <li>The iterator has been reset by a call to <code>start(), 
         *          resetToIndex(), resetToFirst()</code> or <code>resetToLast()</code></li>
         *      <li>There has been no prior call to <code>next()</code></li>
         *      <li>The data associated with the node is itself <code>null</code></li>
         *  </ul>
         *  <p>
         *  Setting this property has has no effect if any of the following conditions are met:
         *  <ul>
         *      <li>The backing list is empty</li>
         *      <li>The iterator has been reset by a call to <code>start(), 
         *          resetToIndex(), resetToFirst()</code> or <code>resetToLast()</code></li>
         *      <li>There has been no prior call to <code>next()</code></li>
         *  </ul>
         *  </p>
         * 
         *  <p><strong>Example usage:</strong></p>
         *  <listing>
 var queue : BoundedQueue  = new BoundedQueue(int, 2);
 var iter  : QueueIterator = queue.getIterator();
 
 for (var i : int = 0; i &lt; queue.size; i++)
     queue.put(i);
 trace(iter.data); // Trace "null" to the console.
 iter.getNext();
 trace(iter.data); // Trace "0" to the console.
         *  </listing>
         */
        public function get data() : Object {
            return _iterator.data;
        }
        public function set data(value : Object) : void {           
            _iterator.data = value;
        }
        
        /**
         * Returns the next element in the iteration sequence. The first call to <code>next()</code> returns
         * the first element in the iteration.
         * <p>
         * <em>Notes:</em>
         * <ul>
         *     <li>When traversing the list in reverse, the <code>next()</code> method will actually return 
         *         the previous node (the node closer to the head) in the list which is the logical "next"
         *         element. </li>
         *     <li>Successive calls to the <code>next()</code> method will eventually result in a 
         *         <code>RangeError</code> being thrown when the end of the list is reached.</li>
         *     <li>A <code>RangeError</code> will be thrown on a call to this method when the list is
         *         empty.</li>
         * </ul>
         * </p>
         * 
         * <p><strong>Example usage:</strong></p>
         * <listing>
 // Prints the following to the console:
 //
 // Forward Traversal:
 //     Node Value: 1
 //     Node Value: 2
 //     Node Value: 3
 //     Node Value: 4
 //     Node Value: 5
 // Backward Traversal:
 //     Node Value: 5
 //     Node Value: 4
 //     Node Value: 3
 //     Node Value: 2
 //     Node Value: 1 
     
 var queue : BoundedQueue  = new BoundedQueue(String, 5);
 var iter  : QueueIterator;
 var i     : int;
     
 // Add five strings to the queue.
 for (i = 1 ; i &lt;= queue.capacity ; i++)
     queue.put(i as String);
     
 iter = queue.getIterator();
 trace("Forward Traversal:");
 while (iter.hasNext()) {
     iter.next();
     trace("    Node Value: " + iter.data as String);
 }
     
 iter = queue.getIterator(false);
 trace("Backward Traversal:");
 while (iter.hasNext()) {
     iter.next();
     trace("    Node Value: " + iter.data as String);
 }
         * </listing>
         * 
         * @return The next element in the iteration. (<em>Note:</em> you can catch the
         *         <code>RangeError</code> exception to determine when the iterator has
         *         passed the end/beginning of the list.)
         * 
         * @throws <code>RangeError</code> if there are no more elements in the direction
         *         of the iteration, or if the list has no entries.
         */
        public function next() : * {
            return _iterator.next();
        }
        
        /**
         * Returns <code>true</code> if the iteration has more elements, <code>false</code> otherwise.
         * Guarantees that a call to the <code>next()</code> method will return an element if <code>true</code>.
         * <p><em>Note: </em> If traversing the list in reverse, this method will return the previous node
         *                    in the list (logically the next node when moving backwards through the list).</p>
         * 
         * <p><strong>Example usage:</strong></p>
         * <listing>
 // Prints the following to the console:
 //
 // Forward Traversal:
 // 1, 2, 3, 4, 5
 // Backward Traversal:
 // 5, 4, 3, 2, 1
 
 var queue : BoundedQueue = new BoundedQueue(int, 5);
 var iter  : QueueIterator;
 var str   : String;
 var i     : int;
 
 for (i = 1; i &lt;= queue.capacity; i++)
     queue.put(i);
 
 iter = queue.getIterator();
 trace("Forward Traversal:");
 while(iter.hasNext()) {
     iter.next();
     str += (iter.data + ", ");
 }
 trace(str.substring(0, str.size - 2)); 
 
 iter = queue.getIterator(false);
 str  = "";
 trace("Backward Traversal:");
 while(iter.hasNext()) {
     iter.next();
     str += (iter.data + ", ");
 }
 trace(str.substring(0, str.size - 2));
         * </listing>
         * 
         * 
         * @return <code>true</code> if the iteration has a previous element. <code>false</code> if the
         *         iteration has already reached the end of the list (either forward or backward.)
         */
        public function hasNext() : Boolean {
            return _iterator.hasNext();
        }
                
        /**
         * Resets the iterator to the specified position in the list. 
         * <p>
         * <em>Notes:</em>
         * <ul>
         *      <li>The <code>data</code> property contains a <code>null</code> value until a
         *          <code>next()</code> method call is made.</li>
         *      <li><code>hasNext()</code> method will always return <code>true</code>
         *          if there is at least one item in the list.</li>
         *      <li>The current traversal direction is unchanged.</li>
         * </ul>
         * </p>
         * <p><strong>Example usage:</strong></p>
         * <listing>
var queue : BoundedQueue = new BoundedQueue(int, 2);
     
for (i = 1; i &lt;= queue.capacity; i++)
    queue.put(i);
     
iter : QueueIterator  = queue.getIterator();
trace(iter.next() as int);     // Traces "1" to the console.
trace(iter.next() as int);     // Traces "2" to the console.
trace(iter.hasNext());         // Traces "false" to the console.
     
try {
    iter.next() as int;
}
catch (e : RangeError) {
    trace("RangeError trapped: Resetting position with resetToIndex() call");
    iter.resetToIndex(0);
}
trace(iter.next() as int);    // Traces "1" to the console.
trace(iter.hasNext());        // Traces "true" to the console.
         * </listing> 
         */
        public function resetToIndex(index : Number) : void {
            _iterator.resetToIndex(index);
        }
        
        /**
         * Resets the iterator to the first element in the queue.
         * <p>
         * <em>Notes:</em>
         * <ul>
         *      <li>The <code>data</code> property contains a <code>null</code> value until a
         *          <code>next()</code> method call is made.</li>
         *      <li><code>hasNext()</code> method will always return <code>true</code>
         *          if there is at least one item in the list.</li>
         *      <li>The current traversal direction is unchanged.</li>
         * </ul>
         * </p>
         * 
         * <p><strong>Example usage:</strong></p>
         * <listing>
var queue : BoundedQueue = new BoundedQueue(int, 3);
     
for (var i:int = 1; i &lt;= queue.capacity; i++)
    queue.put(i);
     
var iter : QueueIterator = queue.getIterator();
     
trace(iter.next() as int); // Traces "1" to the console.
trace(iter.next() as int); // Traces "2" to the console.
trace(iter.next() as int); // Traces "3" to the console.
iter.resetToFirst();
trace(iter.next() as int); // Traces "1" to the console. 
         * </listing>
         */
        public function resetToFirst() : void {
            _iterator.resetToFirst();
        }
        
        /**
         * Resets the iterator to the last element in the queue.
         * <p>
         * <em>Notes:</em>
         * <ul>
         *      <li>The <code>data</code> property contains a <code>null</code> value until a
         *          <code>next()</code> method call is made.</li>
         *      <li><code>hasNext()</code> method will always return <code>true</code>
         *          if there is at least one item in the list.</li>
         *      <li>The current traversal direction is unchanged.</li>
         * </ul>
         * </p>
         * 
         * <p><strong>Example usage:</strong></p>
         * <listing>
var queue : BoundedQueue = new BoundedQueue(int, 3);
     
for (var i:int = 1; i &lt;= queue.capacity; i++)
    queue.put(i);
     
var iter : QueueIterator = queue.getIterator(false);
     
trace(iter.next() as int); // Traces "3" to the console.
trace(iter.next() as int); // Traces "2" to the console.
trace(iter.next() as int); // Traces "1" to the console.
iter.resetToLast();
trace(iter.next() as int); // Traces "3" to the console. 
         * </listing>
         * 
         */
        public function resetToLast() : void {
            _iterator.resetToLast();
        }
        
        /**
         *  Removes the queue item currently referenced by the iterator.
         *
         *  @return <code>true</code> if the referenced object is removed. <code>false</code> if 
         *          <code>next()</code> method has not been called (i.e., the iterator has no
         *          reference point), or if the iterator is past the end of the underlying 
         *          collection after the last call to the <code>next()</code> method.
         *
         *  @throws  <code>IllegalOperationError</code> if the iterator implementing this interface
         *          does not support the remove operation.
         */
        public function remove() : Boolean {
            return _iterator.remove();
        }
    }
}
