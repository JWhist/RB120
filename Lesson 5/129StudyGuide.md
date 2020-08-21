## Classes and Objects
#### Classes
Classes describe the attributes and behaviors of the objects that they create.
  Classes are defined using the `class` keyword followed by the class name, closed out with `end`.

  ```
  class Example
  end
  ```

#### Objects
Objects in Ruby are anything that can hold a value, and are created by their classes. Objects are created by calling the `new` method on the class.  Objects contain *state*, which are the values of the attributes at any given moment, and *behavior*, which are the public methods available to the object as defined by its class.

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
