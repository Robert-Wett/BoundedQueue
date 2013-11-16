package com.bqueue.flex.util {
    /**
     * A comparison function used to order a collection of objects. 
     * 
     * Example of a simple implementation that compares Person objects based on
     * the class property Person.last (last name.)  (This example uses the <code>BoundedQueue</code> object
     * which has several methods requiring a function implementing <code>IComparator</code> as
     * a parameter.):
     * <listing>
public class LastNameComparator implements IComparator {
    
    public function compare(obj1 : Object, obj2 : Object) : int {
        if (!(obj1 is Person) || !(obj2 is Person))
            throw new TypeError("Both arguments must be a Person object");
        
        var person1 : Person = obj1 as Person;    // For convenience...
        var person2 : Person = obj2 as Person;
            
        if (person1.last.toUpperCase() == person2.last.toUpperCase()) 
            return 0;
        if (person1.last.toUpperCase() &lt; person2.last.toUpperCase()) 
            return -1;
        return 1;       
    }
 }
     * </listing> 
     * 
     * Example usage of the above-defined LastNameComparator object:
     * <listing>
var queue : BoundedQueue       = new BoundedQueue(Person, 2);
var cmp   : LastNameComparator = new LastNameComparator();
     
queue.put(new Person("Ted",    "Smith"));
queue.put(new Person("Barney", "Smith"));
var search : Person = new Person("Marshall", "Smith");
var result : Person = queue.find(search, cmp) as Person; 
trace(result.first + " " + result.last); // Traces "Ted Smith" to the console.
     
var results : Array = queue.findAll(search, cmp);
// Trace "Ted Smith" to the console.
trace((results[0] as Person).first + " " + (results[0] as Person).last);
// Trace "Barney Smith" to the console.
trace((results[1] as Person).first + " " + (results[1] as Person).last);
     * </listing>
     */
    public interface IComparator {
        /**
         *  Compares two objects for order.  Returns -1, 0 or 1 if the first argument it less than,
         *  equal to, or greater than the second argument respectively.
         *
         *  @return -1, 0 or 1 if the first argument it less than, equal to, or greater than
         *          the second argument respectively.
         *
         *  @throws TypeError if <code>obj1</code> is not the same type as <code>obj2</code> or either 
         *                    object is not of the type expected by the implementation of this method.
         * 
         */
         function compare(obj1 : Object, obj2 : Object) : int;  
    }
}
