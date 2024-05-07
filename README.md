# Jayse

![Logo](Images/IconSmall.png) 

Traverse and modify JSON documents with an immutable data structures and lossless conversion to and from strongly typed objects in Dart and .NET.

<small>**Note**: this repo has two separate libraries (Dart/.NET) for working with JSON with the same name. They are currently different, but the aim for the long term is to bring them together and make them converge.</small>

[Dart Package](src/dart_jayse)

[C# Package](src/dotnet)

## What Is It And Why?

[JSON](https://www.json.org/json-en.html) is a simple data structure and textual representation that allows the storage and transfer of data in a human readable format. Most of the web uses JSON for Web API data transfer. 

Unlike data structures in statically typed languages like C# and Dart, JSON is a dynamic structure that can contain any type of data. This poses challenges for mapping JSON to statically typed languages. JSON is in stark contrast with comparable structures like [Protobuf](https://protobuf.dev/), which is modelled after statically typed languages and is designed to be converted to and from them.