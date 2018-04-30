# DSON
DSON is a customized version of BSON that more closely represents internal Delphi data types.

## Purpose
Provides the ability to stream "DSON" objects in and out while retaining (as much as possible) the native Delphi data types.

## Usage
Everything is interface based. The basic usage flow is build an object, write it to a stream, read it back in. Additionally there is a JSON writer to write your object to pure JSON but this will, of course, result in the loss of the Delphi data type precision.

```
IDSONBuilder: A "fluent" builder class for building DSON objects
IDSONReader:  Reads a stream and returns a DSON object
IDSONBinaryWriter: Writes a DSON object to a stream or TBytes array
IDSONJSONWriter: Writes a DSON object to a JSON string
```

There are four utility functions provided in the DSON source file. They are:

```
DSON.Builder: returns an IDSONBuilder instance
DSON.Reader: returns an IDSONReader instance
DSON.BinaryWriter: returns an IDSONBinaryWriter instance
DSON.JSONWriter: returns an IDSONJSONWriter instance
```

## DSON Builder
Use this to build your DSON objects. After the final call to EndObject you can retrieve the built object through the DSONObject property.

**Fluent Example:**
```
var
  Obj: IDSONObject;
begin
  Obj :=
    DSON.Builder
      .StartObject
        .AddPropertyName('foo')
        .AddValue('bar')
        .StartObject
          .AddPropertyName('subfoo')
          .AddValue('subbar')
        .EndObject
        .AddPropertyName('fooarray')
        .StartArray
          .AddValue(1)
          .AddValue(2)
          .AddValue(3)
        .EndArray
        // ...
      .EndObject.DSONObject;
end;
```

**Non-fluent Example:**
```
// The utility function always returns a new builder, so you want to
// keep a local reference.
var
  Builder: IDSONBuilder;
  Obj: IDSONObject;
begin
  Builder := DSON.Builder;
  Builder.StartObject;
  Builder.AddPropertyName('foo');
  Builder.AddValue('bar');
  // ...
  Builder.EndObject;
  Obj := Builder.DSONObject;
end;
```

Of course, everything is interfaces so there is no need to free your local builder.

## DSON Binary Writer
Use this to write your DSON objects to a stream.

**Example:**
```
var
  Obj: IDSONObject;
begin
  Obj :=
    DSON.Builder
      .StartObject
        .AddPropertyName('foo')
        .AddValue('bar')
      .EndObject.DSONObject;
  // Write to a stream
  DSON.BinaryWriter.WriteObjectToStream(Obj,Stream);
  // Write to TBytes
  DSON.BinaryWriter.WriteObject(Obj); // Returns TBytes
end;
```

## DSON JSON Writer
This will generate a JSON string from your object.

**Example:**
```
var
  Obj: IDSONObject;
begin
  Obj :=
    DSON.Builder
      .StartObject
        .AddPropertyName('foo')
        .AddValue('bar')
      .EndObject.DSONObject;
  // Write to a JSON string
  DSON.JSONWriter.WriteObject(Obj); // Returns a JSON string
end;
```

Again, this will be lossy as you will lose the precision of Delphi native types.

## DSON Reader
