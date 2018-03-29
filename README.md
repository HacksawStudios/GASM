# GASM ECS

Framework agnostic ECS layer.

## What is it?
Entity Component System heavily inspired by Flambe, but which is designed not to be tied to a particular renderer. So for example it could be used together with HEAPS, OpenFL, Pixi or Kha.
The idea is to abstract the features that are common across frameworks, for example by having a sprite component tied to a sprite model with data such as x and y position.
You can then add components modifying the sprite model without being tightly coupled to a Sprite class from a particular framework.

This will remove a lot of the coupling between game code and rendering framework, but not to remove it completely since that would mean having to limit yourself to features that can reliably be replicated between frameworks. However it means that you can reuse a lot of components without modification, and should minimize the effort of porting a game to a different renderer.
Targeting a new framework means writing a few classes to ensure that the Entity graph is tied to the rendering system and models for graphics and sound that can interface with the framework classes. 

Note that ECS purists will not consider this a proper ECS framework, since components contain the logic instead of systems. If you are writing a complex RPG or MMO, proper ECS might be worth looking in to, but for more typical small scale web or mobile projects I think having logic in components is preferable.

## Why should I use it
There are several complete game engines using ECS, that are easy to work with and perform well (Flambe, Unity, Phaser, etc).
However, when working with games that can have a commercial lifespan spanning decades, often they can outlast the technology which can turn very costly to address if the code is coupled to a specific stack. Haxe allows reaching many different platforms, and makes it possible to write code that transcends specific platforms, but typically you will still depend on for example OpenFL to abstract platform specific functionality.
GASM takes this one step further, and makes it possible to with minimal effort switch to a new platform abstraction should the need arise.
However, in the case of GASM the abstraction does add another layer of complexity and does cost some performance, so is essence there are two scenarios where GASM is a good choice: 
1. You work with games that have a long lifespan, and want to abstract as much as possible from underlying technology to minimise risk and cost associated with having to port your games in the future.
2. You like the ECS flavor, and want to use it with your platform abstraction of choice.

## What does it mean?
The name comes from the separation added to different component types, Graphics, Actor, Sound, Model. 
GASM has model types for graphics (SpriteModelComponent, TextModelComponent) and sound (SoundModelComponent) which are used to interface with the framework used. 

Regardless of in which order components are added, they will always be updated in the following order:
Models -> Actors -> Graphics -> Sound

## Current status
Project is under active development and the current focus is having a stable HEAPS adapter and fixing any issues we might encounter while making our first games using the framework. An OpenFL adapter exists, but is no longer maintained since we decided to go with HEAPS instead.
Some optimization is done to ensure performance seems acceptable, and at least with the shallow entity graph in the bunny mark test in examples, the overhead introduced by the framwork seems like it should be acceptable for most games. Compared to Flambe there will be additional overhead due to two things:
- The model components added to interface between graphics objects in different frameworks means extra calls when updating an Entity.
- Extra logic to ensure the different component types are updated in the correct order.

## Future plans
GASM will only handle parts which makes sense to abstract, and currently no additional features are planned. SOme more generally useful components might be added as the need arises, but for now there are none planned.

## Usage
Run:
```
haxelib install gasm
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
npm i -D gasm
npm i -D gasm-heaps
npm i -D gasm-openfl
```

## Getting started
Have a look the the examples for some ideas of how to use GASM:
https://github.com/HacksawStudios/GASM-examples

## Features
1. Core ECS implementation

Entity and Component classes.

2. LayoutComponent

Can be used to position and scale display objects to create layouts.

3. Loader

Both HEAPS and OpenFL offer asset management, but they are designed to have assets available at compile time. If you need to do runtime loading you will have to make your own solution. In our case we do branded and localized games, and don't want assets to be compiled with the game.
The Loader class can optionally be configured to handle branding, platform and locale specific resources with fallback while providing accurate loading progress.
See Preloader class in gasm-heaps for an example of usage and preloader integration.

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