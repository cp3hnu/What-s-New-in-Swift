/*:
[< Previous](@previous)           [Home](Introduction)           [Next >](@next)

 ## Dynamic Member Lookup

Apply this attribute to a class, structure, enumeration, or protocol to enable members to be looked up by name at runtime. The type must implement a `subscript(dynamicMemberLookup:)` subscript

In an explicit member expression, if there isn’t a corresponding declaration for the named member, the expression is understood as a call to the type’s `subscript(dynamicMemberLookup:)` subscript, passing information about the member as the argument. The subscript can accept a parameter that’s either a key path or a member name; if you implement both subscripts, the subscript that takes key path argument is used.
 
Dynamic member lookup by member name can be used to create a wrapper type around data that can’t be type checked at compile time, such as when bridging data from other languages into Swift. For example:
*/

import Foundation

@dynamicMemberLookup
struct DynamicStruct {
    let dictionary = ["someDynamicMember": 325,
                      "someOtherMember": 787]
    subscript(dynamicMember member: String) -> Int {
        return dictionary[member] ?? 1054
    }
}
let s = DynamicStruct()

// Use dynamic member lookup.
let dynamic = s.someDynamicMember
print(dynamic)
// Prints "325"

// Call the underlying subscript directly.
let equivalent = s[dynamicMember: "someDynamicMember"]
print(dynamic == equivalent)
// Prints "true"

/*:
 Dynamic member lookup by key path can be used to implement a wrapper type in a way that supports compile-time type checking. For example:
*/
struct Point { var x, y: Int }

@dynamicMemberLookup
struct PassthroughWrapper<Value> {
    var value: Value
    subscript<T>(dynamicMember member: KeyPath<Value, T>) -> T {
        get { return value[keyPath: member] }
    }
}

let point = Point(x: 381, y: 431)
let wrapper = PassthroughWrapper(value: point)
print(wrapper.x)
/*:
&nbsp;

[< Previous](@previous)           [Home](Introduction)           [Next >](@next)
*/
