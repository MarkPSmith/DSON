/// <summary>
///   DSON is a customized version of BSON that more closely represents
///   internal Delphi data types.
/// </summary>
unit DSON;

interface

uses
  System.Rtti,
  System.Generics.Defaults,
  System.SysUtils,
  System.Classes,
  System.Generics.Collections;

type

  TDSONKind = (dkNil, dkByte, dkInt16, dkInt32, dkInt64, dkString, dkSingle, dkDouble, dkExtended, dkChar, dkTrue,
    dkFalse, dkEnum, dkDateTime, dkArray, dkObject, dkGUID, dkRecord, dkPair);

  TDSONMarker = (dmNil, dmByte, dmInt16, dmInt32, dmInt64, dmString, dmSingle, dmDouble, dmExtended, dmChar, dmTrue,
    dmFalse, dmEnum, dmDateTime, dmStartPair, dmEndPair, dmStartArray, dmEndArray, dmStartObject, dmEndObject, dmGUID, dmRecord);

{$REGION 'Interfaces'}
  /// <summary>
  ///   Base DSON value
  /// </summary>
  IDSONValue = interface(IInterface)
    ['{FD12E23B-DAB3-40BC-A619-8C996197B04B}']
    function GetKind: TDSONKind;
    procedure SetKind(const Value: TDSONKind);
    property Kind: TDSONKind read GetKind write SetKind;
  end;

  /// <summary>
  ///   Simple value (ordinals / strings)
  /// </summary>
  IDSONSimple = interface(IDSONValue)
  ['{1949DF4F-4356-427A-95CC-F286F1595D63}']
    function GetValue: TValue;
    property Value: TValue read GetValue;
  end;

  /// <summary>
  ///   Array value
  /// </summary>
  IDSONArray = interface(IDSONValue)
  ['{D98F4AA9-F567-4454-BA41-CBD261002F27}']
    procedure AddArrayValue(const AValue: IDSONValue);
    function GetValues: TArray<IDSONValue>;
    property Values: TArray<IDSONValue> read GetValues;
  end;

  /// <summary>
  ///   DSON Name, Value pair
  /// </summary>
  IDSONPair = interface(IInterface)
    ['{AB0D4072-4236-45E0-BD08-22A09DDBA55E}']
    function GetName: string;
    function GetValue: IDSONValue;
    procedure SetName(const Value: string);
    procedure SetValue(const Value: IDSONValue);
    property Name: string read GetName write SetName;
    property Value: IDSONValue read GetValue write SetValue;
  end;

  /// <summary>
  ///   DSON Object, contains DSON pairs
  /// </summary>
  IDSONObject = interface(IDSONValue)
    ['{877D8139-73A5-4B0A-B4D6-AE2BFE0E18CC}']
    procedure AddPair(const APair: IDSONPair); overload;
    procedure AddPair(const AName: string; AValue: IDSONValue); overload;
    function GetPairs: TList<IDSONPair>;
    property Pairs: TList<IDSONPair> read GetPairs;
  end;

  /// <summary>
  ///   DSON Builder
  /// </summary>
  /// <remarks>
  ///   Can be used fluently or not.
  /// </remarks>
  /// <example>
  ///   <para>
  ///     Fluent Example: <br /><c>
  ///     Builder.AddPropertyName("foo").AddValue("bar");</c>
  ///   </para>
  ///   <para>
  ///     Non-fluent example: <br /><c>Builder.AddPropertyName("foo");
  ///     Builder.AddValue("bar");</c>
  ///   </para>
  /// </example>
  IDSONBuilder = interface(IInterface)
    ['{0C10A42D-E7A1-4F42-821D-15C81369E196}']
    function StartObject: IDSONBuilder;
    function EndObject: IDSONBuilder;
    function StartArray: IDSONBuilder;
    function EndArray: IDSONBuilder;
    function AddPropertyName(const AName: string): IDSONBuilder;
    { TODO: null values! }
    function AddNilValue: IDSONBuilder;
    function AddValue(const AValue: Shortint): IDSONBuilder; overload;
    function AddValue(const AValue: Smallint): IDSONBuilder; overload;
    function AddValue(const AValue: Integer): IDSONBuilder; overload;
    function AddValue(const AValue: Byte): IDSONBuilder; overload;
    function AddValue(const AValue: Word): IDSONBuilder; overload;
    function AddValue(const AValue: Cardinal): IDSONBuilder; overload;
    function AddValue(const AValue: Int64): IDSONBuilder; overload;
    function AddValue(const AValue: UInt64): IDSONBuilder; overload;
    function AddValue(const AValue: string): IDSONBuilder; overload;
    function AddValue(const AValue: Single): IDSONBuilder; overload;
    function AddValue(const AValue: Double): IDSONBuilder; overload;
    function AddValue(const AValue: Extended): IDSONBuilder; overload;
    function AddValue(const AValue: Char): IDSONBuilder; overload;
    function AddValue(const AValue: Boolean): IDSONBuilder; overload;
    function AddValue(const AValue: TGUID): IDSONBuilder; overload;
    function AddValue(const AValue: TDateTime): IDSONBuilder; overload;
    function GetDSONOBject: IDSONObject;
    property DSONObject: IDSONObject read GetDSONOBject;
  end;

  IDSONReader = interface(IInterface)
    ['{E924CEE7-0A79-423A-B12F-94919C56F5C9}']
    function ReadObject(AStream: TStream): IDSONObject;
  end;

  IDSONWriter = interface(IInterface)
    ['{591492B5-567E-49B6-9182-0B8F40941298}']
  end;

  /// <summary>
  ///   Writes the DSON object to a stream
  /// </summary>
  /// <remarks>
  ///   <para>
  ///     The object is written in the following format:
  ///   </para>
  ///   <para>
  ///     [dmStartObject Marker] <br />[Pair] <br />[Pair] <br />... <br />
  ///     [dmEndObjectMarker]
  ///   </para>
  ///   <para>
  ///     Pairs are made up of a name and a value. They are written as
  ///     follows:
  ///   </para>
  ///   <para>
  ///     [dmStartPair marker] <br />[ValueType marker] <br />[Name length
  ///     (integer)][Name] <br />[Value] <br />[dmEndPair marker]
  ///   </para>
  ///   <para>
  ///     Values can be simple or complex. Fixed size values are written
  ///     unadorned, with the ValueType marker determining the byte size.
  ///     Strings are written with the length of the string first (integer)
  ///     followed by the string itself.
  ///   </para>
  ///   <para>
  ///     Objects are written as above.
  ///   </para>
  ///   <para>
  ///     Arrays are written as follows:
  ///   </para>
  ///   <para>
  ///     [dmStartArray Marker] <br />[Value] <br />[Value] <br />... <br />
  ///     [dmEndArray Marker]
  ///   </para>
  /// </remarks>
  IDSONBinaryWriter = interface(IDSONWriter)
    ['{E28B11BE-70E3-48D7-90EC-8BDEF156CE71}']
    function WriteObject(const ADsonObject: IDSONObject): TBytes;
    procedure WriteObjectToStream(const ADsonObject: IDSONObject; const AStream: TStream);
  end;

  /// <summary>
  ///   Writes a DSON object to a JSON string. This will of course be lossy.
  /// </summary>
  IDSONJSONWriter = interface(IDSONWriter)
  ['{37C6D77D-E9AE-4A64-AB0C-76F212731F6A}']
    function WriteObject(const ADsonObject: IDSONObject): string;
  end;
{$ENDREGION}

{$REGION 'Implementations'}
  TDSONValue = class(TInterfacedObject, IDSONValue)
    strict protected
      FKind: TDSONKind;
      function GetKind: TDSONKind;
      procedure SetKind(const Value: TDSONKind);
  end;

  TDSONSimple = class(TDSONValue, IDSONSimple)
  strict private
      FValue: TValue;
      function DSONKindFromValue(const AValue: TValue): TDSONKind;
      function GetValue: TValue;
  public
      constructor CreateNil;
      constructor Create(const AValue: Boolean); overload;
      constructor Create(const AValue: Byte); overload;
      constructor Create(const AValue: Char); overload;
      constructor Create(const AValue: Cardinal); overload;
      constructor Create(const AValue: Double); overload;
      constructor Create(const AValue: Extended); overload;
      constructor Create(const AValue: Integer); overload;
      constructor Create(const AValue: Shortint); overload;
      constructor Create(const AValue: Int64); overload;
      constructor Create(const AValue: Smallint); overload;
      constructor Create(const AValue: string); overload;
      constructor Create(const AValue: Single); overload;
      constructor Create(const AValue: TDateTime); overload;
      constructor Create(const AValue: TGUID); overload;
      constructor Create(const AValue: TValue); overload;
      constructor Create(const AValue: UInt64); overload;
      constructor Create(const AValue: Word); overload;
  end;

  TDSONArray = class(TDSONValue, IDSONArray)
    strict private
      FValues: TArray<IDSONValue>;
      function GetValues: TArray<IDSONValue>;
    public
      constructor Create;
      procedure AddArrayValue(const AValue: IDSONValue);
  end;

  TDSONPair = class(TDSONValue, IDSONPair)
    strict private
      FName: string;
      FValue: IDSONValue;
      function GetName: string;
      function GetValue: IDSONValue;
      procedure SetName(const Value: string);
      procedure SetValue(const Value: IDSONValue);
    public
      constructor Create(const AName: string; const AValue: IDSONValue);
  end;

  { TODO: This is only needed if I decide to implement sorted output }
  TDSONPairNameComparer = class(TComparer<IDSONPair>)
    public
      function Compare(const Left, Right: IDSONPair): Integer; override;
  end;

  TDSONObject = class(TDSONValue, IDSONObject)
    strict private
      FPairs: TList<IDSONPair>;
    public
      constructor Create;
      procedure AddPair(const APair: IDSONPair); overload;
      procedure AddPair(const AName: string; AValue: IDSONValue); overload;
      function GetPairs: TList<IDSONPair>;
      destructor Destroy; override;
  end;

  TDSONBuilder = class(TInterfacedObject, IDSONBuilder)
  strict private
    type
      TBuilderState = (bsError, bsReady, bsExpectingValue, bsBuildingObject, bsBuildingArray);
  strict private
      FDsonObject: IDSONObject;
      FNameStack: TStack<string>;
      FStateStack: TStack<TBuilderState>;
      FValueStack: TStack<IDSONValue>;
      function AddPair(const AName, AValue: string): IDSONBuilder;
      function ArrayIsOnValueStack: Boolean;
      function CurrentState: TBuilderState;
      procedure FinalizeArrayValue;
      procedure FinalizeObjectValue;
      procedure FinalizeSimpleValue;
      function GetDSONOBject: IDSONObject;
      function GetState: TBuilderState;
      function ObjectIsOnValueStack: Boolean;
      function PopPair: IDSONPair;
      property State: TBuilderState read GetState;
  public
      constructor Create;
      destructor Destroy; override;
      function AddPropertyName(const AName: string): IDSONBuilder;
      function AddNilValue: IDSONBuilder;
      function AddValue(const AValue: Boolean): IDSONBuilder; overload;
      function AddValue(const AValue: Byte): IDSONBuilder; overload;
      function AddValue(const AValue: Char): IDSONBuilder; overload;
      function AddValue(const AValue: Cardinal): IDSONBuilder; overload;
      function AddValue(const AValue: Double): IDSONBuilder; overload;
      function AddValue(const AValue: Extended): IDSONBuilder; overload;
      function AddValue(const AValue: Integer): IDSONBuilder; overload;
      function AddValue(const AValue: Shortint): IDSONBuilder; overload;
      function AddValue(const AValue: Int64): IDSONBuilder; overload;
      function AddValue(const AValue: Smallint): IDSONBuilder; overload;
      function AddValue(const AValue: string): IDSONBuilder; overload;
      function AddValue(const AValue: Single): IDSONBuilder; overload;
      function AddValue(const AValue: TDateTime): IDSONBuilder; overload;
      function AddValue(const AValue: TGUID): IDSONBuilder; overload;
      function AddValue(const AValue: UInt64): IDSONBuilder; overload;
      function AddValue(const AValue: Word): IDSONBuilder; overload;
      function StartArray: IDSONBuilder;
      function EndArray: IDSONBuilder;
      function StartObject: IDSONBuilder;
      function EndObject: IDSONBuilder;
      property DSONObject: IDSONObject read GetDSONOBject;
  end;

  TDSONWriter = class abstract(TInterfacedObject, IDSONWriter)
  strict protected
      FStream: TStream;
      procedure InternalWriteArrayValue(const Value: IDSONArray); virtual; abstract;
      procedure InternalWriteBuffer(const Buffer: pointer; ACount: Integer); virtual; abstract;
      procedure InternalWriteDateTime(const Value: IDSONSimple); virtual; abstract;
      procedure InternalWriteGuidValue(const Value: IDSONSimple); virtual; abstract;
      procedure InternalWriteMarker(const AMarker: TDSONMarker); virtual; abstract;
      procedure InternalWriteName(const AName: string); virtual; abstract;
      procedure InternalWriteObject(const ADsonObject: IDSONObject); virtual; abstract;
      procedure InternalWriteSimpleValue(const Value: IDSONSimple); virtual; abstract;
      procedure InternalWriteString(const AValue: string); virtual; abstract;
      function MarkerForSimpleKind(ADsonKind: TDSONKind): TDSONMarker;
      procedure WriteArrayValue(const Value: IDSONArray);
      procedure WriteBuffer(const Buffer: pointer; ACount: Integer);
      procedure WriteDateTime(const Value: IDSONSimple);
      procedure WriteGUIDValue(const Value: IDSONSimple);
      procedure WriteMarker(const AMarker: TDSONMarker);
      procedure WriteName(const AName: string); virtual;
      procedure WritePair(const APair: IDSONPair);
      procedure WriteSimpleValue(const Value: IDSONSimple);
      procedure WriteString(const AValue: string);
      procedure WriteValue(const Value: IDSONValue);
  public
      procedure WriteObjectToStream(const ADsonObject: IDSONObject; const AStream: TStream);
  end;

  TDSONBinaryWriter = class(TDSONWriter, IDSONBinaryWriter)
  strict private
      procedure WriteExtended(const AValue: TValue);
  private
  strict protected
      procedure InternalWriteArrayValue(const Value: IDSONArray); override;
      procedure InternalWriteBuffer(const Buffer: pointer; ACount: Integer); override;
      procedure InternalWriteDateTime(const Value: IDSONSimple); override;
      procedure InternalWriteGuidValue(const Value: IDSONSimple); override;
      procedure InternalWriteMarker(const AMarker: TDSONMarker); override;
      procedure InternalWriteName(const AName: string); override;
      procedure InternalWriteObject(const ADsonObject: IDSONObject); override;
      procedure InternalWriteSimpleValue(const Value: IDSONSimple); override;
      procedure InternalWriteString(const AValue: string); override;
  public
      function WriteObject(const ADsonObject: IDSONObject): TBytes;
  end;

  TDSONJSONWriter = class(TDSONWriter, IDSONJSONWriter)
  strict private
      function DoubleQuoted(const AString: string): String;
      function MarkerToString(const AMarker: TDSONMarker): string;
  strict protected
      procedure InternalWriteArrayValue(const Value: IDSONArray); override;
      procedure InternalWriteBuffer(const Buffer: pointer; ACount: Integer); override;
      procedure InternalWriteDateTime(const Value: IDSONSimple); override;
      procedure InternalWriteGuidValue(const Value: IDSONSimple); override;
      procedure InternalWriteMarker(const AMarker: TDSONMarker); override;
      procedure InternalWriteName(const AName: string); override;
      procedure InternalWriteObject(const ADsonObject: IDSONObject); override;
      procedure InternalWriteSimpleValue(const Value: IDSONSimple); override;
      procedure InternalWriteString(const AValue: string); override;
  public
      function WriteObject(const ADsonObject: IDSONObject): string;
  end;

  TDSONReader = class(TInterfacedObject, IDSONReader)
    strict private
    type
      TReaderState = (rsError, rsReady, rsExpectingValue, rsReadingObject, rsReadingArray);
    strict private
      FStateStack: TStack<TReaderState>;
      FStream: TStream;
      function PeekMarker: TDSONMarker;
      function ReadArray: IDSONArray;
      function ReadDateTime: IDSONValue;
      function ReadExtended: IDSONValue;
      function ReadGUID: IDSONValue;
      function ReadPair: TDSONPair;
      function ReadPropertyName: string;
      function ReadSimple<T>: IDSONSimple;
      function ReadString: string;
      function ReadValue: IDSONValue;
    strict protected
      function ReadMarker: TDSONMarker; virtual;
    public
      constructor Create;
      function ReadObject: IDSONObject; overload;
      function ReadObject(AStream: TStream): IDSONObject; overload;
      destructor Destroy; override;
  end;
{$ENDREGION}

function BinaryWriter: IDSONBinaryWriter;
function Builder: IDSONBuilder;
function JSONWriter: IDSONJSONWriter;
function Reader: IDSONReader;

implementation

uses
  System.DateUtils;

function Reader: IDSONReader;
begin
  Result := TDSONReader.Create;
end;

function BinaryWriter: IDSONBinaryWriter;
begin
  Result := TDSONBinaryWriter.Create;
end;

function JSONWriter: IDSONJSONWriter;
begin
  Result := TDSONJSONWriter.Create;
end;

function Builder: IDSONBuilder;
begin
  Result := TDSONBuilder.Create;
end;

constructor TDSONPair.Create(const AName: string; const AValue: IDSONValue);
begin
  FName := AName;
  FValue := AValue;
  FKind := dkPair;
end;

function TDSONPair.GetName: string;
begin
  Result := FName;
end;

function TDSONPair.GetValue: IDSONValue;
begin
  Result := FValue;
end;

procedure TDSONPair.SetName(const Value: string);
begin
  FName := Value;
end;

procedure TDSONPair.SetValue(const Value: IDSONValue);
begin
  FValue := Value;
end;

procedure TDSONObject.AddPair(const AName: string; AValue: IDSONValue);
begin
  AddPair(TDSONPair.Create(AName, AValue));
end;

procedure TDSONObject.AddPair(const APair: IDSONPair);
begin
  FPairs.Add(APair);
end;

constructor TDSONObject.Create;
begin
  FKind := dkObject;
  FPairs := TList<IDSONPair>.Create(TDSONPairNameComparer.Create);
end;

destructor TDSONObject.Destroy;
begin
  FPairs.Free;
  inherited;
end;

function TDSONObject.GetPairs: TList<IDSONPair>;
begin
  Result := FPairs;
end;

{TDSONPairNameComparer}

function TDSONPairNameComparer.Compare(const Left, Right: IDSONPair): Integer;
begin
  Result := CompareText(Left.Name, Right.Name);
end;

procedure TDSONBinaryWriter.InternalWriteArrayValue(const Value: IDSONArray);
var
  ArrayValue: IDSONValue;
begin
  WriteMarker(dmStartArray);
  for ArrayValue in Value.Values do
    begin
      WriteValue(ArrayValue);
    end;
  WriteMarker(dmEndArray);
end;

procedure TDSONBinaryWriter.InternalWriteBuffer(const Buffer: pointer; ACount: Integer);
begin
  FStream.Write(Buffer^, ACount);
end;

procedure TDSONBinaryWriter.InternalWriteDateTime(const Value: IDSONSimple);
var
  UnixDate: Int64;
begin
  UnixDate := Value.Value.AsInt64;
  FStream.Write(UnixDate, Sizeof(Int64));
end;

procedure TDSONBinaryWriter.InternalWriteGuidValue(const Value: IDSONSimple);
var
  GUID: TGUID;
  GUIDBytes: TBytes;
begin
  {internally this is stored as a GUID string.
   When writing binary, write the 16 actual GUID bytes}
  GUID := TGUID.Create(Value.Value.AsString);
  GUIDBytes := GUID.ToByteArray;
  FStream.Write(GUIDBytes[0], Length(GUIDBytes));
end;

procedure TDSONBinaryWriter.InternalWriteMarker(const AMarker: TDSONMarker);
begin
  FStream.Write(AMarker, Sizeof(TDSONMarker));
end;

procedure TDSONBinaryWriter.InternalWriteName(const AName: string);
begin
  WriteString(AName);
end;

procedure TDSONBinaryWriter.InternalWriteObject(const ADsonObject: IDSONObject);
var
  Pair: IDSONPair;
begin
  WriteMarker(dmStartObject);
  for Pair in ADsonObject.Pairs do
    begin
      WritePair(Pair);
    end;
  WriteMarker(dmEndObject);
end;

procedure TDSONBinaryWriter.InternalWriteSimpleValue(const Value: IDSONSimple);
var
  Buffer: pointer;
begin
  WriteMarker(MarkerForSimpleKind(Value.Kind));
  Buffer := Value.Value.GetReferenceToRawData;
  // Null, true and false are fully represented by the marker, nothing else needs to be written.
  case Value.Kind of
    dkNil:
      exit;
    dkByte:
      WriteBuffer(Buffer, 1);
    dkInt16:
      WriteBuffer(Buffer, 2);
    dkInt32:
      WriteBuffer(Buffer, 4);
    dkInt64:
      WriteBuffer(Buffer, 8);
    dkString:
      WriteString(Value.Value.AsString);
    dkSingle:
      WriteBuffer(Buffer, Sizeof(Single));
    dkDouble:
      WriteBuffer(Buffer, Sizeof(Double));
    dkExtended:
      WriteExtended(Value.Value);
    dkChar:
      WriteBuffer(Buffer, Sizeof(Char));
    dkTrue:
      exit;
    dkFalse:
      exit;
    dkEnum:
      raise Exception.Create('Enums not supported');
    {internally this is a unix date int64}
    dkDateTime:
      WriteDateTime(Value);
    dkGUID:
      WriteGUIDValue(Value);
    dkRecord:
      raise Exception.Create('Records not supported');
  end;
end;

procedure TDSONBinaryWriter.InternalWriteString(const AValue: string);
var
  Bytes: TBytes;
  Len: Integer;
begin
  Bytes := TEncoding.UTF8.GetBytes(AValue);
  Len := Length(Bytes);
  FStream.Write(Len, Sizeof(Integer));
  FStream.Write(Bytes[0], Length(Bytes));
end;

procedure TDSONBinaryWriter.WriteExtended(const AValue: TValue);
var
  Dbl: Double;
begin
  // I don't like it but until I figure out a better way, Extended must be forced to Double
  // because Extended is so many different sizes on all platforms.
  Dbl := Double(AValue.AsExtended);
  FStream.Write(Dbl,Sizeof(Double));
end;

function TDSONBinaryWriter.WriteObject(const ADsonObject: IDSONObject): TBytes;
var
  BS: TBytesStream;
begin
  BS := TBytesStream.Create;
  try
    WriteObjectToStream(ADsonObject, BS);
    SetLength(Result, BS.Size);
    Move(BS.Bytes[0], Result[0], BS.Size);
  finally
    BS.Free;
  end;
end;

constructor TDSONSimple.Create(const AValue: Boolean);
begin
  if AValue then
    FKind := dkTrue
  else
    FKind := dkFalse;
  FValue := TValue.From(AValue);
end;

constructor TDSONSimple.Create(const AValue: Byte);
begin
  FKind := dkByte;
  FValue := TValue.From(AValue);
end;

constructor TDSONSimple.Create(const AValue: Char);
begin
  FKind := dkChar;
  FValue := TValue.From(AValue);
end;

constructor TDSONSimple.Create(const AValue: Cardinal);
begin
  FKind := dkInt32;
  FValue := TValue.From(AValue);
end;

constructor TDSONSimple.Create(const AValue: Double);
begin
  FKind := dkDouble;
  FValue := TValue.From(AValue);
end;

constructor TDSONSimple.Create(const AValue: Extended);
begin
  FKind := dkExtended;
  FValue := TValue.From(AValue);
end;

constructor TDSONSimple.Create(const AValue: Integer);
begin
  FKind := dkInt32;
  FValue := TValue.From(AValue);
end;

constructor TDSONSimple.Create(const AValue: Shortint);
begin
  FKind := dkByte;
  FValue := TValue.From(AValue);
end;

{TDSONSimple}

constructor TDSONSimple.Create(const AValue: Int64);
begin
  FKind := dkInt64;
  FValue := TValue.From(AValue);
end;

constructor TDSONSimple.Create(const AValue: Smallint);
begin
  FKind := dkInt16;
  FValue := TValue.From(AValue);
end;

constructor TDSONSimple.Create(const AValue: string);
begin
  FKind := dkString;
  FValue := TValue.From(AValue);
end;

constructor TDSONSimple.Create(const AValue: Single);
begin
  FKind := dkSingle;
  FValue := TValue.From(AValue);
end;

constructor TDSONSimple.Create(const AValue: TDateTime);
begin
  FKind := dkDateTime;
  {internal storage format is unix time}
  FValue := TValue.From(DateTimeToUnix(AValue));
end;

constructor TDSONSimple.Create(const AValue: TGUID);
begin
  FKind := dkGUID;
  {internal guid storage is a guid string}
  FValue := TValue.From(AValue.ToString);
end;

constructor TDSONSimple.Create(const AValue: TValue);
begin
  FKind := DSONKindFromValue(AValue);
  FValue := AValue;
end;

constructor TDSONSimple.Create(const AValue: UInt64);
begin
  FKind := dkInt64;
  FValue := TValue.From(AValue);
end;

constructor TDSONSimple.Create(const AValue: Word);
begin
  FKind := dkInt16;
  FValue := TValue.From(AValue);
end;

constructor TDSONSimple.CreateNil;
begin
  FKind := dkNil;
  FValue := TValue.From(nil);
end;

function TDSONSimple.DSONKindFromValue(const AValue: TValue): TDSONKind;
begin
  case AValue.Kind of
    tkUnknown, tkSet, tkClass, tkMethod, tkVariant, tkArray, tkRecord, tkInterface, tkDynArray, tkClassRef, tkPointer, tkProcedure:
      raise Exception.Create('Too complex for a simple DSON type');
    tkInteger: begin
      case AValue.DataSize of
        1: Result := dkByte;
        2: Result := dkInt16;
        4: Result := dkInt32;
      end;
    end;
    tkChar: Result := dkChar;
    tkEnumeration: raise Exception.Create('Enums not supported yet');
    tkFloat: begin
      case AValue.DataSize of
        4: Result := dkSingle;
        8: Result := dkDouble;
      end;
    end;
    tkString, tkLString, tkWString, tkUString: Result := dkString;
    tkWChar: Result := dkChar;
    tkInt64: Result := dkInt64;
  end;
end;

function TDSONSimple.GetValue: TValue;
begin
  Result := FValue;
end;

function TDSONValue.GetKind: TDSONKind;
begin
  Result := FKind;
end;

procedure TDSONValue.SetKind(const Value: TDSONKind);
begin
  FKind := Value;
end;

{TDSONArray<T>}

procedure TDSONArray.AddArrayValue(const AValue: IDSONValue);
begin
  SetLength(FValues, Length(FValues) + 1);
  FValues[High(FValues)] := AValue;
end;

constructor TDSONArray.Create;
begin
  FKind := dkArray;
  SetLength(FValues, 0);
end;

function TDSONArray.GetValues: TArray<IDSONValue>;
begin
  Result := FValues;
end;

constructor TDSONBuilder.Create;
begin
  FDsonObject := nil;
  FNameStack := TStack<String>.Create;
  FValueStack := TStack<IDSONValue>.Create;
  FStateStack := TStack<TBuilderState>.Create;
end;

destructor TDSONBuilder.Destroy;
begin
  FStateStack.Free;
  FNameStack.Free;
  FValueStack.Free;
  inherited;
end;

function TDSONBuilder.AddNilValue: IDSONBuilder;
begin
  FValueStack.Push(TDSONSimple.CreateNil);
  FinalizeSimpleValue;
  Result := Self;
end;

function TDSONBuilder.AddPair(const AName, AValue: string): IDSONBuilder;
begin
  FValueStack.Push(TDSONSimple.Create(AValue));
  Result := Self;
end;

function TDSONBuilder.AddPropertyName(const AName: string): IDSONBuilder;
begin
  FNameStack.Push(AName);
  FStateStack.Push(bsExpectingValue);
  Result := Self;
end;

function TDSONBuilder.AddValue(const AValue: Boolean): IDSONBuilder;
begin
  FValueStack.Push(TDSONSimple.Create(AValue));
  FinalizeSimpleValue;
  Result := Self;
end;

function TDSONBuilder.AddValue(const AValue: Byte): IDSONBuilder;
begin
  FValueStack.Push(TDSONSimple.Create(AValue));
  FinalizeSimpleValue;
  Result := Self;
end;

function TDSONBuilder.AddValue(const AValue: Char): IDSONBuilder;
begin
  FValueStack.Push(TDSONSimple.Create(AValue));
  FinalizeSimpleValue;
  Result := Self;
end;

function TDSONBuilder.AddValue(const AValue: Cardinal): IDSONBuilder;
begin
  FValueStack.Push(TDSONSimple.Create(AValue));
  FinalizeSimpleValue;
  Result := Self;
end;

function TDSONBuilder.AddValue(const AValue: Double): IDSONBuilder;
begin
  FValueStack.Push(TDSONSimple.Create(AValue));
  FinalizeSimpleValue;
  Result := Self;
end;

function TDSONBuilder.AddValue(const AValue: Extended): IDSONBuilder;
begin
  FValueStack.Push(TDSONSimple.Create(AValue));
  FinalizeSimpleValue;
  Result := Self;
end;

function TDSONBuilder.AddValue(const AValue: Integer): IDSONBuilder;
begin
  FValueStack.Push(TDSONSimple.Create(AValue));
  FinalizeSimpleValue;
  Result := Self;
end;

{TDSONBuilder}

function TDSONBuilder.AddValue(const AValue: Shortint): IDSONBuilder;
begin
  FValueStack.Push(TDSONSimple.Create(AValue));
  FinalizeSimpleValue;
  Result := Self;
end;

function TDSONBuilder.AddValue(const AValue: Int64): IDSONBuilder;
begin
  FValueStack.Push(TDSONSimple.Create(AValue));
  FinalizeSimpleValue;
  Result := Self;
end;

function TDSONBuilder.AddValue(const AValue: Smallint): IDSONBuilder;
begin
  FValueStack.Push(TDSONSimple.Create(AValue));
  FinalizeSimpleValue;
  Result := Self;
end;

function TDSONBuilder.AddValue(const AValue: string): IDSONBuilder;
begin
  FValueStack.Push(TDSONSimple.Create(AValue));
  FinalizeSimpleValue;
  Result := Self;
end;

function TDSONBuilder.AddValue(const AValue: Single): IDSONBuilder;
begin
  FValueStack.Push(TDSONSimple.Create(AValue));
  FinalizeSimpleValue;
  Result := Self;
end;

function TDSONBuilder.AddValue(const AValue: TDateTime): IDSONBuilder;
begin
  FValueStack.Push(TDSONSimple.Create(AValue));
  FinalizeSimpleValue;
  Result := Self;
end;

function TDSONBuilder.AddValue(const AValue: TGUID): IDSONBuilder;
begin
  FValueStack.Push(TDSONSimple.Create(AValue));
  FinalizeSimpleValue;
  Result := Self;
end;

function TDSONBuilder.AddValue(const AValue: UInt64): IDSONBuilder;
begin
  FValueStack.Push(TDSONSimple.Create(AValue));
  FinalizeSimpleValue;
  Result := Self;
end;

function TDSONBuilder.AddValue(const AValue: Word): IDSONBuilder;
begin
  FValueStack.Push(TDSONSimple.Create(AValue));
  FinalizeSimpleValue;
  Result := Self;
end;

function TDSONBuilder.ArrayIsOnValueStack: Boolean;
begin
  if (FValueStack.Count > 0) then
    Result := Supports(FValueStack.Peek, IDSONArray)
  else
    Result := false;
end;

function TDSONBuilder.CurrentState: TBuilderState;
begin
  if FStateStack.Count = 0 then
    Result := bsReady
  else
    Result := FStateStack.Peek;
end;

function TDSONBuilder.EndArray: IDSONBuilder;
begin
  FinalizeArrayValue;
  Result := Self;
end;

function TDSONBuilder.EndObject: IDSONBuilder;
begin
  FinalizeObjectValue;
  Result := Self;
end;

procedure TDSONBuilder.FinalizeArrayValue;
var
  DArr: IDSONArray;
  DObj: IDSONObject;
  Pair: IDSONPair;
begin
  Pair := PopPair;
  if FStateStack.Peek = bsBuildingArray then
    begin
      if ObjectIsOnValueStack then
        begin
          DObj := FValueStack.Peek as IDSONObject;
          DObj.AddPair(Pair);
        end
      else if ArrayIsOnValueStack then
        begin
          // Array members don't have a property name. Since the property name has already been popped from
          // the name stack, it needs to be put back, and only the value needs to be added to the
          // parent array. This method could be refactored in such a way that only the value is popped.
          DArr := FValueStack.Peek as IDSONArray;
          DArr.AddArrayValue(Pair.Value);
          FNameStack.Push(Pair.Name);
        end
      else
        begin
          FDsonObject.AddPair(Pair);
        end;
      // Gotta pop the stack twice! Once for bsBuildingArray and once for bsExpectingValue
      FStateStack.Pop;
      if State = bsExpectingValue then
        FStateStack.Pop;
    end
  else
    raise Exception.Create('Cannot finalize array unless currently building array');
end;

procedure TDSONBuilder.FinalizeObjectValue;
var
  DArr: IDSONArray;
  DObj: IDSONObject;
  Pair: IDSONPair;
begin
  if FStateStack.Count = 1 then
    begin
      // Finalizing the outer object. Pop the object off the value stack and assign it to FDSONObject.
      FDsonObject := FValueStack.Pop as IDSONObject;
      FStateStack.Pop;
    end
  else
    begin
      if FStateStack.Peek = bsBuildingObject then
        begin
          Pair := PopPair;
          if ObjectIsOnValueStack then
            begin
              DObj := FValueStack.Peek as IDSONObject;
              DObj.AddPair(Pair);
            end
          else if ArrayIsOnValueStack then
            begin
              // Array members don't have a property name. Since the property name has already been popped from
              // the name stack, it needs to be put back, and only the value needs to be added to the
              // parent array. This method could be refactored in such a way that only the value is popped.
              DArr := FValueStack.Peek as IDSONArray;
              DArr.AddArrayValue(Pair.Value);
              FNameStack.Push(Pair.Name);
            end
          else
            begin
              FDsonObject.AddPair(Pair);
            end;
          // Gotta pop the stack twice! Once for bsBuildingObject and once for bsExpectingValue
          FStateStack.Pop;
          if State = bsExpectingValue then
            FStateStack.Pop;
        end
      else
        raise Exception.Create('Cannot finalize object unless currently building object');
    end;
end;

procedure TDSONBuilder.FinalizeSimpleValue;
var
  Obj: IDSONObject;
  Pair: IDSONPair;
  Value: IDSONValue;
begin
  if FStateStack.Peek = bsBuildingArray then
    begin
      Value := FValueStack.Pop;
      with (FValueStack.Peek as IDSONArray) do
        begin
          AddArrayValue(Value);
        end;
    end
  else if FStateStack.Peek = bsExpectingValue then
    begin
      Pair := PopPair;
      Obj := FValueStack.Peek as IDSONObject;
      Obj.AddPair(Pair);
      FStateStack.Pop;
    end
  else
    raise Exception.Create('Invalid builder state');
end;

function TDSONBuilder.GetDSONOBject: IDSONObject;
begin
  Result := FDsonObject;
end;

function TDSONBuilder.GetState: TBuilderState;
begin
  if FStateStack.Count = 0 then
    Result := bsReady
  else
    Result := FStateStack.Peek;
end;

function TDSONBuilder.ObjectIsOnValueStack: Boolean;
begin
  if (FValueStack.Count > 0) then
    Result := Supports(FValueStack.Peek, IDSONObject)
  else
    Result := false;
end;

function TDSONBuilder.PopPair: IDSONPair;
begin
  Result := TDSONPair.Create(FNameStack.Pop, FValueStack.Pop);
end;

function TDSONBuilder.StartArray: IDSONBuilder;
begin
  FValueStack.Push(TDSONArray.Create);
  FStateStack.Push(bsBuildingArray);
  Result := Self;
end;

function TDSONBuilder.StartObject: IDSONBuilder;
begin
  if FStateStack.Count = 0 then
    begin
      // Beginning new object. Clear FDSONObject.
      FDsonObject := nil;
    end;
  FValueStack.Push(TDSONObject.Create);
  FStateStack.Push(bsBuildingObject);
  Result := Self;
end;

function TDSONJSONWriter.DoubleQuoted(const AString: string): String;
begin
  Result := '"' + AString + '"';
end;

{TDSONJSONWriter}

procedure TDSONJSONWriter.InternalWriteArrayValue(const Value: IDSONArray);
var
  ArrayValue: IDSONValue;
  StreamPosition: Int64;
begin
  WriteMarker(dmStartArray);
  StreamPosition := FStream.Position;
  for ArrayValue in Value.Values do
    begin
      WriteValue(ArrayValue);
      WriteString(', ');
    end;
  if FStream.Position > StreamPosition then
    begin
      // Strip off the last comma
      FStream.Position := FStream.Position - 2;
    end;
  WriteMarker(dmEndArray);
end;

procedure TDSONJSONWriter.InternalWriteBuffer(const Buffer: pointer; ACount: Integer);
begin
  FStream.Write(Buffer, ACount);
end;

procedure TDSONJSONWriter.InternalWriteDateTime(const Value: IDSONSimple);
var
  DateString: string;
begin
  DateString := DateToISO8601(UnixToDateTime(Value.Value.AsType<Int64>));
  WriteString(DoubleQuoted(DateString));
end;

procedure TDSONJSONWriter.InternalWriteGuidValue(const Value: IDSONSimple);
begin
  WriteString(DoubleQuoted(Value.Value.AsString));
end;

procedure TDSONJSONWriter.InternalWriteMarker(const AMarker: TDSONMarker);
var
  MarkerStr: String;
begin
  MarkerStr := MarkerToString(AMarker);
  WriteString(MarkerStr);
end;

procedure TDSONJSONWriter.InternalWriteName(const AName: string);
begin
  WriteString(DoubleQuoted(AName) + ': ');
end;

procedure TDSONJSONWriter.InternalWriteObject(const ADsonObject: IDSONObject);
var
  Pair: IDSONPair;
begin
  WriteMarker(dmStartObject);
  for Pair in ADsonObject.Pairs do
    begin
      WritePair(Pair);
      if ADsonObject.Pairs.IndexOf(Pair) < ADsonObject.Pairs.Count - 1 then
        WriteString(',');
    end;
  WriteMarker(dmEndObject);
end;

procedure TDSONJSONWriter.InternalWriteSimpleValue(const Value: IDSONSimple);
begin
  case Value.Kind of
    dkNil:
      WriteString('null');
    dkTrue, dkFalse:
      WriteString(Value.Value.ToString.ToLower);
    dkByte, dkInt16, dkInt32, dkInt64, dkSingle, dkDouble, dkExtended:
      WriteString(Value.Value.ToString);
    dkChar, dkString:
      WriteString(DoubleQuoted(Value.Value.ToString));
    dkEnum:
      raise Exception.Create('Enums not supported');
    dkDateTime:
      WriteDateTime(Value);
    dkGUID:
      WriteGUIDValue(Value);
    dkRecord:
      raise Exception.Create('Records not supported');
  end;
end;

procedure TDSONJSONWriter.InternalWriteString(const AValue: string);
var
  Bytes: TBytes;
begin
  Bytes := TEncoding.UTF8.GetBytes(AValue);
  FStream.Write(Bytes[0], Length(Bytes));
end;

function TDSONJSONWriter.MarkerToString(const AMarker: TDSONMarker): string;
begin
  case AMarker of
    dmNil, dmByte, dmInt16, dmInt32, dmInt64, dmString, dmSingle, dmDouble, dmExtended, dmChar, dmTrue,
      dmFalse, dmGUID:
      Result := '';
    dmEnum:
      raise Exception.Create('Enums not yet supported');
    dmRecord:
      raise Exception.Create('Records not yet supported');
    dmStartArray:
      Result := '[';
    dmEndArray:
      Result := ']';
    dmStartObject:
      Result := '{';
    dmEndObject:
      Result := '}';
  end;
end;

function TDSONJSONWriter.WriteObject(const ADsonObject: IDSONObject): string;
var
  StrStream: TStringStream;
begin
  StrStream := TStringStream.Create;
  try
    WriteObjectToStream(ADsonObject, StrStream);
    Result := StrStream.DataString;
  finally
    StrStream.Free;
  end;
end;

function TDSONWriter.MarkerForSimpleKind(ADsonKind: TDSONKind): TDSONMarker;
begin
  case ADsonKind of
    dkNil:
      exit(dmNil);
    dkByte:
      exit(dmByte);
    dkInt16:
      Result := dmInt16;
    dkInt32:
      Result := dmInt32;
    dkInt64:
      Result := dmInt64;
    dkString:
      Result := dmString;
    dkSingle:
      Result := dmSingle;
    dkDouble:
      Result := dmDouble;
    dkExtended:
      Result := dmExtended;
    dkChar:
      Result := dmChar;
    dkTrue:
      Result := dmTrue;
    dkFalse:
      Result := dmFalse;
    dkEnum:
      Result := dmEnum;
    dkDateTime:
      Result := dmDateTime;
    dkGUID:
      Result := dmGUID;
  end;
end;

procedure TDSONWriter.WriteArrayValue(const Value: IDSONArray);
begin
  InternalWriteArrayValue(Value);
end;

procedure TDSONWriter.WriteBuffer(const Buffer: pointer; ACount: Integer);
begin
  InternalWriteBuffer(Buffer, ACount);
end;

procedure TDSONWriter.WriteDateTime(const Value: IDSONSimple);
var
  UnixDate: Int64;
begin
  InternalWriteDateTime(Value);
end;

procedure TDSONWriter.WriteGUIDValue(const Value: IDSONSimple);
var
  GUID: TGUID;
  GUIDBytes: TBytes;
begin
  InternalWriteGuidValue(Value);
end;

procedure TDSONWriter.WriteMarker(const AMarker: TDSONMarker);
begin
  InternalWriteMarker(AMarker);
end;

procedure TDSONWriter.WriteName(const AName: string);
begin
  InternalWriteName(AName);
end;

procedure TDSONWriter.WriteObjectToStream(const ADsonObject: IDSONObject; const AStream: TStream);
begin
  FStream := AStream;
  InternalWriteObject(ADsonObject);
end;

procedure TDSONWriter.WritePair(const APair: IDSONPair);
var
  Marker: TDSONMarker;
  Name: string;
begin
  WriteMarker(dmStartPair);
  Name := APair.Name; // compiler friendly
  // Write name
  WriteName(Name);
  // Write value
  WriteValue(APair.Value);
  WriteMarker(dmEndPair);
end;

procedure TDSONWriter.WriteSimpleValue(const Value: IDSONSimple);
begin
  InternalWriteSimpleValue(Value);
end;

procedure TDSONWriter.WriteString(const AValue: string);
begin
  InternalWriteString(AValue);
end;

procedure TDSONWriter.WriteValue(const Value: IDSONValue);
var
  Pair: IDSONPair;
begin
  if Supports(Value, IDSONSimple) then
    WriteSimpleValue(Value as IDSONSimple)
  else if Supports(Value, IDSONArray) then
    WriteArrayValue(Value as IDSONArray)
  else if Supports(Value, IDSONObject) then
    WriteObjectToStream(Value as IDSONObject,FStream)
  else if Supports(Value, IDSONPair) then
    begin
      Pair := Value as IDSONPair;
      WriteName(Pair.Name);
      WriteValue(Pair.Value);
    end;
end;

{TDSONReader}

constructor TDSONReader.Create;
begin
  FStateStack := TStack<TReaderState>.Create;
end;

destructor TDSONReader.Destroy;
begin
  FStateStack.Free;
  inherited;
end;

function TDSONReader.PeekMarker: TDSONMarker;
begin
  Result := ReadMarker;
  FStream.Position := FStream.Position - Sizeof(TDSONMarker);
end;

function TDSONReader.ReadArray: IDSONArray;
var
  Value: IDSONValue;
begin
  Result := TDSONArray.Create;
  while PeekMarker <> dmEndArray do
    begin
      Value := ReadValue;
      Result.AddArrayValue(Value);
    end;
  ReadMarker;
end;

function TDSONReader.ReadDateTime: IDSONValue;
var
  Date: TDateTime;
  UnixDate: Int64;
begin
  // Date time is stored as a UNIX 64 bit value.
  FStream.Read(UnixDate,Sizeof(Int64));
  Date := UnixToDateTime(UnixDate);
  Result := TDSONSimple.Create(Date);
end;

function TDSONReader.ReadExtended: IDSONValue;
var
  Dbl: Double;
begin
  // Extended is stored as double due to the wide variety of sizes extended has on different platforms.
  FStream.Read(Dbl,Sizeof(Double));
  Result := TDSONSimple.Create(Extended(Dbl));
end;

function TDSONReader.ReadGUID: IDSONValue;
var
  Bytes: TBytes;
  GUID: TGUID;
begin
  SetLength(Bytes,16);
  FStream.Read(Bytes[0],16);
  GUID := TGUID.Create(Bytes);
  Result := TDSONSimple.Create(GUID);
end;

function TDSONReader.ReadMarker: TDSONMarker;
begin
  FStream.Read(Result, Sizeof(TDSONMarker));
end;

function TDSONReader.ReadObject: IDSONObject;
var
  Marker: TDSONMarker;
  Pair: TDSONPair;
begin
  Marker := ReadMarker;
  if Marker = dmStartObject then
    begin
      Result := TDSONObject.Create;
      while PeekMarker <> dmEndObject do
        begin
          Pair := ReadPair;
          Result.AddPair(Pair);
        end;
      ReadMarker;
    end
  else
    raise Exception.Create('Expected a DSON Object Marker');
end;

function TDSONReader.ReadObject(AStream: TStream): IDSONObject;
begin
  FStream := AStream;
  Result := ReadObject;
end;

function TDSONReader.ReadPair: TDSONPair;
var
  Name: string;
  Value: IDSONValue;
begin
  if ReadMarker <> dmStartPair then
    raise Exception.Create('Expected to read dmStartPair marker');
  Name := ReadPropertyName;
  Value := ReadValue;
  Result := TDSONPair.Create(Name, Value);
  if ReadMarker <> dmEndPair then
    raise Exception.Create('Expected to read dmEndPair marker');
end;

function TDSONReader.ReadPropertyName: string;
begin
  Result := ReadString;
end;

function TDSONReader.ReadSimple<T>: IDSONSimple;
var
  Bytes: TBytes;
  Value: TValue;
begin
  SetLength(Bytes,Sizeof(T));
  FStream.Read(Bytes[0],Sizeof(T));
  TValue.Make(Bytes,TypeInfo(T),Value);
  Result := TDSONSimple.Create(Value);
end;

function TDSONReader.ReadString: string;
var
  Bytes: TBytes;
  Count: Integer;
begin
  FStream.Read(Count, Sizeof(Integer));
  SetLength(Bytes, Count);
  FStream.Read(Bytes[0], Count);
  Result := TEncoding.UTF8.GetString(Bytes);
end;

function TDSONReader.ReadValue: IDSONValue;
var
  Marker: TDSONMarker;
begin
  Marker := ReadMarker;
  case Marker of
    dmNil: Result := TDSONSimple.CreateNil;
    dmByte: Result := ReadSimple<Byte>;
    dmInt16: Result := ReadSimple<Int16>;
    dmInt32: Result := ReadSimple<Int32>;
    dmInt64: Result := ReadSimple<Int64>;
    dmString: Result := TDSONSimple.Create(ReadString);
    dmSingle: Result := ReadSimple<Single>;
    dmDouble: Result := ReadSimple<Double>;
    dmExtended: Result := ReadExtended;
    dmChar: Result := ReadSimple<Char>;
    dmTrue: Result := TDSONSimple.Create(True);
    dmFalse: Result := TDSONSimple.Create(False);
    dmEnum: raise Exception.Create('Enums not supported');
    dmDateTime: Result := ReadDateTime;
    dmStartArray: Result := ReadArray;
    dmEndArray: raise Exception.Create('End-of-array marker should never be read here');
    dmStartObject:
      begin
      // ReadObject expects to read the marker.
      FStream.Position := FStream.Position - Sizeof(TDSONMarker);
      Result := ReadObject;
      end;
    dmEndObject: raise Exception.Create('End-of-object marker should never be read here');
    dmGUID: Result := ReadGUID;
    dmRecord: raise Exception.Create('records not supported') ;
  end;
end;

end.
