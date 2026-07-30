# ``CoreOSC``

Construct, encode, parse, match and dispatch Open Sound Control packets.

## Overview

CoreOSC provides the infrastructural value types for communicating among computers, sound synthesisers and other multimedia devices via [OSC](https://opensoundcontrol.stanford.edu): messages, bundles, time tags and every required argument type from [OSC 1.1](https://opensoundcontrol.stanford.edu/files/2009-NIME-OSC-1.1.pdf), together with validated address types, pattern matching, and the address space and filter machinery an OSC server needs to invoke methods from received packets.

The package is transport-agnostic — it produces and consumes the `Data` an OSC packet is on the wire, and leaves the networking to a transport layer of your choosing.

## Topics

### Packets

- ``OSCPacket``
- ``OSCMessage``
- ``OSCBundle``
- ``OSCTimeTag``

### Arguments

- ``OSCArgument``
- ``OSCArgumentProtocol``
- ``OSCArgumentError``

### Addresses

- ``OSCAddressPattern``
- ``OSCAddress``
- ``OSCAddressError``

### Pattern Matching

- ``OSCMatch``
- ``OSCPatternMatch``

### Method Dispatch

- ``OSCAddressSpace``
- ``OSCMethod``
- ``OSCAddressFilter``
- ``OSCFilterMethod``
- ``OSCFilterAddress``

### Stores

- ``OSCStore``
- ``OSCAddressStore``
- ``OSCFilterAddressStore``

### Parsing

- ``OSCParser``
- ``OSCParserError``

### Annotations

- ``OSCAnnotation``

### Refracting

- ``OSCRefractingAddress``

### Package Information

- ``CoreOSC/CoreOSC``
