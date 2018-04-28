unit DSONTestSuites;

interface

uses
  DUnitX.TestFramework,
  DSON;

type

  DSONTestsBase = class(TObject)
    strict protected
      FDSONObject: IDSONObject;
      FDateTime: TDateTime;
      procedure BuildDSONObject;
  end;

  [TestFixture]
  BuilderTests = class(DSONTestsBase)
    public
      [Setup]
      procedure Setup;
      [Test]
      procedure BuildsValueNames;
      [Test]
      procedure BuildsValueKinds;
      [Test]
      procedure BuildsSimpleValues;
      [Test]
      procedure BuildsArrayValues;
      [Test]
      procedure BuildsObjectValues;
  end;

  [TestFixture]
  ReaderTests = class(DSONTestsBase)
    public
      [Setup]
      procedure Setup;
  end;

  [TestFixture]
  BinaryWriterTests = class(DSONTestsBase)
    public
      [Setup]
      procedure Setup;
      [Test]
      procedure WritesNumerics;
      [Test]
      procedure WritesStrings;
      [Test]
      procedure WritesArrays;
  end;

  [TestFixture]
  JSONWriterTests = class(DSONTestsBase)
    public
      [Setup]
      procedure Setup;
  end;

implementation

uses
  System.SysUtils,
  System.Rtti,
  System.DateUtils;

{BuilderTests}

procedure BuilderTests.BuildsArrayValues;
begin
  // Array of integer
  Assert.IsTrue(Supports(FDSONObject.Pairs[14].Value, IDSONArray));
  with FDSONObject.Pairs[14].Value as IDSONArray do
    begin
      Assert.AreEqual(5, Length(Values));
      Assert.AreEqual(1, (Values[0] as IDSONSimple).Value.AsInteger);
      Assert.AreEqual(2, (Values[1] as IDSONSimple).Value.AsInteger);
      Assert.AreEqual(3, (Values[2] as IDSONSimple).Value.AsInteger);
      Assert.AreEqual(4, (Values[3] as IDSONSimple).Value.AsInteger);
      Assert.AreEqual(5, (Values[4] as IDSONSimple).Value.AsInteger);
    end;

  // Array of array
  with FDSONObject.Pairs[15].Value as IDSONArray do
    begin
      Assert.AreEqual(2, Length(Values));
      Assert.IsTrue(Supports(Values[0], IDSONArray));
      Assert.IsTrue(Supports(Values[1], IDSONArray));
    end;

  with (FDSONObject.Pairs[15].Value as IDSONArray).Values[0] as IDSONArray do
    begin
      Assert.AreEqual(5, Length(Values));
      Assert.AreEqual(1, (Values[0] as IDSONSimple).Value.AsInteger);
      Assert.AreEqual(2, (Values[1] as IDSONSimple).Value.AsInteger);
      Assert.AreEqual(3, (Values[2] as IDSONSimple).Value.AsInteger);
      Assert.AreEqual(4, (Values[3] as IDSONSimple).Value.AsInteger);
      Assert.AreEqual(5, (Values[4] as IDSONSimple).Value.AsInteger);
    end;

  with (FDSONObject.Pairs[15].Value as IDSONArray).Values[1] as IDSONArray do
    begin
      Assert.AreEqual(3, Length(Values));
      Assert.AreEqual('red', (Values[0] as IDSONSimple).Value.AsString);
      Assert.AreEqual('green', (Values[1] as IDSONSimple).Value.AsString);
      Assert.AreEqual('blue', (Values[2] as IDSONSimple).Value.AsString);
    end;

  // Array of object
  with FDSONObject.Pairs[16].Value as IDSONArray do
    begin
      Assert.AreEqual(2, Length(Values));
      Assert.IsTrue(Supports(Values[0], IDSONObject));
      Assert.IsTrue(Supports(Values[1], IDSONObject));
    end;

  with (FDSONObject.Pairs[16].Value as IDSONArray).Values[0] as IDSONObject do
    begin
      Assert.AreEqual('name', Pairs[0].Name);
      Assert.AreEqual('John Doe', (Pairs[0].Value as IDSONSimple).Value.ToString);
      Assert.AreEqual('age', Pairs[1].Name);
      Assert.AreEqual(34, (Pairs[1].Value as IDSONSimple).Value.AsInteger);
    end;

  with (FDSONObject.Pairs[16].Value as IDSONArray).Values[1] as IDSONObject do
    begin
      Assert.AreEqual('name', Pairs[0].Name);
      Assert.AreEqual('Jane Doe', (Pairs[0].Value as IDSONSimple).Value.ToString);
      Assert.AreEqual('age', Pairs[1].Name);
      Assert.AreEqual(32, (Pairs[1].Value as IDSONSimple).Value.AsInteger);
    end;

  // Array of array of array
  with FDSONObject.Pairs[18].Value as IDSONArray do
    begin
      Assert.AreEqual(2, Length(Values));
    end;

  with (FDSONObject.Pairs[18].Value as IDSONArray).Values[0] as IDSONArray do
    begin
      Assert.AreEqual(2, Length(Values));
      with Values[0] as IDSONArray do
        begin
          Assert.AreEqual(2, Length(Values));
          Assert.AreEqual(1, (Values[0] as IDSONSimple).Value.AsInteger);
          Assert.AreEqual(2, (Values[1] as IDSONSimple).Value.AsInteger);
        end;
      with Values[1] as IDSONArray do
        begin
          Assert.AreEqual(2, Length(Values));
          Assert.AreEqual(3, (Values[0] as IDSONSimple).Value.AsInteger);
          Assert.AreEqual(4, (Values[1] as IDSONSimple).Value.AsInteger);
        end;
    end;

  with (FDSONObject.Pairs[18].Value as IDSONArray).Values[1] as IDSONArray do
    begin
      Assert.AreEqual(2, Length(Values));
      with Values[0] as IDSONArray do
        begin
          Assert.AreEqual(2, Length(Values));
          Assert.AreEqual(5, (Values[0] as IDSONSimple).Value.AsInteger);
          Assert.AreEqual(6, (Values[1] as IDSONSimple).Value.AsInteger);
        end;
      with Values[1] as IDSONArray do
        begin
          Assert.AreEqual(2, Length(Values));
          Assert.AreEqual(7, (Values[0] as IDSONSimple).Value.AsInteger);
          Assert.AreEqual(8, (Values[1] as IDSONSimple).Value.AsInteger);
        end;
    end;
end;

procedure BuilderTests.BuildsObjectValues;
begin
  // Object
  with FDSONObject.Pairs[17].Value as IDSONObject do
    begin
      Assert.AreEqual(2, Pairs.Count);
      Assert.AreEqual('widget', Pairs[0].Name);
      Assert.AreEqual('total', Pairs[1].Name);
      Assert.AreEqual(305.75, (Pairs[1].Value as IDSONSimple).Value.AsExtended, 0.01);
    end;

  with (FDSONObject.Pairs[17].Value as IDSONObject).Pairs[0].Value as IDSONObject do
    begin
      Assert.AreEqual(2, Pairs.Count);
      Assert.AreEqual('materials', Pairs[0].Name);
      Assert.AreEqual(125.75, (Pairs[0].Value as IDSONSimple).Value.AsExtended, 0.01);
      Assert.AreEqual('labor', Pairs[1].Name);
      Assert.AreEqual(180.00, (Pairs[1].Value as IDSONSimple).Value.AsExtended, 0.01);
    end;
end;

procedure BuilderTests.BuildsValueKinds;
begin
  Assert.AreEqual(dkGUID, FDSONObject.Pairs[0].Value.Kind);
  Assert.AreEqual(dkByte, FDSONObject.Pairs[1].Value.Kind);
  Assert.AreEqual(dkInt16, FDSONObject.Pairs[2].Value.Kind);
  Assert.AreEqual(dkInt32, FDSONObject.Pairs[3].Value.Kind);
  Assert.AreEqual(dkInt64, FDSONObject.Pairs[4].Value.Kind);
  Assert.AreEqual(dkString, FDSONObject.Pairs[5].Value.Kind);
  Assert.AreEqual(dkSingle, FDSONObject.Pairs[6].Value.Kind);
  Assert.AreEqual(dkDouble, FDSONObject.Pairs[7].Value.Kind);
  Assert.AreEqual(dkExtended, FDSONObject.Pairs[8].Value.Kind);
  Assert.AreEqual(dkChar, FDSONObject.Pairs[9].Value.Kind);
  Assert.AreEqual(dkTrue, FDSONObject.Pairs[10].Value.Kind);
  Assert.AreEqual(dkFalse, FDSONObject.Pairs[11].Value.Kind);
  Assert.AreEqual(dkDateTime, FDSONObject.Pairs[12].Value.Kind);
  Assert.AreEqual(dkNil, FDSONObject.Pairs[13].Value.Kind);
  Assert.AreEqual(dkArray, FDSONObject.Pairs[14].Value.Kind);
  Assert.AreEqual(dkArray, FDSONObject.Pairs[15].Value.Kind);
  Assert.AreEqual(dkArray, FDSONObject.Pairs[16].Value.Kind);
  Assert.AreEqual(dkObject, FDSONObject.Pairs[17].Value.Kind);
  Assert.AreEqual(dkArray, FDSONObject.Pairs[18].Value.Kind);
end;

procedure BuilderTests.BuildsValueNames;
begin
  Assert.AreEqual('dkGUID', FDSONObject.Pairs[0].Name);
  Assert.AreEqual('dkByte', FDSONObject.Pairs[1].Name);
  Assert.AreEqual('dkInt16', FDSONObject.Pairs[2].Name);
  Assert.AreEqual('dkInt32', FDSONObject.Pairs[3].Name);
  Assert.AreEqual('dkInt64', FDSONObject.Pairs[4].Name);
  Assert.AreEqual('dkString', FDSONObject.Pairs[5].Name);
  Assert.AreEqual('dkSingle', FDSONObject.Pairs[6].Name);
  Assert.AreEqual('dkDouble', FDSONObject.Pairs[7].Name);
  Assert.AreEqual('dkExtended', FDSONObject.Pairs[8].Name);
  Assert.AreEqual('dkChar', FDSONObject.Pairs[9].Name);
  Assert.AreEqual('dkTrue', FDSONObject.Pairs[10].Name);
  Assert.AreEqual('dkFalse', FDSONObject.Pairs[11].Name);
  Assert.AreEqual('dkDateTime', FDSONObject.Pairs[12].Name);
  Assert.AreEqual('dkNil', FDSONObject.Pairs[13].Name);
  Assert.AreEqual('dkArrayOfInteger', FDSONObject.Pairs[14].Name);
  Assert.AreEqual('dkArrayOfArray', FDSONObject.Pairs[15].Name);
  Assert.AreEqual('dkArrayOfObjects', FDSONObject.Pairs[16].Name);
  Assert.AreEqual('dkObject', FDSONObject.Pairs[17].Name);
  Assert.AreEqual('dkArrayOfArrayOfArray', FDSONObject.Pairs[18].Name);
end;

procedure BuilderTests.BuildsSimpleValues;
begin
  // Simple types
  Assert.AreEqual('{11111111-2222-3333-4444-555555555555}', (FDSONObject.Pairs[0].Value as IDSONSimple).Value.ToString);
  Assert.AreEqual('65', (FDSONObject.Pairs[1].Value as IDSONSimple).Value.ToString);
  Assert.AreEqual('16', (FDSONObject.Pairs[2].Value as IDSONSimple).Value.ToString);
  Assert.AreEqual('32', (FDSONObject.Pairs[3].Value as IDSONSimple).Value.ToString);
  Assert.AreEqual('64', (FDSONObject.Pairs[4].Value as IDSONSimple).Value.ToString);
  Assert.AreEqual('The quick brown fox jumped over the lazy dogs', (FDSONObject.Pairs[5].Value as IDSONSimple)
    .Value.ToString);
  Assert.AreEqual(1.1, (FDSONObject.Pairs[6].Value as IDSONSimple).Value.AsExtended, 0.01);
  Assert.AreEqual(2.2, (FDSONObject.Pairs[7].Value as IDSONSimple).Value.AsExtended, 0.01);
  Assert.AreEqual(3.3, (FDSONObject.Pairs[8].Value as IDSONSimple).Value.AsExtended, 0.01);
  Assert.AreEqual('Z', (FDSONObject.Pairs[9].Value as IDSONSimple).Value.ToString);
  Assert.AreEqual(True, (FDSONObject.Pairs[10].Value as IDSONSimple).Value.AsBoolean);
  Assert.AreEqual(False, (FDSONObject.Pairs[11].Value as IDSONSimple).Value.AsBoolean);
  Assert.AreEqual(DateTimeToUnix(FDateTime), (FDSONObject.Pairs[12].Value as IDSONSimple).Value.AsInt64);
  Assert.IsTrue((FDSONObject.Pairs[13].Value as IDSONSimple).Value.IsEmpty);
end;

procedure BuilderTests.Setup;
begin
  FDateTime := Now;
  BuildDSONObject;
end;

procedure DSONTestsBase.BuildDSONObject;
var
  Builder: IDSONBuilder;
  GUID: TGUID;
begin
  {
   TOddDSONKind = (dkNull, dkByte, dkInt16, dkInt32, dkInt64, dkString, dkSingle, dkDouble, dkExtended, dkChar, dkTrue,
   dkFalse, dkEnum, dkDateTime, dkArray, dkObject, dkGUID, dkRecord);
  }
  (*
   {
   "dkGUID": "{11111111-2222-3333-4444-555555555555}",
   "dkByte": 65,
   "dkInt16": 16,
   "dkInt32": 32,
   "dkInt64": 64,
   "dkString": "The quick brown fox jumped over the lazy dogs",
   "dkSingle": 1.1,
   "dkDouble": 2.2,
   "dkExtended": 3.3,
   "dkChar": "Z",
   "dkTrue": true,
   "dkFalse": false,
   "dkDateTime": [ISO time],
   "dkArrayOfInteger": [
   1,2,3,4,5
   ],
   "dkArrayOfArray": [
   [1,2,3,4,5],
   ["red","green","blue"]
   ],
   "dkArrayOfObjects": [
   "object": {
   "name": "john doe",
   "age": 34
   }
   ],
   "dkObject": {
   "widget": {
   "materials": 125.75,
   "labor": 180.00
   }
   "total": 305.75
   },
   "dkArrayOfArrayOfArray": {
   [
   [
   [1,2],
   [3,4]
   ],
   [
   [5,6],
   [7,8]
   ]
   ]
   }
   }
  *)
  GUID := TGUID.Create('{11111111-2222-3333-4444-555555555555}');
  Builder := DSON.Builder;
  Builder.StartObject;
  Builder.AddPropertyName('dkGUID').AddValue(GUID).AddPropertyName('dkByte').AddValue(Byte(65))
    .AddPropertyName('dkInt16').AddValue(Int16(16)).AddPropertyName('dkInt32').AddValue(Int32(32))
    .AddPropertyName('dkInt64').AddValue(Int64(64)).AddPropertyName('dkString')
    .AddValue('The quick brown fox jumped over the lazy dogs').AddPropertyName('dkSingle').AddValue(Single(1.1))
    .AddPropertyName('dkDouble').AddValue(Double(2.2)).AddPropertyName('dkExtended').AddValue(Extended(3.3))
    .AddPropertyName('dkChar').AddValue(Char('Z')).AddPropertyName('dkTrue').AddValue(True).AddPropertyName('dkFalse')
    .AddValue(False).AddPropertyName('dkDateTime').AddValue(FDateTime).AddPropertyName('dkNil')
    .AddNilValue.AddPropertyName('dkArrayOfInteger').StartArray.AddValue(1).AddValue(2).AddValue(3).AddValue(4)
    .AddValue(5).EndArray.AddPropertyName('dkArrayOfArray').StartArray.StartArray.AddValue(1).AddValue(2).AddValue(3)
    .AddValue(4).AddValue(5).EndArray.StartArray.AddValue('red').AddValue('green').AddValue('blue')
    .EndArray.EndArray.AddPropertyName('dkArrayOfObjects').StartArray.StartObject.AddPropertyName('name')
    .AddValue('John Doe').AddPropertyName('age').AddValue(34).EndObject.StartObject.AddPropertyName('name')
    .AddValue('Jane Doe').AddPropertyName('age').AddValue(32).EndObject.EndArray.AddPropertyName('dkObject')
    .StartObject.AddPropertyName('widget').StartObject.AddPropertyName('materials').AddValue(125.75)
    .AddPropertyName('labor').AddValue(180.00).EndObject.AddPropertyName('total').AddValue(305.75)
    .EndObject.AddPropertyName('dkArrayOfArrayOfArray').StartArray.StartArray.StartArray.AddValue(1).AddValue(2)
    .EndArray.StartArray.AddValue(3).AddValue(4).EndArray.EndArray.StartArray.StartArray.AddValue(5).AddValue(6)
    .EndArray.StartArray.AddValue(7).AddValue(8).EndArray.EndArray.EndArray.EndObject;
  FDSONObject := Builder.DSONObject;
end;

{ ReaderTests }

procedure ReaderTests.Setup;
begin
  FDateTime := Now;
  BuildDSONObject;
end;

{ BinaryWriterTests }

procedure BinaryWriterTests.Setup;
begin
  FDateTime := Now;
  BuildDSONObject;
end;

procedure BinaryWriterTests.WritesArrays;
begin
  {
  dmStartObject   1
    dmStartPair   1
      Name length 4
      Name string 4
      dmArray     1
      Value       [1,2,3]
    dmEndPair     1
  dmEndObject     1
  }
end;

procedure BinaryWriterTests.WritesNumerics;
var
  Bytes: TBytes;
  Obj: IDSONObject;
begin
  {
  dmStartObject   1
    dmStartPair   1
      Name length 4
      Name string 4
      dm[Value]   1
      Value       Byte: 1, Int16: 2, Int32: 4, Int64: 8, Single: 8, Double: 16, Extended: 16 (stored as a double)
    dmEndPair     1
  dmEndObject     1
  }

  // Byte
  Obj := DSON.Builder.StartObject.AddPropertyName('prop').AddValue(Byte(65)).EndObject.DSONObject;
  Bytes := DSON.BinaryWriter.WriteObject(Obj);
  Assert.AreEqual(14,Length(Bytes));

  Assert.AreEqual(dmStartObject, TDSONMarker(Bytes[0]));
  Assert.AreEqual(dmStartPair, TDSONMarker(Bytes[1]));
  Assert.AreEqual(dmByte, TDSONMarker(Bytes[10]));
  Assert.AreEqual(dmEndPair, TDSONMarker(Bytes[12]));
  Assert.AreEqual(dmEndObject, TDSONMarker(Bytes[13]));

  // Int16
  Obj := DSON.Builder.StartObject.AddPropertyName('prop').AddValue(Word(65)).EndObject.DSONObject;
  Bytes := DSON.BinaryWriter.WriteObject(Obj);
  Assert.AreEqual(15,Length(Bytes));
  Assert.AreEqual(dmInt16, TDSONMarker(Bytes[10]));

  // Int32
  Obj := DSON.Builder.StartObject.AddPropertyName('prop').AddValue(Integer(65)).EndObject.DSONObject;
  Bytes := DSON.BinaryWriter.WriteObject(Obj);
  Assert.AreEqual(17,Length(Bytes));
  Assert.AreEqual(dmInt32, TDSONMarker(Bytes[10]));

  // Int64
  Obj := DSON.Builder.StartObject.AddPropertyName('prop').AddValue(Int64(65)).EndObject.DSONObject;
  Bytes := DSON.BinaryWriter.WriteObject(Obj);
  Assert.AreEqual(21,Length(Bytes));
  Assert.AreEqual(dmInt64, TDSONMarker(Bytes[10]));

  // Single
  Obj := DSON.Builder.StartObject.AddPropertyName('prop').AddValue(Single(65.1)).EndObject.DSONObject;
  Bytes := DSON.BinaryWriter.WriteObject(Obj);
  Assert.AreEqual(17,Length(Bytes));
  Assert.AreEqual(dmSingle, TDSONMarker(Bytes[10]));

  // Double
  Obj := DSON.Builder.StartObject.AddPropertyName('prop').AddValue(Double(65.1)).EndObject.DSONObject;
  Bytes := DSON.BinaryWriter.WriteObject(Obj);
  Assert.AreEqual(21,Length(Bytes));
  Assert.AreEqual(dmDouble, TDSONMarker(Bytes[10]));

  // Extended
  Obj := DSON.Builder.StartObject.AddPropertyName('prop').AddValue(Extended(65.1)).EndObject.DSONObject;
  Bytes := DSON.BinaryWriter.WriteObject(Obj);
  Assert.AreEqual(21,Length(Bytes));
  Assert.AreEqual(dmExtended, TDSONMarker(Bytes[10]));
end;

procedure BinaryWriterTests.WritesStrings;
var
  Bytes: TBytes;
  Obj: IDSONObject;
begin
  {
  dmStartObject    1
    dmStartPair    1
      Name length  4
      Name string  4
      dm[Value]    1
      Value length 4
      Value        "Hello World" 11
    dmEndPair      1
  dmEndObject      1
  } // 28 bytes

  Obj := DSON.Builder.StartObject.AddPropertyName('prop').AddValue('Hello World').EndObject.DSONObject;
  Bytes := DSON.BinaryWriter.WriteObject(Obj);
  Assert.AreEqual(28,Length(Bytes));

  Assert.AreEqual(dmStartObject, TDSONMarker(Bytes[0]));
  Assert.AreEqual(dmStartPair, TDSONMarker(Bytes[1]));
  Assert.AreEqual(dmString, TDSONMarker(Bytes[10]));
  Assert.AreEqual(dmEndPair, TDSONMarker(Bytes[26]));
  Assert.AreEqual(dmEndObject, TDSONMarker(Bytes[27]));
end;

{ JSONWriterTests }

procedure JSONWriterTests.Setup;
begin
  FDateTime := Now;
  BuildDSONObject;
end;

initialization

TDUnitX.RegisterTestFixture(BuilderTests);
TDUnitX.RegisterTestFixture(ReaderTests);
TDUnitX.RegisterTestFixture(BinaryWriterTests);
TDUnitX.RegisterTestFixture(JSONWriterTests);

end.
