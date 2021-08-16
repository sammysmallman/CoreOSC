<p align="center">
    <img src="osckit-icon.svg" width="256" align="middle" alt=“CoreOSC”/>
</p>

# CoreOSC
The CoreOSC package contains common infrastructural code for your apps to communicate among computers, sound synthesizers, and other multimedia devices via [OSC](http://opensoundcontrol.org/README.html).

## Architecture

### Addresses
An address has a similar syntax to a URL and begins with the character "/", followed by the names of all the containers, in order, along the path from the root of the tree to the method, separated by forward slash characters, followed by the name of the method. All types of addresses found in CoreOSC contain ASCII characters only, as specified in [OSC 1.0](http://opensoundcontrol.org/spec-1_0.html).

#### OSC Address Pattern
An address pattern is an address to a potential destination of one ore more methods hosted by an "OSC Server". A number of wildcard characters, such as "*", can be used to allow for a single address pattern to invoke multiple methods.
```swift
    let addressPattern = try? OSCAddressPattern("/core/osc/*")
```
Initialization of an `OSCAddressPattern` will `throw` if the format is incorrect or invalid characters are found in the given `String`.

A `String` can be evaluated to verify whether it is a valid address pattern by using the following:
```swift
    let valid: Bool = OSCAddressPattern.evaluate("/core/osc/*")    
```
#### OSC Address
An address is the path to a method hosted by an "OSC Server". No wildcard characters are allowed as this address signifies the endpoint of an `OSCMesage` and the full path a message traverses to invoke the method associated with it.
```swift
    let address = try? OSCAddress("/core/osc/method")
```
Initialization of an `OSCAddress` will `throw` if the format is incorrect or invalid characters are found in the given `String`.

A `String` can be evaluated to verify whether it is a valid address by using the following:
```swift
    let valid: Bool = OSCAddress.evaluate("/core/osc/method")    
```
### Messages
An `OSCMessage` is a packet formed of an `OSCAddressPattern` that directs it towards one or more methods hosted by an "OSC Server" and arguments that can be used when invoking the methods. CoreOSC implements all required argument types as specified in [OSC 1.1](http://opensoundcontrol.org/files/2009-NIME-OSC-1.1.pdf).
#### Initialization with an `OSCAddressPattern`:
```swift

    let addressPattern = try! OSCAddressPattern("/core/osc/*")
    let message = OSCMessage(with: addressPattern,
                             arguments: [Int32(1),
                                         Float32(3.142),
                                         "Core OSC",
                                         OSCTimeTag.immediate,
                                         true,
                                         false,
                                         Data([0x01, 0x01]),
                                         OSCArgument.nil,
                                         OSCArgument.impulse])
```
#### Initialization with a raw address pattern `String`:
```swift
    let message = try? OSCMessage(with: "/core/osc/*",
                                  arguments: [Int32(1),
                                              Float32(3.142),
                                              "Core OSC",
                                              OSCTimeTag.immediate,
                                              true,
                                              false,
                                              Data([0x01, 0x01]),
                                              OSCArgument.nil,
                                              OSCArgument.impulse])
```
Initialization of an `OSCMessage` will `throw` if the format is incorrect or invalid characters are found in the given `String` address pattern.

### Bundles
An `OSCBundle` is a container for messages, but also other bundles and allows for the invokation of multiple messages atomically as well scheduling them to be invoked at some point in the future. For further information regarding the temporal semantics of bundles and their associated `OSCTimeTag`s, please see [OSC 1.0](http://opensoundcontrol.org/spec-1_0.html#timetags).
```swift
    let message1 = try! OSCMessage(with: "/core/osc/1")
    let message2 = try! OSCMessage(with: "/core/osc/2")
    let message3 = try! OSCMessage(with: "/core/osc/3")
    
    let bundle = OSCBundle([message1, message2, message3], 
                           timetag: .immediate)
```

### Address Spaces
An `OSCAddressSpace` is a set of methods hosted by an "OSC Server" that can be invoked by one or more `OSCMessage`s. Think of it as a container for blocks of code, that can be dispatched when a message is received, with an address pattern that matches against a methods `OSCAddress`.

#### Methods
An `OSCMethod` is a `struct` that encapsulates a closure and the `OSCAddress` needed to invoke it. The idea is that if you wanted to make available control functionality within your application to "OSC Clients" you would begin by creating `OSCMethod`s, adding them to an `OSCAddressSpace` and when an `OSCMessage` is received it would be passed to the address space to potentially invoke a method it contains. 

For example:
```swift
    let method = OSCMethod(with try! OSCAddress("object/coords"), invokedAction { [weak self] message, _ in
        guard message.arguments.count == 2,
              let x = message.argument[0] as? Float32, 
              let y = message.argument[1] as? Float32 else { return }
        print("Received /object/coords, x: \(x), y: \(y)"
        self?.object.x = x
        self?.object.y = y
    })
    
    var addressSpace = OSCAddressSpace(methods: [method])
    
    let message = try! OSCMessage("object/coords", arguments: [Float32(3), Float32(5)])
    addressSpace.invoke(with: message)
                                                     
    print(object.x) // 3
    print(object.y) // 5
```

## Extensions
The following objects are not part of either OSC specification but have been developed after observation of implementations of OSC in the wild and aim to provide help and functionality for you to integrate with them.

### Address Filters
An `OSCAddressFilter` is kind of the reverse of an `OSCAddressSpace`. Where an address space allows for an address pattern to invoke multiple pre defined methods. An address filter allows for a single method to be invoked by multiple loosly formatted address patterns by using a "#" wildcard character and omitting parts from the pattern matching. Think of an address filter as a container for blocks of code, that can be dispatched when a message is received, with an address pattern that matches against a filter methods `OSCFilterAddress`.

#### Filter Methods
An `OSCFilterMethod` is a `struct` that encapsulates a closure and the `OSCFilterAddress` needed to invoke it. The idea is that if you wanted to make available control functionality within your application to "OSC Clients" without the overhead of establishing an address space containing an `OSCAddress` and method for each control functionality you would begin by creating `OSCFilterMethod`s, adding them to an `OSCAddressFilter` and when an `OSCMessage` is received it would be passed to the address filter to potentially invoke a method it contains. 

For example:
```swift
    let method = OSCFilterMethod(with try! OSCAddress("cue/#/fired"), invokedAction { [weak self] message, _ in
        print("Received: \(message.addressPattern.fullPath)")
        self?.logs.append("Cue \(message.addressPattern.parts[1])")
    })
    
    var addressFilter = OSCAddressFilter(methods: [method])
    
    let message1 = try! OSCMessage(with: "cue/1/fired")
    addressFilter.invoke(with: message1)
    
    let message2 = try! OSCMessage(with: "cue/2/fired")
    addressFilter.invoke(with: message2)
    
    let message3 = try OSCMessage(with: "cue/3/fired")
    addressFilter.invoke(with: message3)
    
    print(logs) // ["Cue 1", "Cue 2", "Cue 3"]
```

### Refracting
An `OSCRefractingAddress` can be used to "refract" an `OSCAddressPattern` to something else. The core idea for this object is to allow an "OSC Server" to act as a router, taking an `OSCMessage` from one application and rerouting it to another with modifcations made to the address pattern. Refracting is made possible by using an "#" wildcard character suffixed by a part index number (not 0 indexed). Where a wildcard is used within the refracting address the part will be replaced by the part from the given address pattern. To be succesful at refracting the suffixed index number but be valid with regards to the given address patterns number of parts.
```swift
        let refractingAddress = try? OSCRefractingAddress("/core/#2/#4")
        
        let addressPattern = try? OSCAddressPattern("/core/osc/refracting/test")
        
        let refractedAddress: OSCAddressPattern = try? refractingAddress.refract(address: addressPattern)
        
        print(refractedAddress!.fullPath) // "/core/osc/test"
```

A `String` can be evaluated to verify whether it is a valid refracting address by using the following:
```swift
    let valid: Bool = OSCRefractingAddress.evaluate("/core/#2/#4")    
```

## To Do
- Enhance the regexes for all address objects: `OSCAddressPattern`, `OSCAddress`, `OSCRefractingAddress`, `OSCFilterAddress`.
- Enhance the `evaluate(:String)` function for all address objects: `OSCAddressPattern`, `OSCAddress`, `OSCRefractingAddress`, `OSCFilterAddress`.
- Develop an API for invoking `OSCMessage`s within `OSCBundle`s and respecting the bundles `OSCTimeTag`.
- Research and potentially implement [OSCQuery](https://github.com/Vidvox/OSCQueryProposal).
- Explore mapping `OSCMethod`s within the `OSCAddressSpace` to a tree like data structure.

## Authors

**Sammy Smallman** - *Initial Work* - [SammySmallman](https://github.com/sammysmallman)

See also the list of [contributors](https://github.com/sammysmallman/CoreOSC/graphs/contributors) who participated in this project.
