<p align="center">
    <img src="osckit-icon.svg" width="256" align="middle" alt=“CoreOSC”/>
</p>

# CoreOSC
The CoreOSC package contains common infrastructural code for your apps to communicate among computers, sound synthesizers, and other multimedia devices via [OSC](http://opensoundcontrol.org/README.html).

## To Do
- Enhance the regexes for all address objects: `OSCAddressPattern`, `OSCAddress`, `OSCRefractingAddress`, `OSCFilterAddress`.
- Enhance the `evaluate(:String)` function for all address objects: `OSCAddressPattern`, `OSCAddress`, `OSCRefractingAddress`, `OSCFilterAddress`.
- Develop an API for invoking `OSCMessage`'s within `OSCBundle`'s and respecting the bundles `OSCTimeTag`.
- Research and potentially implement [OSCQuery](https://github.com/Vidvox/OSCQueryProposal).
- Explore mapping `OSCMethod`'s within the `OSCAddressSpace` to a tree like data structure.

## Authors

**Sammy Smallman** - *Initial Work* - [SammySmallman](https://github.com/sammysmallman)

See also the list of [contributors](https://github.com/sammysmallman/CoreOSC/graphs/contributors) who participated in this project.
