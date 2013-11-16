/*
 *  Tests the BoundedQueue and QueueIterator classes as well as the IComparator and IIterator interfaces.
 *
 *  @author Robert Wettlaufer
 */
package com.bqueue.flex.test {
    
    import com.bqueue.flex.util.BoundedQueue;
    import com.bqueue.flex.error.CapacityError;
    import com.bqueue.flex.util.IComparator;
    import com.bqueue.flex.util.QueueIterator;
    
    import flash.errors.IllegalOperationError;
    
    import org.flexunit.asserts.assertEquals;
    import org.flexunit.asserts.fail;
    
    public class BoundedQueueUnitTest { 
        
        [Test]
        public function boundedQueueTest():void {
            var queue       : BoundedQueue;
            var cmp         : RequestIdComparator = new RequestIdComparator();
            var personCmp   : PersonComparator    = new PersonComparator();
            var lnameCmp    : LastNameComparator  = new LastNameComparator();
            var returnArray : Array;
            var testString  : String;
            var i           : int;

            queue = new BoundedQueue();
            assertEquals(int.MAX_VALUE, queue.capacity);
            assertEquals("Object", queue.classType);
            
            queue = new BoundedQueue(String);
            assertEquals(int.MAX_VALUE, queue.capacity);
            assertEquals("String", queue.classType);
            
            queue = new BoundedQueue(null, 10);
            assertEquals("Object", queue.classType);    
            assertEquals(10, queue.capacity);
            
            queue = new BoundedQueue(String, 0);     
            assertEquals(int.MAX_VALUE, queue.capacity);         
            assertEquals("String", queue.classType);
            
            queue.put(new String("test"));               
            assertEquals(1, queue.size);
            
            testString = queue.peek() as String;
            assertEquals("test", testString);
            assertEquals(1, queue.size);    
            assertEquals("test", queue.take());
            assertEquals(0, queue.size);
            
            queue = new BoundedQueue(String, 5);
            for (i = 0; i < queue.capacity; i++) {
                assertEquals((queue.capacity - i), queue.remainingCapacity); 
                queue.put(new String(i));
            }
            assertEquals(0,   queue.remainingCapacity);
            assertEquals("0", queue.peek());
            
            testString = queue.peek() as String;
            assertEquals("0", testString);
                        
            for (i = 0; i < queue.capacity; i++) {
                assertEquals(queue.take() as String, i.toString());
                assertEquals(queue.size, queue.capacity - (i + 1));
                assertEquals(queue.remainingCapacity, (queue.capacity - queue.size));
            }
            assertEquals(0, queue.size);
            assertEquals(5, queue.remainingCapacity);
            
            /*
             * Adding item to a full list
             */
            for (i = 0; i < queue.capacity; i++) {
                queue.put(new String(i));
            }
            try {
                queue.put(new String);
                fail("Allowed adding an item past the capacity limit");
            }
            catch (e : CapacityError) {
                // Ignore, this is expected.
            }
            catch (e1 : Error) {            
                fail("Expected CapacityError, got " + e1.name + ". StackTrace: " + e1.getStackTrace());
            }
            assertEquals(queue.capacity, queue.size);
            /*
             * Adding in-compatible types to open list
             */
            try {
                assertEquals("String", queue.classType);
                queue.take();
                queue.put(new int(1));
                fail("Expected ArgumentError for adding incompatible type to queue");
            }
            catch (e : ArgumentError) {
                // Ignore, this is expected
            }
            catch (e1 : Error) {
                fail("Expected ArgumentError, got " + e1.name + ". StackTrace: " + e1.getStackTrace());
            }
            
            queue.clear();
            assertEquals(0, queue.size);
            assertEquals(5, queue.remainingCapacity);
            assertEquals(null, queue.take());
            assertEquals(null, queue.peek());
            assertEquals(queue.capacity, queue.remainingCapacity);
            
            /*
             * Adding item to list with in-compatible entry inside
             */
            queue = new BoundedQueue(int, 5);
            queue.put(2);
            assertEquals("int", queue.classType);
            assertEquals(1, queue.size);
            try {
                queue.put("hola");
                fail("Allowed adding incompatible types to the list");
            }
            catch (e : ArgumentError) {
                // Ignore, this is expected
            }
            catch (e1 : Error) {
                fail("Expected ArgumentError, got " + e1.name + ". StackTrace: " + e1.getStackTrace());
            }
            
            /*
             * Testing Comparators/Comparator enabled functions
             */
            queue = new BoundedQueue(Person, 10, personCmp); // Set a default Comparator
            queue.put(new Person("Dre",    "Gunn"));
            queue.put(new Person("Bart",   "Gunn"));
            queue.put(new Person("Ted",    "Gunn"));
            queue.put(new Person("Brett",  "Burger"));
            queue.put(new Person("Brett",  "Thor"));
            queue.put(new Person("Rock",   "Star"));
            queue.put(new Person("Brutus", "McGillacutty"));
            queue.put(new Person("Brutus", "Thor"));
            queue.put(new Person("Jack",   "Fantastic"));
            queue.put(new Person("Jet",    "Grey"));
            assertEquals(10,         queue.capacity);
            assertEquals(queue.size, queue.capacity);
            assertEquals(0,          queue.size - queue.capacity);
            //assertEquals(Person, queue.classType);  expected:<[class Person]> but was:<BoundedQueueTest.as$4::Person>
            
            var person     : Person = new Person("Jet",    "Grey");
            var notInQueue : Person = new Person("Barney", "DarkGrey");
            person     = queue.find(person) as Person;
            notInQueue = queue.find(notInQueue) as Person;
            assertEquals("Jet Grey",  person.first + " " + person.last);
            assertEquals(null, notInQueue);
            
            person = new Person("Dre", "Gunn");         
            returnArray = queue.findAllMatching(person);        
            assertEquals(1, returnArray.length);
            assertEquals("Dre Gunn", (returnArray[0] as Person).first + " " + (returnArray[0] as Person).last);
            
            returnArray = queue.findAllMatching(person, lnameCmp);
            assertEquals(3, returnArray.length);
            assertEquals("Dre Gunn",  (returnArray[0] as Person).first + " " + (returnArray[0] as Person).last);
            assertEquals("Bart Gunn", (returnArray[1] as Person).first + " " + (returnArray[1] as Person).last);
            assertEquals("Ted Gunn",  (returnArray[2] as Person).first + " " + (returnArray[2] as Person).last);
            
            returnArray = queue.removeAllMatching(person);
            assertEquals(1, returnArray.length);
            assertEquals("Dre Gunn", (returnArray[0] as Person).first + " " + (returnArray[0] as Person).last);
            
            person = queue.find(new Person("Bart", "Gunn")) as Person;
            assertEquals("Bart Gunn", person.first + " " + person.last);
            
            person = queue.find(new Person("Ted", "Gunn")) as Person;
            assertEquals("Ted Gunn", person.first + " " + person.last);
            assertEquals(9, queue.size);
            
            returnArray = queue.removeAllMatching(person, lnameCmp);
            assertEquals(2, returnArray.length);
            assertEquals("Bart Gunn", (returnArray[0] as Person).first + " " + (returnArray[0] as Person).last);
            assertEquals("Ted Gunn",  (returnArray[1] as Person).first + " " + (returnArray[1] as Person).last);
            
            person.first = "Jack";
            person.last  = "Fantastic";
            person       = queue.find(person) as Person;
            assertEquals("Jack Fantastic", person.first + " " + person.last);

            queue.drainToValue(person, lnameCmp);
            assertEquals(2, queue.size);
            assertEquals("Jack",      (queue.peek() as Person).first);
            assertEquals("Fantastic", (queue.peek() as Person).last);
            
            queue.take();
            assertEquals(1, queue.size);
            assertEquals("Jet",  (queue.peek() as Person).first);
            assertEquals("Grey", (queue.peek() as Person).last);
            
            queue.drainToSize(0);
            assertEquals(queue.capacity, queue.remainingCapacity);
            
            /*
             * Testing without default Comparator
             */
            queue = new BoundedQueue(Person, 5);  //Pass this queue a default Comparator
            queue.put(new Person("Bart",  "Gunn"));
            queue.put(new Person("Brett", "Thor"));
            queue.put(new Person("Rock",  "Star"));
            queue.put(new Person("Jack",  "Fantastic"));
            queue.put(new Person("Jet",   "Grey"));
            
            assertEquals(5,          queue.capacity);
            assertEquals(queue.size, queue.capacity);
            assertEquals(0,          queue.size - queue.capacity);
            
            person = new Person("Bart", "Gunn");
            try {
                queue.find(person, personCmp); // OK
                queue.find(person);
                fail("Should have thrown an IllegalOperationError for no Comparators");
            }
            catch (e : IllegalOperationError) {
                // Ignore, this is expected
            }
            catch (e1 : Error) {
                fail("Expected IllegalOperationError, got " + e1.name + ". StackTrace: " + e1.getStackTrace());
            }
            queue.drainToValue(new Person("Rock", "Star"), personCmp);
            assertEquals(3, queue.size);
            
            queue.drainToValue(new Person("Theodolphilus", "Grey"), lnameCmp);
            assertEquals(1, queue.size);
            assertEquals("Jet Grey", (queue.peek() as Person).first + " " + (queue.peek() as Person).last);
            
            queue.drainToSize(0);
            assertEquals(queue.capacity, queue.remainingCapacity);

            /*
             * Test to ensure different Comparators result in different returns
             */
            
            var _fnCmp : PersonComparator   = new PersonComparator();           
            var _lnCmp : LastNameComparator = new LastNameComparator();
            var _queue : BoundedQueue       = new BoundedQueue(Person, 2, _lnCmp);
            _queue.put(new Person("Bart", "Gunn"));
            _queue.put(new Person("Ted",  "Gunn"));

            var search : Person = new Person("Bart", "Gunn");
            var result : Person = _queue.find(search, _fnCmp) as Person;
            assertEquals("Bart Gunn", result.first + " " + result.last); 
            
            var results : Array = _queue.findAllMatching(search, _fnCmp);
            assertEquals(1, results.length);
            assertEquals("Bart Gunn", (results[0] as Person).first + " " + (results[0] as Person).last);

            results = _queue.findAllMatching(search, _lnCmp);
            assertEquals(2, results.length);
            assertEquals("Bart Gunn", (results[0] as Person).first + " " + (results[0] as Person).last);
            assertEquals("Ted Gunn", (results[1] as Person).first + " " + (results[1] as Person).last);
            
            results = _queue.findAllMatching(search, _fnCmp);
            assertEquals(1,           (results.length));
            assertEquals("Bart Gunn", (results[0] as Person).first + " " + (results[0] as Person).last);
        
            results = _queue.findAllMatching(person, lnameCmp);
            assertEquals(2, results.length);
            assertEquals("Bart Gunn", (results[0] as Person).first + " " + (results[0] as Person).last);
            assertEquals("Ted Gunn",  (results[1] as Person).first + " " + (results[1] as Person).last);
            
            try {
                results = queue.findAllMatching(person);
                fail("Should have thrown an IllegalOperationError for no Comparators");
            }
            catch (e : IllegalOperationError) {
                // Ignore, this is expected
            }
            catch (e1 : Error) {
                fail("Expected IllegalOperationError, got " + e1.name + ". StackTrace: " + e1.getStackTrace());
            }
            
            queue = new BoundedQueue(uint, 10);
            for (i = 1; i <= queue.capacity; i++) {
                queue.put(i);
            }
        
            assertEquals(10,         queue.capacity);
            assertEquals(queue.size, queue.capacity);
            assertEquals(0,          queue.size - queue.capacity);
            
            var objReturn : Object = queue.remove(1, cmp);
            assertEquals(9, queue.size);
            assertEquals(2, queue.peek());
            assertEquals(1, objReturn as int);
            
            queue.put(2);
            returnArray = queue.findAllMatching(2, cmp);
            assertEquals(2, returnArray.length);
            
            queue.drainToValue(2, cmp);
            assertEquals(10, queue.size);
            assertEquals(2,  queue.peek());
            
            queue.drainToValue(10, cmp);
            assertEquals(2, queue.size);
            assertEquals(10, queue.peek());
            
            queue.drainToValue(2, cmp);
            assertEquals(1, queue.size);
            assertEquals(2, queue.peek());
            
            queue.drainToSize(0);
            assertEquals(10, queue.remainingCapacity);
            assertEquals(0,  queue.size);
            
            for (i = 1; i <= 10; i++) {
                queue.put(i);
            }
            assertEquals(10, queue.size);
            assertEquals(0,  queue.remainingCapacity);          
            
            // Testing out the IBoundedQueueIterator
            queue = new BoundedQueue(uint, 10);
            for (i = 1; i <= queue.capacity; i++) {
                queue.put(i);
            }
            
                    
            var iter : QueueIterator = queue.getIterator(true, 0);
            assertEquals(true, iter.hasNext());
            
            var testInt : int = iter.next() as int;
            assertEquals(1, testInt);
            
            iter = queue.getIterator(false, 9);
            assertEquals(null, iter.data);
            assertEquals(10,  iter.next() as int);
            
            iter = queue.getIterator(false, 9);
            i = 10;
            assertEquals(null, iter.data);
            while (iter.hasNext()) {
                iter.next();
                assertEquals(i, iter.data as int);
                i--;
            }
            
            queue = new BoundedQueue(int, 2);
            for (i = 0; i < queue.capacity; i++)
                queue.put(i);
            iter  = queue.getIterator();
            assertEquals(null, iter.data);
            assertEquals(true, iter.hasNext());
            iter.next();
            assertEquals(0, iter.data);
            iter.next();
            assertEquals(1, iter.data);
        
            try {
                iter.next();
            }
            catch (e : RangeError) {
                iter.resetToFirst();
            }
            catch (e1 : Error) {
                fail("Expected RangeError, got :" + e1.name + ".");
            }
            assertEquals(null, iter.data);
            assertEquals(0, iter.next() as int);
            assertEquals(1, iter.next() as int);
            
            
            queue = new BoundedQueue(String, 4);
            var names1 : Array  = new Array("Abed", "Berry", "Carl", "Dick");
            var names2 : Array  = new Array("Earl", "Fred", "Gary", "Herb");
            var name   : String = "";

            for (i = 0; i < names1.length; i++)
                queue.put(names1[i]);
            iter = queue.getIterator();
            assertEquals(null, iter.data);
            while(iter.hasNext()) {
                iter.next();
                name += (iter.data + ", ");
            }           
            assertEquals("Abed, Berry, Carl, Dick", name.substr(0, name.length - 2));
            assertEquals(false, iter.hasNext());
            iter.resetToFirst();
            assertEquals(true, iter.hasNext());
            
            i = 0;
            while(iter.hasNext()) {
                iter.next();
                iter.data = names2[i];
                i++;
            }
            iter.resetToFirst();
            name = "";
            while(iter.hasNext()) {
                iter.next();
                name += (iter.data + ", ");
            }   
            assertEquals("Earl, Fred, Gary, Herb", name.substr(0, name.length - 2)); 
            iter = queue.getIterator(false);
            name = "";
            while(iter.hasNext()) {
                iter.next();
                name += (iter.data + ", ");
            }
            assertEquals("Herb, Gary, Fred, Earl", name.substr(0, name.length - 2));
            
            names1 = new Array(new Person("Abed", "Hertz"), new Person("Berry", "Lebens"),
                               new Person("Carl", "Cody"),  new Person("Dick",  "Hertz"),
                               new Person("Earl", "Grey"),  new Person("Fred",  "Clause"),
                               new Person("Gary", "Black"), new Person("Herb",  "Black"));
            name   = "";
            queue  = new BoundedQueue(Person, names1.length);
            for (i = 0; i < queue.capacity; i++) {
                queue.put(names1[i]);
            }
            iter   = queue.getIterator(true, 2);
            assertEquals("Carl", (iter.next() as Person).first);
            iter.resetToFirst();
            assertEquals("Abed", (iter.next() as Person).first);
            iter.resetToIndex(5);
            assertEquals("Fred", (iter.next() as Person).first);
            iter.resetToLast();
            assertEquals("Herb", (iter.next() as Person).first);
            iter.resetToFirst();
            assertEquals("Abed", (iter.next() as Person).first);
            
            
            
            iter   = queue.getIterator();
            assertEquals("Abed", (iter.next() as Person).first);
            (iter.data as Person).first = "Rich";
            iter.resetToFirst();
            assertEquals("Rich", (iter.next() as Person).first);
            
            iter = queue.getIterator(true, 7);
            assertEquals(true, iter.hasNext());
            iter.next();
            assertEquals("Herb", (iter.data as Person).first);
            assertEquals(false, iter.hasNext());
            iter = queue.getIterator(false, 7);
            assertEquals(true, iter.hasNext());
            iter.next();
            assertEquals("Herb", (iter.data as Person).first);
            iter.next();
            assertEquals("Gary", (iter.data as Person).first);
            
            iter.resetToFirst();
            assertEquals("Rich", (iter.next() as Person).first);
            iter.resetToLast();
            assertEquals("Herb", (iter.next() as Person).first);
            
            queue = new BoundedQueue(Object, 5);
            iter  = queue.getIterator();
            assertEquals(false, iter.hasNext());
            try {
                iter.next();
            }
            catch (e : RangeError) {
                // Ignore, this is supposed to happen.
            }
            catch (e1 : Error) {
                fail("Expected RangeError, got: " + e1.name);
            }
        }   
    }
}

/*
 * Comparator definitions
 */

import com.investlab.flex.util.IComparator;

class Person {
    public var first : String;
    public var last  : String;
    
    public function Person(fName : String, lName : String) {
        first = fName;
        last  = lName;
    }
}

class PersonComparator implements IComparator { 
    public function PersonComparator() { }
    
    public function compare(obj1 : Object, obj2 : Object) : int {
        var person1 : Person = obj1 as Person;
        var person2 : Person = obj2 as Person;
        
        if (person1.first.toUpperCase() == person2.first.toUpperCase() && 
            person1.last.toUpperCase()  == person2.last.toUpperCase()) 
            return 0;
        if (person1.last < person2.last)
            return -1;
        return 1;
    }
}

class LastNameComparator implements IComparator {
    public function LastNameComparator(){ }
    
    public function compare(obj1 : Object, obj2 : Object) : int {
        var person1 : Person = obj1 as Person;
        var person2 : Person = obj2 as Person;
        
        if (person1.last.toUpperCase() == person2.last.toUpperCase()) 
            return 0;
        if (person1.last.toUpperCase() < person2.last.toUpperCase()) 
            return -1;
        return 1;       
    }
}

class RequestIdComparator implements IComparator { 
    public function RequestIdComparator() { }
    
    public function compare(obj1 : Object, obj2 : Object) : int {
        var req1 : uint = obj1 as int;
        var req2 : uint = obj2 as int;
        
        if (req1 == req2) 
            return 0;
        if (req1 < req2)
            return -1;
        return 1;
    }
}  
