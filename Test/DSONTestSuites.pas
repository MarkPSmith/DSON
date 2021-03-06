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
      [Test]
      procedure ReadsDSON;
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
      [Test]
      procedure WritesNil;
      [Test]
      procedure WritesBooleans;
      [Test]
      procedure WritesDates;
      [Test]
      procedure WritesGUIDs;
  end;

  [TestFixture]
  JSONWriterTests = class(DSONTestsBase)
    public
      [Setup]
      procedure Setup;
      [Test]
      procedure WritesArrays;
      [Test]
      procedure WritesBooleans;
      [Test]
      procedure WritesDates;
      [Test]
      procedure WritesGUIDs;
      [Test]
      procedure WritesNil;
      [Test]
      procedure WritesNumerics;
      [Test]
      procedure WritesStrings;
  end;

implementation

uses
  System.SysUtils,
  System.Rtti,
  System.DateUtils, System.Classes;

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
  Assert.AreEqual(FDateTime, (FDSONObject.Pairs[12].Value as IDSONSimple).Value.AsType<TDateTime>);
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

procedure ReaderTests.ReadsDSON;
var
  BS: TBytesStream;
  Obj: IDSONObject;

  procedure CheckSimplePair(const APair: IDSONPair; const AKind: TDSONKind; const AName, AValue: string);
  begin
    Assert.AreEqual(AName,APair.Name);
    Assert.AreEqual(AKind,APair.Value.Kind);
    Assert.AreEqual(AValue,(APair.Value as IDSONSimple).Value.ToString);
  end;

begin
  BS := TBytesStream.Create;
  try
    DSON.BinaryWriter.WriteObjectToStream(FDSONObject,BS);
    BS.Position := 0;
    Assert.WillNotRaiseAny(
      procedure begin
        Obj := DSON.Reader.ReadObject(BS);
      end
    );
    CheckSimplePair(Obj.Pairs[0],dkGUID,'dkGUID','{11111111-2222-3333-4444-555555555555}');
    CheckSimplePair(Obj.Pairs[1],dkByte,'dkByte','65');
    CheckSimplePair(Obj.Pairs[2],dkInt16,'dkInt16','16');
    CheckSimplePair(Obj.Pairs[3],dkInt32,'dkInt32','32');
    CheckSimplePair(Obj.Pairs[4],dkInt64,'dkInt64','64');
    CheckSimplePair(Obj.Pairs[5],dkString,'dkString','The quick brown fox jumped over the lazy dogs');

    // Single doesn't have enough precision to come out cleanly as a string. Testing individually
    // instead of in CheckSimplePair()
    Assert.AreEqual('dkSingle',Obj.Pairs[6].Name);
    Assert.AreEqual(dkSingle,Obj.Pairs[6].Value.Kind);
    Assert.AreEqual(Single(1.1),(Obj.Pairs[6].Value as IDSONSimple).Value.AsType<Single>,0.01);

    CheckSimplePair(Obj.Pairs[7],dkDouble,'dkDouble','2.2');
    CheckSimplePair(Obj.Pairs[8],dkExtended,'dkExtended','3.3');
    CheckSimplePair(Obj.Pairs[9],dkChar,'dkChar','Z');
    CheckSimplePair(Obj.Pairs[10],dkTrue,'dkTrue','True');
    CheckSimplePair(Obj.Pairs[11],dkFalse,'dkFalse','False');
    CheckSimplePair(Obj.Pairs[12],dkDateTime,'dkDateTime',TValue.From(FDateTime).ToString);
    CheckSimplePair(Obj.Pairs[13],dkNil,'dkNil','(empty)');

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
  finally
    BS.Free;
  end;
end;

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
var
  Bytes: TBytes;
  Obj: IDSONObject;
begin
  {
  dmStartObject    1
    dmStartPair    1
      Name length  4
      Name string  4
      dmStartArray 1
        dmByte     1
        1          1
        dmByte     1
        2          1
        dmByte     1
        3          1
      dmEndArray   1
    dmEndPair      1
  dmEndObject      1
  } // 20 bytes
  Obj := DSON.Builder
         .StartObject
           .AddPropertyName('prop')
           .StartArray
             .AddValue(Byte(1))
             .AddValue(Byte(2))
             .AddValue(Byte(3))
           .EndArray
         .EndObject
         .DSONObject;

  Bytes := DSON.BinaryWriter.WriteObject(Obj);
  Assert.AreEqual(20,Length(Bytes));

  Assert.AreEqual(dmStartObject, TDSONMarker(Bytes[0]));
  Assert.AreEqual(dmStartPair, TDSONMarker(Bytes[1]));
  Assert.AreEqual(dmStartArray,TDSONMarker(Bytes[10]));
  Assert.AreEqual(dmByte,TDSONMarker(Bytes[11]));
  Assert.AreEqual(Byte(1),Bytes[12]);
  Assert.AreEqual(dmByte,TDSONMarker(Bytes[13]));
  Assert.AreEqual(Byte(2),Bytes[14]);
  Assert.AreEqual(dmByte,TDSONMarker(Bytes[15]));
  Assert.AreEqual(Byte(3),Bytes[16]);
  Assert.AreEqual(dmEndArray, TDSONMarker(Bytes[17]));
  Assert.AreEqual(dmEndPair, TDSONMarker(Bytes[18]));
  Assert.AreEqual(dmEndObject, TDSONMarker(Bytes[19]));
end;

procedure BinaryWriterTests.WritesBooleans;
var
  Bytes: TBytes;
  Obj: IDSONObject;
begin
  {
  dmStartObject   1
    dmStartPair   1
      Name length 4
      Name string 4
      dmTrue      1
      Value       [Empty for Booleans]
    dmEndPair     1
    dmStartPair   1
      Name length 4
      Name string 5
      dmFalse     1
      Value       [Empty for Booleans]
    dmEndPair     1
  dmEndObject     1
  } // 25 bytes

  Obj := DSON.Builder
         .StartObject
         .AddPropertyName('prop')
         .AddValue(True)
         .AddPropertyName('prop2')
         .AddValue(False)
         .EndObject.DSONObject;
  Bytes := DSON.BinaryWriter.WriteObject(Obj);
  Assert.AreEqual(25,Length(Bytes));

  Assert.AreEqual(dmTrue,TDSONMarker(Bytes[10]));
  Assert.AreEqual(dmFalse,TDSONMarker(Bytes[22]));
end;

procedure BinaryWriterTests.WritesDates;
var
  Bytes: TBytes;
  Obj: IDSONObject;
begin
  {
  dmStartObject   1
    dmStartPair   1
      Name length 4
      Name string 4
      dmDateTime  1
      Value       8 byte integer (Unix date)
    dmEndPair     1
  dmEndObject     1
  } // 21 bytes

  Obj := DSON.Builder
         .StartObject
         .AddPropertyName('prop')
         .AddValue(Now())
         .EndObject.DSONObject;
  Bytes := DSON.BinaryWriter.WriteObject(Obj);
  Assert.AreEqual(21,Length(Bytes));
end;

procedure BinaryWriterTests.WritesGUIDs;
var
  Bytes: TBytes;
  Obj: IDSONObject;
begin
  {
  dmStartObject   1
    dmStartPair   1
      Name length 4
      Name string 4
      dmDateTime  1
      Value       16 byte GUID
    dmEndPair     1
  dmEndObject     1
  } // 29 bytes
  Obj := DSON.Builder
         .StartObject
         .AddPropertyName('prop')
         .AddValue(TGUID.NewGuid)
         .EndObject.DSONObject;
  Bytes := DSON.BinaryWriter.WriteObject(Obj);
  Assert.AreEqual(29,Length(Bytes));

  Assert.AreEqual(dmGUID,TDSONMarker(Bytes[10]));
end;

procedure BinaryWriterTests.WritesNil;
var
  Bytes: TBytes;
  Obj: IDSONObject;
begin
  {
  dmStartObject   1
    dmStartPair   1
      Name length 4
      Name string 4
      dmNil       1
      Value       [Empty for Nil]
    dmEndPair     1
  dmEndObject     1
  } // 13 bytes

  Obj := DSON.Builder
         .StartObject
         .AddPropertyName('prop')
         .AddNilValue
         .EndObject.DSONObject;
  Bytes := DSON.BinaryWriter.WriteObject(Obj);
  Assert.AreEqual(13,Length(Bytes));

  Assert.AreEqual(dmNil,TDSONMarker(Bytes[10]));
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

procedure JSONWriterTests.WritesArrays;
var
  ActualJSON: string;
  ExpectedJSON: string;
  Obj: IDSONObject;
begin
  // Simple Array
  ExpectedJSON :=
    '{"prop":[1,2,3]}';
  Obj := DSON.Builder
         .StartObject
           .AddPropertyName('prop')
           .StartArray
             .AddValue(1)
             .AddValue(2)
             .AddValue(3)
           .EndArray
         .EndObject.DSONObject;
  ActualJSON := DSON.JSONWriter.WriteObject(Obj);
  Assert.AreEqual(ExpectedJSON, ActualJSON);

  // Array of arrays
  ExpectedJSON :=
    '{"prop":[[1,2,3],[4,5,6]]}';
  Obj := DSON.Builder
         .StartObject
           .AddPropertyName('prop')
           .StartArray
             .StartArray
               .AddValue(1)
               .AddValue(2)
               .AddValue(3)
             .EndArray
             .StartArray
               .AddValue(4)
               .AddValue(5)
               .AddValue(6)
             .EndArray
           .EndArray
         .EndObject.DSONObject;
  ActualJSON := DSON.JSONWriter.WriteObject(Obj);
  Assert.AreEqual(ExpectedJSON, ActualJSON);
end;

procedure JSONWriterTests.WritesBooleans;
var
  ActualJSON: string;
  ExpectedJSON: string;
  Obj: IDSONObject;
begin
  ExpectedJSON :=
    '{"prop":true}';
  Obj := DSON.Builder.StartObject.AddPropertyName('prop').AddValue(True).EndObject.DSONObject;
  ActualJSON := DSON.JSONWriter.WriteObject(Obj);
  Assert.AreEqual(ExpectedJSON, ActualJSON);
end;

procedure JSONWriterTests.WritesDates;
var
  ActualJSON: string;
  ExpectedJSON: string;
  Obj: IDSONObject;
begin
  ExpectedJSON :=
    '{"prop":"' + DateToISO8601(FDateTime,False) + '"}';
  Obj := DSON.Builder.StartObject.AddPropertyName('prop').AddValue(FDateTime).EndObject.DSONObject;
  ActualJSON := DSON.JSONWriter.WriteObject(Obj);
  Assert.AreEqual(ExpectedJSON, ActualJSON);
end;

procedure JSONWriterTests.WritesGUIDs;
var
  ActualJSON: string;
  ExpectedJSON: string;
  Obj: IDSONObject;
begin
  ExpectedJSON :=
    '{"prop":"{11111111-2222-3333-4444-555555555555}"}';
  Obj := DSON.Builder.StartObject.AddPropertyName('prop').AddValue(TGUID.Create('{11111111-2222-3333-4444-555555555555}')).EndObject.DSONObject;
  ActualJSON := DSON.JSONWriter.WriteObject(Obj);
  Assert.AreEqual(ExpectedJSON, ActualJSON);
end;

procedure JSONWriterTests.WritesNil;
var
  ActualJSON: string;
  ExpectedJSON: string;
  Obj: IDSONObject;
begin
  ExpectedJSON :=
    '{"prop":null}';
  Obj := DSON.Builder.StartObject.AddPropertyName('prop').AddNilValue.EndObject.DSONObject;
  ActualJSON := DSON.JSONWriter.WriteObject(Obj);
  Assert.AreEqual(ExpectedJSON, ActualJSON);
end;

procedure JSONWriterTests.WritesNumerics;
var
  ActualJSON: string;
  ExpectedJSON: string;
  Obj: IDSONObject;
begin
  // Byte
  ExpectedJSON :=
    '{"prop":65}';
  Obj := DSON.Builder.StartObject.AddPropertyName('prop').AddValue(Byte(65)).EndObject.DSONObject;
  ActualJSON := DSON.JSONWriter.WriteObject(Obj);
  Assert.AreEqual(ExpectedJSON, ActualJSON);

  // Int16
  ExpectedJSON :=
    '{"prop":16}';
  Obj := DSON.Builder.StartObject.AddPropertyName('prop').AddValue(Int16(16)).EndObject.DSONObject;
  ActualJSON := DSON.JSONWriter.WriteObject(Obj);
  Assert.AreEqual(ExpectedJSON, ActualJSON);

  // Int32
  ExpectedJSON :=
    '{"prop":32}';
  Obj := DSON.Builder.StartObject.AddPropertyName('prop').AddValue(Int32(32)).EndObject.DSONObject;
  ActualJSON := DSON.JSONWriter.WriteObject(Obj);
  Assert.AreEqual(ExpectedJSON, ActualJSON);

  // Int64
  ExpectedJSON :=
    '{"prop":64}';
  Obj := DSON.Builder.StartObject.AddPropertyName('prop').AddValue(Int64(64)).EndObject.DSONObject;
  ActualJSON := DSON.JSONWriter.WriteObject(Obj);
  Assert.AreEqual(ExpectedJSON, ActualJSON);

  // Single
  ExpectedJSON :=
    '{"prop":1.10000002384186}'; // Single type has terrible precision
  Obj := DSON.Builder.StartObject.AddPropertyName('prop').AddValue(Single(1.1)).EndObject.DSONObject;
  ActualJSON := DSON.JSONWriter.WriteObject(Obj);
  Assert.AreEqual(ExpectedJSON, ActualJSON);

  // Double
  ExpectedJSON :=
    '{"prop":2.2}'; // Single type has terrible precision
  Obj := DSON.Builder.StartObject.AddPropertyName('prop').AddValue(Double(2.2)).EndObject.DSONObject;
  ActualJSON := DSON.JSONWriter.WriteObject(Obj);
  Assert.AreEqual(ExpectedJSON, ActualJSON);

  // Extended
  ExpectedJSON :=
    '{"prop":3.3}';
  Obj := DSON.Builder.StartObject.AddPropertyName('prop').AddValue(Extended(3.3)).EndObject.DSONObject;
  ActualJSON := DSON.JSONWriter.WriteObject(Obj);
  Assert.AreEqual(ExpectedJSON, ActualJSON);
end;

procedure JSONWriterTests.WritesStrings;
var
  ActualJSON: string;
  ExpectedJSON: string;
  Obj: IDSONObject;
begin
  ExpectedJSON :=
    '{"prop":"The quick brown fox jumped over the lazy dogs"}';
  Obj := DSON.Builder.StartObject.AddPropertyName('prop').AddValue('The quick brown fox jumped over the lazy dogs').EndObject.DSONObject;
  ActualJSON := DSON.JSONWriter.WriteObject(Obj);
  Assert.AreEqual(ExpectedJSON, ActualJSON);
end;

initialization

TDUnitX.RegisterTestFixture(BuilderTests);
TDUnitX.RegisterTestFixture(ReaderTests);
TDUnitX.RegisterTestFixture(BinaryWriterTests);
TDUnitX.RegisterTestFixture(JSONWriterTests);

end.
