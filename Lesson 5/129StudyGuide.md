## Classes and Objects
#### Classes
Classes describe the attributes and behaviors of the objects that they create.
  Classes are defined using the `class` keyword followed by the class name, closed out with `end`.

  ```
  class Example
  end
  ```

#### Objects
Objects in Ruby are anything that can hold a value, and are created by their classes. Objects are created by calling the `new` method on the class.
##### States and Behaviors
Objects contain *state*, which are the values of the attributes, which are represented by instance variables, at any given moment, and *behavior*, which are the public methods available to the object as defined by its class.  

`new_object = Example.new`

It is important to note here that `new_object` is NOT an object, it is a variable, and as we learned in RB101, a variable is a pointer.  In this case, `new_object` is a pointer to the object returned by the `Example.new` method.

## Using attr_* to create getter and setter methods
#### What does attr_* do?

attr_* methods create getter/setter/both methods.  Instance variables are not initialized, and when referenced will return nil until assigned unlike locally scoped variables which will throw an `undefined local variable or method` error if referenced prior to assignment.  

`attr_reader :value` is the same as: 

```
def value
  @value
end
```

and likewise, `attr_writer :value` is the same as:

```
def value=(param)
  @value = param
end
```

`attr_accessor` will create both of these methods simultaneously.  

#### Public vs Private/Protected attr_*
*If the attr_\* method is called below a private or protected keyword, those methods will also be private/protected as well.*

## How to call setters and getters
Getters and setters are instance methods, and are called by objects of the class that defines them.  
##### Within the class
Public getters and setters can be called within the class by using either the method name along, or in combination with the `self` keyword.  For example:

```
class Example
  attr_accessor :value

  def change_value(new_value)
    self.value = new_value
  end

  def double_value
    2 * value
  end
end
```

When calling a setter method within the class, you must use the `self` keyword before the method invocation to avoid confusion with local variable assignment.

##### Outside the class
Outside the class, getters and setters are invoked on the object of the respective class by appending the method to the objects pointer variable.  For example:

```
class Example
  attr_accessor :value
end

chewy = Example.new
puts chewy.value
chewy.value = new_value
```

*Appending a space between the method name and = sign is syntactical sugar for the Ruby language, and represents the syntax `chewy.value=(new_value)`.*  This can only be done with public attr_* methods.

## Instance Methods vs Class Methods
Example:
```
class Toyota
  @@revenue = 0

  def initialize(model, year, cost)
    @model = model
    @year = year
    @@revenue += cost
  end

  def what_am_i
    puts "I am a #{@year} #{@model}."
  end

  def self.factory_revenue
    @@revenue
  end
end
```

In this case, we have a Toyota factory represented by class `Toyota`.  Every time the factory builds and sells a car, a `Toyota` object is created.  When a new car is created, it will have its own `@year` and `@model` attributes, and at the same time the factory will record an increase in `@@revenue`.
#### Instance Methods
Instance methods are available only to objects of the class and its subclasses.  These methods are created using `def...end` syntax that we are familiar with.  A `self` keyword used *within* an instance method will reference the calling object of the method.

The instance method `what_am_i` will return a different result for each car object, dependent upon its make and model, because each time the `what_am_i` method is invoked, it is invoked on a different object (with a differing *state*).
```
camry = Toyota.new('Camry', 2014, 18000)
taurus = Toyota.new('Taurus', 2002, 2500)
camry.what_am_i
-->I am a 2014 Camry
taurus.what_am_i
-->I am a 2002 Taurus
```

#### Class Methods
Class methods are available only to the class itself.  These methods are created using the `def self.<method_name>...end` syntax.  This time the keyword `self` will reference the class.

The class method `self.factory_revenue` can only be called by the class itself; for instance, `Toyota.factory_revenue`.  If a `Toyota` object tries to call this method, it will throw an `undefined method` error.

```
Toyota.factory_revenue
-->20500
camry.factory_revenue
NoMethodError (undefined method `factory_revenue' for #<Toyota:0x00005629fefccaf0 @make="Camry", @model=2014>)
```

#### Referencing and setting instance variables vs using getters and setters
Best practice is to avoid directly referencing the instance variable in your instance methods, with the exception of the `initialize` method.  Instance variables are referenced using the `@` symbol, ie `@var`.  
When using setter method, the `self` keyword must be appended to the method call to distinguish between the setter method call and a local variable assignment.  Careful attention must also be paid to syntactical sugar such as `+=` method, as this can translate to `var=(var + new_value)`, and this may cause conflicts if the getter is private/undefined or multiple objects are involved.

Outside of the class, public vs private/protected nature of methods must be taken into consideration.

#### Class Inheritance
Methods defined in a class are available to its child classes.  Child classes may define their own methods of the same name in order to overwrite those of their parent class.  This is known as *Duck typing*, a form of inheritance polymorphism in which methods of the same name are processed in a different way to achieve an expected result.

Module methods are inherited between the object and its parent class.

## Encapsulation
Encapsulation is the concept of hiding away code so that it cannot be accessed outside of the class.  This is done through use of private methods primarily, in order to 'lock away' the implentation details of a method, such that the user only has to call a method and get an expected result without being concerned about how that result came to be calculated.  
Modules are also a form of encapsulation, in that they can encapsulate groups of methods into a namespace to prevent clashing with other files, and secure that code in a separate location from the main code it may be inserted in.  An example of this is `pry`.  This is a module we include to help debug our programs.  We know how to use it, but we do not necessarily know or see the code in the module because it is stored separately from our main working code.

## Polymorphism
Polymorphism is the ability to have objects of different classes call the same method and achieve similar expected results through differing implementation.

```
class Snake
  def move
    slither
  end
end

class Person
  def move
    walk
  end
end
```

Here we have a `Snake` object and a `Person` object, each can be called upon to move, however the implementation of the movement is completely different for each object.  Nevertheless, they could be grouped together if needed and expected to `move` as needed, for instance:

`[Snake.new, Person.new].each(&:move)`

#### Modules
Modules are a grouping of methods that can be inserted as needed across classes that are not on the same branches of the inheritance tree.  This allows us to DRY up our code by avoiding repetition in classes that wouldn't otherwise be able to inherit from each other.  
Modules can also be used to namespace, or bundle classes under an umbrella, to avoid having name clashing issues with other code in system or gem files that may have methods of the same names as our code.

```
module Poison
  def make_sick
    "puking my guts out"
  end
end

class Plant; end
class Animal; end
class PoisonIvy < Plant
  include Poison
end
class Snake < Animal
  include Poison
end
```

#### Method lookup path
If a local variable or method cannot be found in the current scope of the operation, ruby will look up the method lookup path to try to find a match prior to throwing an error.  The standard lookup path is:
`.method->Module->Class->SuperClass->Object->Kernel->BasicObject`

#### Self
The `self` keyword references a different object depending on the scope it is called in.  In the class, outside of instance method definitions, it will reflect the class.  Within instance method definitions, `self` will refer to the calling object of the method.
`self` is used when defining class methods, and when implicitly referencing the caller on instance methods (ie, setter methods).  We can chain methods to 
`self` to access the calling object as well, ie `self.class` will return the class of the object it is called on. 

#### Fake Operators and Equality
Comparison and equality in Ruby are methods.  `<, <=, ==, >=, >` methods are found in the Comparable module.  They can either be individually defined in our classes, or if we want to include the whole group, we can simply define a `<=>` method while including the Comparable module, as this is the foundation it uses in the other methods listed above.

## The `===` and `eql?` methods
The `===` method is *not* a part of the Comparable module, and is used to determine a "is a type of" relationship.  This will return true if the argument on the right side of the operator is a 'type of' object on the left side of the operator.
The `===` is used by `case` statements to determine equality in choosing the branch to execute.

The `eql?` method returns a boolean based on whether the objects have the same value and are of the same class.

#### Truthiness
Everything has an implicitly truthy value except for `false` and `nil`.