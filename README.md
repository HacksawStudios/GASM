# GASM ECS

Framework agnostic ECS layer.

## What is it?
After trying the excellent Flambe framework, I really became found of that flavor of Entity Component Systems, but since Flambe is not very actively developed any more and lacks a c++ target, I got the idea to create a entity component system which is not tied to a specific framework and renderer, so I can use ECS regardless of if I want to use OpenFL, NME, Kha or Heaps. Also I would like to be able to reuse components on the server side, in which case I also need components to be decoupled from framework and renderer as well.

The idea is not to add abstractions of everything in the different backends and frameworks used, but just add en ECS implementation to control rendering, input and sound. So the intention is not to be able to write a game that can be instantly ported between frameworks, but it should be possible to write components that can be reused between backends or can run on a server.

Targeting a new framework means writing a few classes to ensure that the Entity graph is tied to the rendering system and models for graphics and sound that can interface with the framework classes. To run components to perform logic on the server, the idea is to create noop systems for rendering and sound so just the models are updated.

Note that ECS purists will not consider this a proper ECS framework, since components contain the logics instead of systems. If you are writing a complex RPG or MMO, proper ECS might be worth looking in to, but for more typical small scale web or mobile projects I think having logic in components is prerable.

## What does it mean?
The name comes from the separation added to different component types, Graphics, Actor, Sound, Model. 
GASM has model types for graphics (SpriteModelComponent, TextModelComponent) and sound (SoundModelComponent) which are used to interface with the framework used. 

Regardless of in which order components are added, they will always be updated in the following order:
Models -> Actors -> Graphics -> Sound

## Current status
Currently there is a basic renderer and sound systems for OpenFL and Heaps, and some examples with graphics, text and sound.See GASM-openfl, GASM-heaps and GASM-examples.
Some optimization is done to ensure performance seems acceptable, and at least with the shallow entity graph in the bunny mark test in examples, the overhead introduced by the framwork seems like it should be acceptable for most games. Compared to Flambe there will be additional overhead due to two things:
- The model components added to interface between graphics objects in different frameworks means extra calls when updating an Entity.
- Extra logic to ensure the different component types are updated in the correct order.

## Future plans
Current focus is having it stable with HEAPS backend and fixing any issues we might encounter while making our first games using the framework.


## Usage
Run:
```
haxelib install gasm
```
Alternatively:
```
npm i -D haxe-module-installer gasm
```
Then add the integration for the backend you want to use:
```
haxelib install gasm-openfl
```
or
```
haxelib install gasm-heaps
```

Those are also available as npm packages, and assuming you already installed haxe-module-installer you can use:
```
npm i -D gasm-heaps
npm i -D gasm-openfl
```
Finally you might want to look the the examples:
https://github.com/HacksawStudios/GASM-examples


## Compatibility

The goal is that the core ECS system should be possible to use for an integration on any target.
So far only core entity component functionality is tested on Haxe 3.2.1 and 3.3.0 with the following targets:
  neko
  python
  node
  flash
  java
  cpp
  cs
  php