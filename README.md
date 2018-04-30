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
```delphi
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
```delphi
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
```delphi
var
  Obj: IDSONObject;
  Stream: TMemoryStream;
  Bytes: TBytes;
begin
  Stream := TMemoryStream.Create;
  try
    Obj :=
      DSON.Builder
        .StartObject
          .AddPropertyName('foo')
          .AddValue('bar')
        .EndObject.DSONObject;
    // Write to a stream
    DSON.BinaryWriter.WriteObjectToStream(Obj,Stream);
    // Write to TBytes
    Bytes := DSON.BinaryWriter.WriteObject(Obj);
  finally
    Stream.Free;
  end;
end;
```

## DSON JSON Writer
This will generate a JSON string from your object.

**Example:**
```delphi
var
  Obj: IDSONObject;
  Str: String;
begin
  Obj :=
    DSON.Builder
      .StartObject
        .AddPropertyName('foo')
        .AddValue('bar')
      .EndObject.DSONObject;
  // Write to a JSON string
  Str := DSON.JSONWriter.WriteObject(Obj);
end;
```

Again, this will be lossy as you will lose the precision of Delphi native types.

## DSON Reader
Reads a DSON object back in from a stream.

**Example:**
```delphi
var
  Obj1, Obj2: IDSONObject;
  Stream: TMemoryStream;
begin
  Stream := TMemoryStream.Create;
  try
    Obj :=
      DSON.Builder
        .StartObject
          .AddPropertyName('foo')
          .AddValue('bar')
        .EndObject.DSONObject;
    // Write to a stream
    DSON.BinaryWriter.WriteObjectToStream(Obj,Stream);
    // Read it back in
    Stream.Position := 0;
    Obj2 := DSON.Reader.ReadObject(Stream);
  finally
    Stream.Free;
  end;
end;
```
