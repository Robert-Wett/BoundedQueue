AS3 Bounded Queue
============

#### An ActionScript 3 Bounded Queue Implementation

Implements a FIFO queue that is optionally capacity bound.  The queue also enforces type safety for all entries by designating the queue object class type in the constructor.  ActionScript 3 does not intrinsically support templates/generics other than the `Vector` class but this convention serves the same purpose for this object.


##### Example usage:

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
