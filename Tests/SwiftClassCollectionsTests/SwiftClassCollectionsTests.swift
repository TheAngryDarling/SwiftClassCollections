import XCTest
@testable import SwiftClassCollections



class SwiftClassCollectionsTests: XCTestCase {
    
    private let persons: [String] = {
        var rtn: [String] = []
        for c in UnicodeScalar("A").value...UnicodeScalar("Z").value {
            rtn.append("Person \(UnicodeScalar(c)!)")
        }
        return rtn
    }()
    
    
    
    
    
    private let randomNumbers: [Int] = {
        // Taken from https://stackoverflow.com/questions/41035180/swift-arc4random-uniformmax-in-linux for quick random number generator
        func getRandomNum() -> Int {
            #if os(Linux)
            return Int(random() % Int(UInt32.max)) + Int(UInt32.min)
            #else
            return Int(arc4random_uniform(UInt32.max) + UInt32.min)
            #endif
        }
        
        #if os(Linux)
        srandom(UInt32(time(nil)))
        #endif
        
        var rtn: [Int] = []
        for _ in 0..<26 {
            let v = getRandomNum()
            rtn.append(v)
        }
        return rtn
    }()
    
    private var _lastIndex: [String: Int] = [:]
    
    private func getLastIndex<A>(ofType type: A.Type) -> Int {
        guard let r = _lastIndex[String(describing: A.self)] else { return 0 }
        return r
    }
    
    private func setLastIndex<A>(_ index: Int, ofType type: A.Type) {
        _lastIndex[String(describing: A.self)] = index
    }
    
    
    func createTestDictionary<D>(ofType type: D.Type = D.self) -> D where D: SDictionary, D.Key == String, D.Value == Int {
        var ary = [(String, Int)]()
        let startIndex = getLastIndex(ofType: D.self)
        for i in startIndex..<(startIndex+2) {
            ary.append((persons[i], randomNumbers[i]))
        }
        setLastIndex((startIndex+2), ofType: D.self)
        //ary.append(("Person A", 135))
        //ary.append(("Person B", 9))
        return D(uniqueKeysWithValues: ary)
    }
    
    func createTestArray<A>(ofType type: A.Type = A.self) -> A where A: SArray, A.Element == String {
        var ary = [String] ()
        let startIndex = getLastIndex(ofType: A.self)
        for i in startIndex..<(startIndex+2) {
            ary.append(persons[i])
        }
        setLastIndex((startIndex+2), ofType: A.self)
        //ary.append("Person A")
        //ary.append("Person B")
        return A(ary)
    }
    
    func testGenericDictionaryIterator<D>(_ dictionary: D) where D: SDictionary {
        for (k,v) in dictionary {
            #if verbose
            print("\(k): \(v)")
            #endif
        }
    }
    
    func testGenericArrayIterator<A>(_ array: A) where A: SArray {
        for v in array {
            #if verbose
            print(v)
            #endif
        }
    }
    
    func testDictionaryOrdering() {
        
        
        let expectedOrderedResults = "[\"\(persons[0])\": \(randomNumbers[0]), \"\(persons[1])\": \(randomNumbers[1])]"
        
        let orgDict = createTestDictionary(ofType: Dictionary<String, Int>.self) //Dictionary<String, Int>()
        let clsDict = createTestDictionary(ofType: SCDictionary<String, Int>.self) //SCDictionary<String, Int>()
        let orderedClsDict = createTestDictionary(ofType: SCArrayOrderedDictionary<String, Int>.self) //SCArrayOrderedDictionary<String, Int>()
        
        
        let orgDictStrOrder = "\(orgDict)"
        let clsDictStrOrder = "\(clsDict)"
        let orderedClsDictStrOrder = "\(orderedClsDict)"
        
        #if verbose
        print("Swift Dictionary Order: (Order is not guarenteed)")
        print("\t" + orgDictStrOrder)
        print("SCDictionary Order: (Order is not guarenteed, because storage is a Swift Dictionary)")
        print("\t" + clsDictStrOrder)
        print("SCOrderedDictionary Order: (Expected to be ordered by index (first in first out))")
        print("\t" + orderedClsDictStrOrder)
        #endif
        
        XCTAssert(orderedClsDictStrOrder == expectedOrderedResults, "Ordered results \(orderedClsDictStrOrder) does not match expected '\(expectedOrderedResults)'")
        
        
    }
    
    func testOrderedDictionaryIterator() {
        let orderedClsDict = createTestDictionary(ofType: SCArrayOrderedDictionary<String, Int>.self) //SCArrayOrderedDictionary<String, Int>()
        
        var idx = orderedClsDict.startIndex
        for (k,v) in orderedClsDict {
            #if verbose
            print("\(k) - \(v)")
            #endif
            XCTAssert(k == orderedClsDict[idx].key, "Invalid order.  Expected '\(orderedClsDict[idx].key)' got '\(k)'")
            idx = orderedClsDict.index(after: idx)
        }
        
    }
    
    func testSCArrayClassFielsForMatch() {
        let objectType: String = "Array"
        var matchingObject: Array<String> = createTestArray(ofType: Array<String>.self)
        var customObject: SCArray<String> = createTestArray(ofType: SCArray<String>.self)
        
        //Collection Properties
        XCTAssert(customObject.isEmpty == matchingObject.isEmpty && customObject.isEmpty == false, "\(objectType) isEmpty do not match or returned true")
        XCTAssert(customObject.count == matchingObject.count, "\(objectType) count do not match")
        XCTAssert(customObject.capacity == matchingObject.capacity, "\(objectType) capacity do not match")
        XCTAssert(customObject.first == matchingObject.first, "\(objectType) firsts do not match")
        XCTAssert(customObject.last == matchingObject.last, "\(objectType) lasts do not match")
        
        XCTAssert(customObject[customObject.startIndex] == matchingObject[matchingObject.startIndex], "\(objectType) index subscripts do not match")
        XCTAssert(customObject[0..<1] == matchingObject[0..<1], "\(objectType) range subscripts do not match")
        #if swift(>=4.2)
        _ = customObject.randomElement()
        #endif
        
        
        customObject.append("Person C")
        matchingObject.append("Person C")
        XCTAssert(customObject == matchingObject, "\(objectType)s do not match after appending new item")
        customObject.insert("Person A1", at: 1)
        matchingObject.insert("Person A1", at: 1)
        XCTAssert(customObject == matchingObject, "\(objectType)s do not match after inserting new item")
        customObject.replaceSubrange(1..<4, with: ["Person B", "Person C", "Person D"])
        matchingObject.replaceSubrange(1..<4, with: ["Person B", "Person C", "Person D"])
        XCTAssert(customObject == matchingObject, "\(objectType)s do not match after replace range")
        customObject.reserveCapacity(10)
        matchingObject.reserveCapacity(10)
        customObject.append(contentsOf: ["Person E", "Person F", "Person G"])
        matchingObject.append(contentsOf: ["Person E", "Person F", "Person G"])
        XCTAssert(customObject == matchingObject, "\(objectType)s do not match after appending sequence")
        var customObjectR = customObject.remove(at: 0)
        var mcustomObjectR = matchingObject.remove(at: 0)
        XCTAssert(customObject == matchingObject, "\(objectType)s do not match after removing object")
        XCTAssert(customObjectR == mcustomObjectR, "Removed objects from \(objectType.lowercased()) do not match")
        customObjectR = customObject.removeFirst() // Why did this require me to make customObject a var when its a class? mutable fiels are only for structures I though.
        mcustomObjectR = matchingObject.removeFirst()
        XCTAssert(customObject == matchingObject, "\(objectType)s do not match after removing first object")
        XCTAssert(customObjectR == mcustomObjectR, "Removed objects from \(objectType.lowercased()) do not match")
        customObjectR = customObject.removeLast() // Why did this require me to make customObject a var when its a class? mutable fiels are only for structures I though.
        mcustomObjectR = matchingObject.removeLast()
        XCTAssert(customObject == matchingObject, "\(objectType)s do not match after removing last object")
        XCTAssert(customObjectR == mcustomObjectR, "Removed objects from \(objectType.lowercased()) do not match")
        customObject.removeSubrange(0..<1)
        matchingObject.removeSubrange(0..<1)
        XCTAssert(customObject == matchingObject, "\(objectType)s do not match after removing range")
        #if swift(>=4.2)
        XCTAssert(customObject.popLast() == matchingObject.popLast(), "popLast objects from \(objectType.lowercased()) do not match")
        #endif
        XCTAssert(customObject == matchingObject, "\(objectType)s do not match after popLast range")
        
        // print(customObject) // At this point ["Person D", "Person E"]
        
        let filterContainsFunc = { (_ val: String) -> Bool in
            return val == "Person E"
        }
        
        
        XCTAssert(customObject.contains(where: filterContainsFunc) == matchingObject.contains(where: filterContainsFunc), "contains(where:) do not match")
        XCTAssert(customObject.contains("Person D") == matchingObject.contains("Person D"), "contains() do not match")
        
        #if swift(>=4.2)
        XCTAssert(customObject.allSatisfy({(String) -> Bool in return true}) == matchingObject.allSatisfy({(String) -> Bool in return true}), "allSatisfy({true}) do not match")
        XCTAssert(customObject.allSatisfy({(String) -> Bool in return false}) == matchingObject.allSatisfy({(String) -> Bool in return false}), "allSatisfy({false}) do not match")
        XCTAssert(customObject.allSatisfy({(String) -> Bool in return true}) != matchingObject.allSatisfy({(String) -> Bool in return false}), "allSatisfy({true/false}) match when they should not")
        
        
        
        XCTAssert(customObject.first(where: filterContainsFunc) == matchingObject.first(where: filterContainsFunc), "first(where:) do not match")
        XCTAssert(customObject.firstIndex(of: "Person D") == matchingObject.firstIndex(of: "Person D"), "firstIndex() do not match")
        XCTAssert(customObject.firstIndex(where: filterContainsFunc) == matchingObject.firstIndex(where: filterContainsFunc), "firstIndex(where:) do not match")
        
        XCTAssert(customObject.last(where: filterContainsFunc) == matchingObject.last(where: filterContainsFunc), "last(where:) do not match")
        XCTAssert(customObject.lastIndex(of: "Person D") == matchingObject.lastIndex(of: "Person D"), "lastIndex() do not match")
        XCTAssert(customObject.lastIndex(where: filterContainsFunc) == matchingObject.lastIndex(where: filterContainsFunc), "lastIndex(where:) do not match")
        #endif
        
        XCTAssert(customObject.min() == matchingObject.min(), "min() do not match")
        XCTAssert(customObject.max() == matchingObject.max(), "max() do not match")
        
        XCTAssert(customObject.filter({_ in return true}) == matchingObject.filter({_ in return true}), "filter() do not match")
        
        XCTAssert(customObject.prefix(2) == matchingObject.prefix(2), "prefix() do not match")
        XCTAssert(customObject.prefix(through: 0) == matchingObject.prefix(through: 0), "prefix(through:) do not match")
        XCTAssert(customObject.prefix(upTo: 2) == matchingObject.prefix(upTo: 2), "prefix(upTo:) do not match")
        XCTAssert(customObject.prefix(while: filterContainsFunc) == matchingObject.prefix(while: filterContainsFunc), "prefix(while:) do not match")
        #if verbose
        print(customObject)
        print(matchingObject)
        #endif
        
        XCTAssert(customObject.suffix(1) == matchingObject.suffix(1), "suffix() do not match")
        XCTAssert(customObject.suffix(from: 1) == matchingObject.suffix(from: 1), "suffix(from:) do not match")
        
        
        // Last test because it removes everything
        customObject.removeAll(keepingCapacity: true)
        matchingObject.removeAll(keepingCapacity: true)
        XCTAssert(customObject == matchingObject, "\(objectType)s do not match after removing all")
        XCTAssert(customObject.capacity == matchingObject.capacity, "\(objectType) capacities do not match: sc(\(customObject.capacity)), swift(\(matchingObject.capacity))")
        
        testGenericArrayIterator(customObject)
        
        
    }
    
    func testSCDictionaryClassFielsForMatch() {
        
        let objectType: String = "Dictionary"
        
        var matchingObject = createTestDictionary(ofType: Dictionary<String, Int>.self)
        let customObject = createTestDictionary(ofType: SCDictionary<String, Int>.self)
        
        
        //Collection Properties
        XCTAssert(customObject.isEmpty == matchingObject.isEmpty && customObject.isEmpty == false, "\(objectType) isEmpty do not match or returned true")
        XCTAssert(customObject.count == matchingObject.count, "\(objectType) count do not match")
        XCTAssert(customObject.capacity == matchingObject.capacity, "\(objectType) capacity do not match")
        
        // May not match
        // XCTAssert(customObject.first! == matchingObject.first!, "\(objectType) firsts do not match") // Does not match since order will not be the same
        
        // May not match
        //XCTAssert(customObject[customObject.startIndex] == matchingObject[matchingObject.startIndex], "\(objectType) index subscripts do not match")
        #if swift(>=4.2)
        _ = customObject.randomElement()
        #endif
        
        customObject.reserveCapacity(10)
        matchingObject.reserveCapacity(10)
        XCTAssert(customObject.capacity == matchingObject.capacity, "\(objectType) capacities do not match: sc(\(customObject.capacity)), swift(\(matchingObject.capacity))")
        
        let filterContainsFunc = { (_ key: String, _ val: Int) -> Bool in
            return key == "Person E"
        }
        
        XCTAssert(customObject.contains(where: filterContainsFunc) == matchingObject.contains(where: filterContainsFunc), "contains(where:) do not match")
        
        #if swift(>=4.2)
        XCTAssert(customObject.allSatisfy({(String) -> Bool in return true}) == matchingObject.allSatisfy({(String) -> Bool in return true}), "allSatisfy({true}) do not match")
        XCTAssert(customObject.allSatisfy({(String) -> Bool in return false}) == matchingObject.allSatisfy({(String) -> Bool in return false}), "allSatisfy({false}) do not match")
        XCTAssert(customObject.allSatisfy({(String) -> Bool in return true}) != matchingObject.allSatisfy({(String) -> Bool in return false}), "allSatisfy({true/false}) match when they should not")
        
        XCTAssert(customObject.first(where: filterContainsFunc) == matchingObject.first(where: filterContainsFunc), "first(where:) do not match")
        XCTAssert(customObject.firstIndex(where: filterContainsFunc) == matchingObject.firstIndex(where: filterContainsFunc), "firstIndex(where:) do not match")
        #endif
        
        
        #if swift(>=4.2)
        _ = customObject.randomElement()
        #endif
       
        let mergeFnc = { (_ lhs: Int, _ rhs: Int) -> Int in
            return lhs
        }
        
        customObject.merge(createTestDictionary(ofType: SCDictionary<String, Int>.self), uniquingKeysWith: mergeFnc)
        matchingObject.merge(createTestDictionary(ofType: Dictionary<String, Int>.self), uniquingKeysWith: mergeFnc)
        XCTAssert(customObject == matchingObject, "\(objectType)s do not match after merging")
        
        customObject.updateValue(-1, forKey: "Person E")
        matchingObject.updateValue(-1, forKey: "Person E")
        XCTAssert(customObject == matchingObject, "\(objectType)s do not match after updateValue")
        

        // Last test because it removes everything
        customObject.removeAll(keepingCapacity: true)
        matchingObject.removeAll(keepingCapacity: true)
        XCTAssert(customObject == matchingObject, "\(objectType)s do not match after removing all")
        
        
        testGenericDictionaryIterator(customObject)
    }
    
    func testSCArrayOrderedDictionaryClassFielsForMatch() {
        
        let objectType: String = "Dictionary"
        
        var matchingObject = createTestDictionary(ofType: Dictionary<String, Int>.self)
        let customObject = createTestDictionary(ofType: SCArrayOrderedDictionary<String, Int>.self)
        
        //Collection Properties
        XCTAssert(customObject.isEmpty == matchingObject.isEmpty && customObject.isEmpty == false, "\(objectType) isEmpty do not match or returned true")
        XCTAssert(customObject.count == matchingObject.count, "\(objectType) count do not match")
        XCTAssert(customObject.capacity == matchingObject.capacity, "\(objectType) capacities do not match: sc(\(customObject.capacity)), swift(\(matchingObject.capacity))") // Default capacities for Dictioanry and Arrays are not the same
        
        XCTAssert(customObject.first != nil, "\(type(of: customObject)) first was nil")
        
        XCTAssert(customObject[customObject.startIndex].key == persons[0], "\(type(of: customObject)) index subscripts key does not match expected first key '\(persons[0])'")
        #if swift(>=4.2)
        _ = customObject.randomElement()
        #endif
        
        customObject.reserveCapacity(10)
        matchingObject.reserveCapacity(10)
        
        XCTAssert(customObject.capacity == matchingObject.capacity, "\(objectType) capacities do not match: sc(\(customObject.capacity)), swift(\(matchingObject.capacity))")
        
        let filterContainsFunc = { (_ key: String, _ val: Int) -> Bool in
            return key == "Person E"
        }
        
        XCTAssert(customObject.contains(where: filterContainsFunc) == matchingObject.contains(where: filterContainsFunc), "contains(where:) do not match")
        
        #if swift(>=4.2)
        XCTAssert(customObject.allSatisfy({(String) -> Bool in return true}) == matchingObject.allSatisfy({(String) -> Bool in return true}), "allSatisfy({true}) do not match")
        XCTAssert(customObject.allSatisfy({(String) -> Bool in return false}) == matchingObject.allSatisfy({(String) -> Bool in return false}), "allSatisfy({false}) do not match")
        XCTAssert(customObject.allSatisfy({(String) -> Bool in return true}) != matchingObject.allSatisfy({(String) -> Bool in return false}), "allSatisfy({true/false}) match when they should not")
        
        XCTAssert(customObject.first(where: filterContainsFunc) == matchingObject.first(where: filterContainsFunc), "first(where:) do not match")
        XCTAssert(customObject.firstIndex(where: filterContainsFunc) == matchingObject.firstIndex(where: filterContainsFunc), "firstIndex(where:) do not match")
        #endif
        
        
        #if swift(>=4.2)
        _ = customObject.randomElement()
        #endif
        
        let mergeFnc = { (_ lhs: Int, _ rhs: Int) -> Int in
            return lhs
        }
        
        customObject.merge(createTestDictionary(ofType: SCArrayOrderedDictionary<String, Int>.self), uniquingKeysWith: mergeFnc)
        matchingObject.merge(createTestDictionary(ofType: Dictionary<String, Int>.self), uniquingKeysWith: mergeFnc)
        XCTAssert(customObject == matchingObject, "\(objectType)s do not match after merging")
        
        customObject.updateValue(-1, forKey: "Person E")
        matchingObject.updateValue(-1, forKey: "Person E")
        XCTAssert(customObject == matchingObject, "\(objectType)s do not match after updateValue")
        
        
        // Last test because it removes everything
        customObject.removeAll(keepingCapacity: true)
        matchingObject.removeAll(keepingCapacity: true)
        XCTAssert(customObject == matchingObject, "\(objectType)s do not match after removing all")
        
        
        testGenericDictionaryIterator(customObject)
    }
    
    
    
#if swift(>=4.1)
    func testOrderedArrayCoding() {
        
        let dict = createTestDictionary(ofType: SCArrayOrderedDictionary<String, Int>.self)
        #if verbose
        print(dict)
        #endif
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let encodedData = try encoder.encode(dict)
            //Print json string here
            let str = String(data: encodedData, encoding: .utf8)
            #if verbose
            print(str!)
            #endif
            let decoder = JSONDecoder()
            
            do {
                let decodedDict = (try decoder.decode(SCArrayOrderedDictionary<String, Int>.self, from: encodedData))
                #if verbose
                print(decodedDict)
                #endif
                // Since when using the JSONDecoder there is no guarentee on the order returned since it uses regular Swift Dictionaries, we will use the custom ~= operator to compare.  It checks to see if all elements are there even if they are not in the same order
                XCTAssert(decodedDict ~= dict, "Decoded dictionary \(decodedDict) does not match origional dictionary \(dict)")
                
            } catch {
                XCTFail("Failed to decode ordered dictionary: \(error)")
            }
            
            
        } catch {
            XCTFail("Failed to encode ordered dictionary: \(error)")
        }
    }
#endif
    
    private static func buildTestList() -> [(String, (SwiftClassCollectionsTests) -> () -> () )] {
        #if swift(>=5.0)
        print("Working with: Swift >= 5.0")
        #elseif swift(>=4.2)
        print("Working with: Swift 4.2")
        #elseif swift(>=4.1)
        print("Working with: Swift 4.1")
        #elseif swift(>=4.0)
        print("Working with: Swift 4.0")
        #else
        print("Unsupported Swift version")
        #endif
        
        var rtn = [(String, (SwiftClassCollectionsTests) -> () -> () )]()
        
        rtn.append(("testDictionaryOrdering", testDictionaryOrdering))
        rtn.append(("testOrderedDictionaryIterator", testOrderedDictionaryIterator))
        rtn.append(("testSCArrayClassFielsForMatch", testSCArrayClassFielsForMatch))
        rtn.append(("testSCDictionaryClassFielsForMatch", testSCDictionaryClassFielsForMatch))
        rtn.append(("testSCArrayOrderedDictionaryClassFielsForMatch", testSCArrayOrderedDictionaryClassFielsForMatch))
        
        #if swift(>=4.1)
        rtn.append(("testOrderedArrayCoding", SwiftClassCollectionsTests.testOrderedArrayCoding))
        #endif
        
        return rtn
    }
    /*static var allTests = [
        ("testDictionaryOrdering", testDictionaryOrdering),
        ("testOrderedDictionaryIterator", testOrderedDictionaryIterator)
    ]*/
    static var allTests = { return buildTestList() }()

    
}


