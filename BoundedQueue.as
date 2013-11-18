package util {
    
import com.bqueue.flex.error.CapacityError;
import com.bqueue.flex.util.IComparator;
    
import flash.errors.IllegalOperationError;
import flash.utils.getQualifiedClassName;
    
/**
*   Implements a FIFO queue that is optionally capacity bound.  The queue also enforces type safety for 
*  all entries by designating the queue object class type in the constructor.  ActionScript 3 does not
*  intrinsically support templates/generics other than the <code>Vector</code> class but this convention
*  serves the same purpose for this object.  Example Use:
*  <listing>
// Create a FIFO queue of <code>Person</code> objects that can 
// only contain 2 entrees at a given time with no default comparator.
var fnComp : FullNameComparator = new FullNameComparator();           
var lnCmp  : LastNameComparator = new LastNameComparator();
var queue  : BoundedQueue       = new BoundedQueue(Person, 2);
queue.put(new Person("Bart", "Gunn"));
queue.put(new Person("Ted",  "Gunn"));
        
var search : Person = new Person("Bart", "Gunn");
var result : Person = queue.find(search, fnComp) as Person;
// Trace "Bart Gunn" to the console.
trace(result.first + " " + result.last);
        
var results : Array = queue.findAllMatching(search, fnComp);
// Trace "# of entries in queue: 1" to the console.
trace("# of entries in queue: " + results.length);
// Trace "Bart Gunn" to the console.
trace((results[0] as Person).first + " " + (results[0] as Person).last);
        
results = queue.findAllMatching(search, lnCmp);
// Trace "# of entries in queue: 2" to the console.
trace("# of entries in queue: " + results.length);
// Trace "Bart Gunn" to the console.
trace((results[0] as Person).first + " " + (results[0] as Person).last);
// Trace "Ted Gunn" to the console.
trace((results[1] as Person).first + " " + (results[1] as Person).last);
        
queue.drainToValue(search, fnComp);
// Trace "# of entries in queue: 2" to the console.
trace("# of entries in queue: " + results.length);
// Trace "Bart Gunn" to the console.
trace((queue.peek() as Person).first + " " + (queue.peek() as Person).last);
        
var take : Person = queue.take() as Person;
// Trace "Ted Gunn" to the console.
trace((queue.peek() as Person).first + " " + (queue.peek() as Person).last);
// Trace "Bart Gunn" to the console.
trace(take.first + " " + take.last);    
// Trace "# of entries in queue: 1" to the console.
trace("# of entries in queue: " + results.length);
        
result = queue.put(take);
// Traces "# of entries in queue: 2" to the console.
trace("# of entries in queue: " + results.length);
// Trace "Bart Gunn" to the console.
trace(result.first + " " + result.last);
// Trace "Ted Gunn" to the console.
trace((queue.peek() as Person).first + " " + (queue.peek() as Person).last);
        
results = queue.drainToSize(1);
// Trace "# of entries in queue: 1" to the console.
trace("# of entries in queue: " + results.length);
// Trace "Bart Gunn" to the console.
trace((results[0] as Person).first + " " + (results[0] as Person).last);
// Trace "Ted Gunn" to the console.
trace((queue.peek() as Person).first + " " + (queue.peek() as Person).last);
        
queue.clear();
// Trace "# of entries in queue: 1" to the console.
trace("# of entries in queue: " + results.length);   *  </listing>
     * 
     *  <p>
     *  <em>Notes:</em>
     *      <ul>
     *          <li>If this object is constructed with no parameters, the result will be an unbounded queue supporting 
     *              the insertion of any ActionScript 3 <code>Object</code></li>
     *          <li>Method calls requiring an object implementing the <code>IComparator</code> interface as
     *             a parameter (<code>remove()</code>,  <code>removeAllMatching()</code>, <code>find()</code>, <code>findAllMatching()</code> 
     *             and <code>drainToValue()</code>) will throw an <code>IllegalOperationError</code> if a comparator
     *             is not specified and no default caparator has been set</li>
     *      </ul>
     *  </p>
     * 
     *  @see defaultComparator
     * 
     *  @author Robert Wettlaufer
     */
    public class BoundedQueue {
        
        private var _capacity          : int;
        private var _queue             : LinkedList;
        private var _class             : Class;
        private var _defaultComparator : IComparator;
        
        /**
         *  Constructs a <code>BoundedQueue</code> object (a FIFO queue with an optional maximum capacity.)
         *  <p>
         *  <em>Notes:</em>
         *      <ul>
         *          <li>If this object is constructed with no parameters, the result will be an unbounded queue supporting the insertion of any 
         *              ActionScript 3 <code>Object</code>.</li>
         *          <li>Method calls requiring an object implementing the <code>IComparator</code> interface as
         *              a parameter (<code>remove()</code>,  <code>removeAllMatching()</code>, <code>find()</code>, <code>findAllMatching()</code> 
         *              and <code>drainToValue()</code>) will throw an <code>IllegalOperationError</code> if a comparator
         *              is not specified.</li>
         *      </ul>
         *  </p>
         * 
         *  @param type      The <code>Class</code> type to which every entry inserted into the queue will be restricted. 
         *                   For example, <code>var myQueue : BoundedQueue = new BoundedQueue(String);</code> will 
         *                   create a queue into which only <code>String</code> objects can be inserted.  Attempts to 
         *                   <code>put()</code> anything other than a <code>String</code> in this case will result in
         *                   an <code>ArgumentError</code> being thrown. A <code>null</code> value for this parameter 
         *                   creates a queue accepting any ActionScript 3 <code>Object</code>.
         *  @param capacity  Sets the maximum number of entries allowed in the queue.  Attempts to <code>put()</code>
         *                   an entry into the queue when its capacity has been reached will result in an
         *                   <code>CapacityError</code> being thrown. 
         *                   <em>Note:</em> A zero for this parameter will define an unbounded queue.
         * @param comparator Sets the default comparator to be used when a <code>IComparator</code> object isn't specified
         *                   as an argument to the <code>remove()</code>, <code>removeAllMatching()</code>, <code>find()</code>, <code>findAllMatching()</code>, 
         *                   or <code>drainToValue()</code> method calls. <em>Note:</em> If no default comparator is specified, an 
         *                   <code>IComparator</code> object must be provided as an argument to the above method calls, otherwise an 
         *                   <code>IllegalOperationError</code> will be thrown.
         * 
         * @see #put()
         * @see #remove() 
         * @see #removeAllMatching() 
         * @see #find() 
         * @see #findAllMatching() 
         * @see #drainToValue() 
         * @see com.bqueue.flex.error.CapacityError
         * @see com.bqueue.flex.util.IComparator
         */
        public function BoundedQueue(type       : Class       = null,
                                     capacity   : int         = 0,
                                     comparator : IComparator = null)
        {
            if (type == null)
                type = Object;
            if (comparator != null)
                _defaultComparator = comparator;
            _class     = type;
            _queue     = new LinkedList();
            _capacity  = capacity <= 0 ? int.MAX_VALUE : capacity;
        }
        
        /**
         * The maximum number of items allowed in the queue.
         */
        public function get capacity() : int {
            return _capacity;
        }
        
        /**
         * The number of items that can be inserted into the queue before it reaches capacity.
         */
        public function get remainingCapacity() : int {
            return _capacity - _queue.size;
        }
        
        /**
         * The current number of items in the queue.
         */
        public function get size() : int {
            return _queue.size;
        }
        
        /**
         * A <code>String</code> representing the name of the <code>Class</code> type this queue is restricted to.
         */
        public function get classType() : String {
            return getQualifiedClassName(_class);
        }
        
        /**
         * The default comparator used by the <code>remove()</code>,  <code>removeAllMatching()</code>, <code>find()</code>, <code>findAllMatching()</code> 
         * and <code>drainToValue()</code> methods if none is specified as an argument.  This value can be <code>null</code> if no 
         * default comparator was provided as a constructor argument or has not been otherwise set using this property.
         */
        public function get defaultComparator() : IComparator {
            return _defaultComparator;
        }
        public function set defaultComparator(comparator : IComparator) : void {
            _defaultComparator = comparator;
        }
        
        /**
         * Inserts an entry into the queue.
         * 
         * @throws ArgumentError  if an attempt is made to insert an object of a different type than that defined  
         *                        by the constructor <code>type</code> parameter.
         * @throws CapacityError  if an attempt to insert inserting the object in the queue will exceed its maximum capacity.
         * 
         * @param entry The entry to add to the queue.
         */
        public function put(entry : Object) : void {
            if (!(entry is _class))
                throw new ArgumentError("Object is of type " + getQualifiedClassName(entry) + ", must be of type " + getQualifiedClassName(_class)); 
            if ((_capacity - _queue.size) == 0)
                throw new CapacityError("Unable to insert into queue: Maximum capacity (" + _capacity +") has already been reached");
            _queue.add(entry);  
        }
        
        /**
         * Removes and returns the oldest entry in the queue.
         * 
         * @return The the oldest pending entry in queue or <code>null</code> if the queue is empty.
         */
        public function take() : * {
            if (_queue.size == 0)
                return null;
            
            var returnValue : Object = _queue.first;
            
            _queue.removeFirstNode();
            return returnValue;
        }
        
        /**
         * Removes the oldest entry from the queue identified by the specified comparator (or the default 
         * comparator if <code>comparator</code> is <code>null</code>) successfully matching <code>identifier</code>.
         * 
         * @param identifier The value used by the comparator to identify the queue entry to be
         *                   removed.
         * @param comparator An object implementing the <code>IComparator</code> interface to be used
         *                   to identify the queue entry to be returned.  If this value is <code>null</code>, 
         *                   the default comparator will be used if it exists. If no default comparator has been
         *                   specified and <code>comparator</code> is <code>null</code>, an <code>IllegalOperationError</code>
         *                   is thrown.
         *                   <p>
         *                   <em>Comparator Implementation Notes:</em> 
         *                   <ul>
         *                       <li>The comparator must return a zero for matching entries to be identified.</li>
         *                       <li>This method will pass the <code>identifier</code> and queue entry object as the
         *                           first and second arguments respectively to the comparator.</li>
         *                   </ul>
         *                   </p>
         * 
         * @return The entry that was removed, or <code>null</code> if there was no entry in the queue matching the 
         *         criteria provided.
         * 
         * @throws IllegalOperationError if no default comparator has been specified and <code>comparator</code> is <code>null</code>.
         * 
         * @see com.bqueue.flex.util.IComparator
         */
        public function remove(identifier : Object, comparator : IComparator = null) : * {
            var curNode : ListNode = _queue.firstNode;
            
            if (comparator == null) {
                if (_defaultComparator == null)
                    throw new IllegalOperationError("A comparator must be specified (there is no default comparator for this queue.)");
                comparator = _defaultComparator;
            }
            while (true) {
                if (comparator.compare(identifier, curNode.data as Object) == 0) {
                    var returnValue : Object = curNode.data;
                    
                    _queue.removeNode(curNode); 
                    return returnValue;
                }
                if (curNode == _queue.lastNode || curNode.next == null)
                    break;
                curNode = curNode.next;             
            }
            return null;
        }
        
        /**
         * Removes every entry from the queue identified by the specified comparator
         * (or the default comparator if <code>comparator</code> is <code>null</code>) successfully
         * matching <code>identifier</code>.
         * 
         * @param identifier The value used by the comparator to identify the queue entry to be
         *                   removed.
         * @param comparator An object implementing the <code>IComparator</code> interface to be used
         *                   to identify the queue entries to be returned.  If this value is <code>null</code>, 
         *                   the default comparator will be used if it exists. If no default comparator has been
         *                   specified and <code>comparator</code> is <code>null</code>, an <code>IllegalOperationError</code>
         *                   is thrown.
         *                   <p>
         *                   <em>Comparator Implementation Notes:</em> 
         *                   <ul>
         *                       <li>The comparator must return a zero for matching entries to be identified.</li>
         *                       <li>This method will pass the <code>identifier</code> and queue entry object as the
         *                           first and second arguments respectively to the comparator.</li>
         *                   </ul>
         *                   </p>
         * 
         * @return An <code>Array</code> containing all the entries that were removed, or an empty <code>Array</code>
         *         if there were no entries in the queue matching the criteria provided.
         * 
         * @throws IllegalOperationError if no default comparator has been specified and <code>comparator</code> is <code>null</code>.
         * 
         * @see com.bqueue.flex.util.IComparator
         */
        public function removeAllMatching(identifier : Object, comparator : IComparator = null) : Array {
            
            var returnArray : Array     = new Array();
            var curNode     : ListNode  = _queue.firstNode;
            var prevNode    : ListNode  = null;
            var tempNode    : ListNode;
            
            if (comparator == null){
                if (_defaultComparator == null)
                    throw new IllegalOperationError("A comparator must be specified (there is no default comparator for this queue.)");
                comparator = _defaultComparator;
            }
            while (true) {
                if (comparator.compare(identifier, curNode.data as Object) == 0) {
                    tempNode = curNode;
                    curNode  = curNode.next;
                    returnArray.push(tempNode.data);
                    _queue.removeNode(tempNode);
                }
                else {
                    prevNode = curNode;
                    curNode  = curNode.next;                                    
                }
                if (curNode.data == null || curNode.next == null)
                    break;
            }
            return returnArray;         
        }
        
        /**
         * Returns a reference to the oldest entry in the queue identified by the specified 
         * comparator (or the default comparator if <code>comparator</code> is <code>null</code>)
         * successfully matching <code>identifier</code>
         *
         * @param identifier The value used by the comparator to identify the queue entry to be
         *                   removed.
         * @param comparator An object implementing the <code>IComparator</code> interface to be used
         *                   to identify the queue entry to be returned.  If this value is <code>null</code>, 
         *                   the default comparator will be used if it exists. If no default comparator has been
         *                   specified and <code>comparator</code> is <code>null</code>, an <code>IllegalOperationError</code>
         *                   is thrown.
         *                   <p>
         *                   <em>Comparator Implementation Notes:</em> 
         *                   <ul>
         *                       <li>The comparator must return a zero for matching entries to be identified.</li>
         *                       <li>This method will pass the <code>identifier</code> and queue entry object as the
         *                           first and second arguments respectively to the comparator.</li>
         *                   </ul>
         *                   </p>
         * 
         * @return A reference to the oldest entry in the queue, or <code>null</code> if there was no entry in
         *         the queue matching the criteria provided.
         * 
         * @throws IllegalOperationError if no default comparator has been specified and <code>comparator</code> is <code>null</code>.
         */
        public function find(identifier : Object, comparator : IComparator = null) : * {
            
            var curNode : ListNode = _queue.firstNode;
            
            if (comparator == null) {
                if (_defaultComparator == null)
                    throw new IllegalOperationError("A comparator must be specified (there is no default comparator for this queue.)");
                comparator = _defaultComparator;
            }
            while (true) {
                if (comparator.compare(identifier, curNode.data as Object) == 0)
                    return curNode.data as Object;
                if (curNode == _queue.lastNode || curNode.next == null)
                    break;
                curNode = curNode.next;
            }
            return null;
        }
        
        /**
         * Returns a reference to every entry from the queue identified by the specified
         * comparator (or the default comparator if <code>comparator</code> is <code>null</code>) successfully
         * matching <code>identifier</code>.
         * 
         * @param identifier The value used by the comparator to identify the queue entry to be
         *                   removed.
         * @param comparator An object implementing the <code>IComparator</code> interface to be used
         *                   to identify the queue entries to be returned.  If this value is <code>null</code>, 
         *                   the default comparator will be used if it exists. If no default comparator has been
         *                   specified and <code>comparator</code> is <code>null</code>, an <code>IllegalOperationError</code>
         *                   is thrown.
         *                   <p>
         *                   <em>Comparator Implementation Notes:</em> 
         *                   <ul>
         *                       <li>The comparator must return a zero for matching entries to be identified.</li>
         *                       <li>This method will pass the <code>identifier</code> and queue entry object as the
         *                           first and second arguments respectively to the comparator.</li>
         *                   </ul>
         *                   </p>
         * 
         * @return An <code>Array</code> containing references to all the entries found, or an empty <code>Array</code>
         *         if there were no entries in the queue matching the criteria provided.
         * 
         * @throws IllegalOperationError if no default comparator has been specified and <code>comparator</code> is <code>null</code>.
         */
        public function findAllMatching(identifier : Object, comparator : IComparator = null) : Array {
            var returnArray : Array          = new Array();
            var curNode     : ListNode = _queue.firstNode;
            
            if (comparator == null){
                if (_defaultComparator == null)
                    throw new IllegalOperationError("A comparator must be specified (there is no default comparator for this queue.)");
                comparator = _defaultComparator;
            }
            while (true) {
                if (comparator.compare(identifier, curNode.data as Object) == 0)
                    returnArray.push(curNode.data as Object);   
                if (curNode == _queue.lastNode || curNode.next == null)
                    break;
                curNode = curNode.next; 
            }
            return returnArray;         
        }
        
        /**
         * Reduce the number of entries in the queue to a specified size, beginning with the oldest
         * entry in the queue and ending when the number of queue entries match the specified
         * <code>size</code> parameter.
         * 
         * @param size The number of entries to reduce the queue to.
         * 
         * @return An <code>Array</code> containing all the entries that were removed, or <code>null</code>
         *         if the number of queue entries are less than or equal to the <code>size</code> specified.
         */
        public function drainToSize(size : int) : Array {
            var returnArray : Array = new Array();
            
            if (_queue.size <= size)
                return null;
            while (_queue.size > size) {
                returnArray.push(_queue.first);
                _queue.removeFirstNode();
            }
            return returnArray;
        }
        
        /**
         * Removes all entries in the queue older than the first entry identified by the specified 
         * comparator (or the default comparator if <code>comparator</code> is <code>null</code>) successfully
         * matching <code>identifier</code>.
         * 
         * Removes all entries in the queue older than the entry identified by the specified 
         * comparator (or the default comparator if <code>comparator</code> is <code>null</code>) successfully
         * matching against the <code>identifier</code>.
         * 
         * @param identifier The value used by the comparator to identify the queue entries to be
         *                   removed.
         * @param comparator An object implementing the <code>IComparator</code> interface to be used
         *                   to identify the queue entries to be returned.  If this value is <code>null</code>, 
         *                   the default comparator will be used if it exists. If no default comparator has been
         *                   specified and <code>comparator</code> is <code>null</code>, an <code>IllegalOperationError</code>
         *                   is thrown.
         *                   <p>
         *                   <em>Comparator Implementation Notes:</em> 
         *                   <ul>
         *                       <li>The comparator must return a zero for matching entries to be identified.</li>
         *                       <li>This method will pass the <code>identifier</code> and queue entry object as the
         *                           first and second arguments respectively to the comparator.</li>
         *                   </ul>
         *                   </p>
         * 
         * @return An <code>Array</code> containing all the entries removed, or an empty <code>Array</code> if
         *         there were no entries in the queue matching the criteria provided.
         * 
         * @throws IllegalOperationError if no default comparator has been specified and <code>comparator</code> is <code>null</code>.
         */
        public function drainToValue(indentifier : Object, comparator : IComparator = null) : Array {       
            var returnArray : Array       = new Array();
            var curNode     : ListNode  = _queue.firstNode;
            
            if (comparator == null){
                if (_defaultComparator == null)
                    throw new IllegalOperationError("A comparator must be specified (there is no default comparator for this queue.)");
                comparator = _defaultComparator;
            }
            while (true) {
                if (comparator.compare(indentifier, curNode.data as Object) == 0)
                    return returnArray;
                curNode  = curNode.next;
                returnArray.push(_queue.first);
                _queue.removeFirstNode();
                if (curNode == _queue.lastNode || curNode.next == null)
                    break;              
            }
            return returnArray;
        }
        
        /**
         * Returns a reference to the oldest entry in the queue.
         * 
         * @return A reference to the oldest entry in the queue. 
         */
        public function peek() : * {
            return _queue.first;
        }
        
        /**
         * Removes all entries in the queue.
         */
        public function clear() : void {
            _queue = new LinkedList();
        }
        
        /**
         * Creates a <code>QueueIterator</code> instance that provides access to the contents
         * of the queue.
         * 
         * @param forward <code>true</code> to iterate the entries of the list forward starting with
         *                the oldest, <code>false</code> to iterate the entries backwards starting with
         *                the tail.
         * @param startIndex The starting position in the list.  If this parameter is a negative
         *                   number, the first element of the list (the head if a forward iterator
         *                   and the tail for a reverse iterator) is used by default.
         * 
         * @return A <code>QueueIterator</code> instance that provides access to the contents
         *         of the queue.
         */
        public function getIterator(forward : Boolean = true, startIndex : int = -1) : QueueIterator {
            
            return new QueueIterator(_queue, forward, startIndex);
        }       
    } 
}

