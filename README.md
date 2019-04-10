# Swift Class Collections

![macOS](https://img.shields.io/badge/os-macOS-green.svg?style=flat)
![Linux](https://img.shields.io/badge/os-linux-green.svg?style=flat)
![Apache 2](https://img.shields.io/badge/license-Apache2-blue.svg?style=flat)
![Swift](https://img.shields.io/badge/Swift->=4.0-green.svg?style=flat)

Provides Swift equivalents to NSMutableDictionary and NSMutableArray. This allows for swift types to be stored with the collections instead of converting to NSObjects.

These swift collections are classes so they are by reference and can be passed around where as normal collections are passed around by value (copies)

### Classes

* **SCDictionary** -  A class equivalent for the Swift Dictionary structure.  Provides most of the same properties and methods are available
* **SCArray** -  A class equivalent for the Swift Array structure.  Provides most of the same properties and methods are available
* **SCArrayOrderedDictionary** -  A class works as a Dictionary that orders the the objects the same way that Array's do.  Other then that most of the properties and methods are available

### Protocols

* **SAnyArray** - Basic protocol that defines any Array.  Element type does not matter, but can be retrieved by a property.  Good for working with objects stored in Any form
* **SAnyDictionary** - Basic protocol that defines any Dictionary.  Key and Value type does not matter, but can be retrieved by properties.  Good for working with objects stored in Any form.
* **SDictionary** -  A protocol that defines all properties and methods used in read-only Swift Dictionary.  This allows for conditional where clauses to work with different types of dictionaries.  
* **SMutableDictionary** -  A protocol that defines all properties and methods used in the Swift Mutable Dictionaries. This allows for conditional where clauses to work with different types of dictionaries.
* **SArray** -  A protocol that defines all properties and methods used in read-only Swift Array.  This allows for conditional where clauses to work with different types of arrays.
* **SMutableArray** -  A protocol that defines all properties and methods used in the Swift Mutable Array. This allows for conditional where clauses to work with different types of arrays.

## Usage

Usage is the same as their counterparts.
Same constructors and most properties and methods are available

```swift
func dictFunc<D>(_ dict: D) where D: SDictionary, D.Key == String, D.Value == Int {
    ...
}

func aryFunc<A>(_ ary: A) where A: SArray, A.Element == String {
    ...
}

struct Struct<D> where D: SDictionary {

}

struct Struct<A> where A: SArray {

}

```

## Authors

* **Tyler Anger** - *Initial work* - [TheAngryDarling](https://github.com/TheAngryDarling)

## License

This project is licensed under Apache License v2.0 - see the [LICENSE.md](LICENSE.md) file for details
