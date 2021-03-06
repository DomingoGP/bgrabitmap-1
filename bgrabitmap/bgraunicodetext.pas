unit BGRAUnicodeText;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, BGRABitmapTypes, BGRAUnicode, BGRAUTF8;

type
  TDeleteCharEvent = procedure(ASender: TObject; AParagraphIndex: integer; ACharStart, ACharCount: integer) of object;
  TInsertCharEvent = procedure(ASender: TObject; AParagraphIndex: integer; ACharStart, ACharCount: integer) of object;
  TParagraphEvent = procedure(ASender: TObject; AParagraphIndex: integer) of object;
  TParagraphSplitEvent = procedure(ASender: TObject; AParagraphIndex: integer; ACharIndex: integer) of object;

  { TBidiTree }

  TBidiTree = class
  private
    FParent: TBidiTree;
    FData: pointer;
    FStartIndex, FEndIndex: integer;
    FBidiLevel: byte;
    FBranches: TList;
    FIsLeaf: boolean;
    function GetBranch(AIndex: integer): TBidiTree;
    function GetCount: integer;
  public
    constructor Create(AData: pointer; AStartIndex, AEndIndex: integer; ABidiLevel: byte; AIsLeaf: boolean); virtual;
    destructor Destroy; override;
    procedure AfterFinish; virtual;
    procedure AddBranch(ABranch: TBidiTree); virtual;
    procedure Shorten(AEndIndex: integer); virtual;
    function TrySplit: boolean; virtual;
    property StartIndex: integer read FStartIndex;
    property EndIndex: integer read FEndIndex;
    property BidiLevel: byte read FBidiLevel;
    property Parent: TBidiTree read FParent;
    property IsLeaf: boolean read FIsLeaf;
    property Count: integer read GetCount;
    property Branch[AIndex: integer]: TBidiTree read GetBranch;
    property Data: pointer read FData;
  end;

  TBidiTreeAny = class of TBidiTree;

  { TUnicodeAnalysis }

  TUnicodeAnalysis = class
  private
    FOnBidiModeChanged: TNotifyEvent;
    FOnCharDeleted: TDeleteCharEvent;
    FOnCharInserted: TInsertCharEvent;
    FOnParagraphMergedWithNext: TParagraphEvent;
    FOnParagraphDeleted: TParagraphEvent;
    FOnParagraphSplit: TParagraphSplitEvent;
  protected
    FText: string;
    FCharCount: integer;
    FBidi: TBidiUTF8Array;
    FParagraph: array of record
      firstUnbrokenLineIndex: integer;
    end;
    FParagraphCount: integer;

    FUnbrokenLine: array of record
      startIndex: integer;
      paragraphIndex: integer;
    end;
    FUnbrokenLineCount: integer;

    FBidiMode: TFontBidiMode;
    procedure Analyze;
    procedure CheckTextAnalysis;
    function GetUnbrokenLineParagraphIndex(AIndex: integer): integer;
    function GetUnbrokenLineStartIndex(AIndex: integer): integer;
    function GetUnbrokenLineEndIndex(AIndex: integer): integer;
    function GetParagraphEndIndex(AIndex: integer): integer;
    function GetParagraphEndIndexBeforeParagraphSeparator(AIndex: integer): integer;
    function GetParagraphFirstUnbrokenLine(AIndex: integer): integer;
    function GetParagraphLastUnbrokenLinePlusOne(AIndex: integer): integer;
    function GetParagraphStartIndex(AIndex: integer): integer;
    function GetUnicodeChar(APosition0: integer): cardinal;
    function GetUTF8Char(APosition0: integer): string4;
    function GetBidiInfo(APosition0: integer): TUnicodeBidiInfo;
    procedure SetBidiMode(AValue: TFontBidiMode);

    procedure InternalDeleteBidiAndUTF8(ABidiStart, ABidiCount: integer);
    procedure InternalDeleteParagraph(AParagraphIndex: integer);
    procedure InternalDeleteText(APosition, ACount: integer);
    procedure InternalDeleteWithinParagraph(AParagraphIndex: integer;
      APosition, ACount: integer; AUpdateBidi: boolean);
    function InternalInsertText(APosition: integer;
      const ANewBidi: TBidiUTF8Array; ANewTextUTF8: string): integer;
    procedure InternalMergeParagraphWithNext(AParagraphIndex: integer);
    procedure InternalSplitParagraph(AParagraphIndex: integer);
    procedure InternalUpdateBidiIsolate(ABidiStart, ABidiCount: integer);
    procedure InternalUpdateUnbrokenLines(AParagraphIndex: integer);
    procedure CreateBidiTreeRec(ABidiTreeFactory: TBidiTreeAny; AData: pointer; ABidiTree: TBidiTree);
    procedure CheckCharRange(AStartIndex, AEndIndex: integer; AMinIndex, AMaxIndex: integer);
  public
    constructor Create(ATextUTF8: string; ABidiMode: TFontBidiMode);
    function GetParagraphAt(ACharIndex: integer): integer;
    function CopyTextUTF8(AStartIndex, ACount: integer): string;
    function CopyTextUTF8WithoutRemovedChars(AStartIndex,AEndIndex: integer; out ANonRemovedCount: integer): string;
    function InsertText(ATextUTF8: string; APosition: integer): integer;
    function DeleteText(APosition, ACount: integer): integer;
    function DeleteTextBefore(APosition, ACount: integer): integer;
    function IncludeNonSpacingChars(APosition, ACount: integer): integer;
    function IncludeNonSpacingCharsBefore(APosition, ACount: integer): integer;
    function CreateBidiTree(ABidiTreeFactory: TBidiTreeAny; AData: pointer; AStartIndex, AEndIndex: integer;
                            AEmbeddingBidiLevel: integer): TBidiTree;

    property TextUTF8: string read FText;
    property UTF8Char[APosition0: integer]: string4 read GetUTF8Char;
    property UnicodeChar[APosition0: integer]: cardinal read GetUnicodeChar;
    property BidiInfo[APosition0: integer]: TUnicodeBidiInfo read GetBidiInfo;
    property CharCount: integer read FCharCount;
    property UnbrokenLineCount: integer read FUnbrokenLineCount;
    property UnbrokenLineStartIndex[AIndex: integer]: integer read GetUnbrokenLineStartIndex;
    property UnbrokenLineEndIndex[AIndex: integer]: integer read GetUnbrokenLineEndIndex;
    property UnbrokenLineParagraphIndex[AIndex: integer]: integer read GetUnbrokenLineParagraphIndex;
    property ParagraphCount: integer read FParagraphCount;
    property ParagraphFirstUnbrokenLine[AIndex:integer] : integer read GetParagraphFirstUnbrokenLine;
    property ParagraphLastUnbrokenLinePlusOne[AIndex:integer] : integer read GetParagraphLastUnbrokenLinePlusOne;
    property ParagraphStartIndex[AIndex: integer]: integer read GetParagraphStartIndex;
    property ParagraphEndIndex[AIndex: integer]: integer read GetParagraphEndIndex;
    property ParagraphEndIndexBeforeParagraphSeparator[AIndex: integer]: integer read GetParagraphEndIndexBeforeParagraphSeparator;
    property BidiMode: TFontBidiMode read FBidiMode write SetBidiMode;
    property OnBidiModeChanged: TNotifyEvent read FOnBidiModeChanged write FOnBidiModeChanged;
    property OnCharDeleted: TDeleteCharEvent read FOnCharDeleted write FOnCharDeleted;
    property OnCharInserted: TInsertCharEvent read FOnCharInserted write FOnCharInserted;
    property OnParagraphDeleted: TParagraphEvent read FOnParagraphDeleted write FOnParagraphDeleted;
    property OnParagraphMergedWithNext: TParagraphEvent read FOnParagraphMergedWithNext write FOnParagraphMergedWithNext;
    property OnParagraphSplit: TParagraphSplitEvent read FOnParagraphSplit write FOnParagraphSplit;
  end;

implementation

uses math;

{ TBidiTree }

function TBidiTree.GetCount: integer;
begin
  if Assigned(FBranches) then
    result:= FBranches.Count
  else
    result := 0;
end;

function TBidiTree.GetBranch(AIndex: integer): TBidiTree;
begin
  if (AIndex < 0) or (AIndex >= Count) then raise exception.Create('Branch index out of bounds');
  result := TBidiTree(FBranches[AIndex]);
end;

constructor TBidiTree.Create(AData: pointer; AStartIndex, AEndIndex: integer; ABidiLevel: byte; AIsLeaf: boolean);
begin
  FData := AData;
  FParent := nil;
  FStartIndex:= AStartIndex;
  FEndIndex:= AEndIndex;
  FBidiLevel:= ABidiLevel;
  FBranches:= nil;
  FIsLeaf:= AIsLeaf;
end;

destructor TBidiTree.Destroy;
var
  i: Integer;
begin
  if Assigned(FBranches) then
  begin
    for i := 0 to FBranches.Count-1 do
      TBidiTree(FBranches[i]).Free;
    FBranches.Free;
  end;
  inherited Destroy;
end;

procedure TBidiTree.AfterFinish;
begin
  //
end;

procedure TBidiTree.AddBranch(ABranch: TBidiTree);
begin
  if IsLeaf then raise exception.Create('A leaf cannot have branches');
  if Assigned(ABranch.Parent) then raise exception.Create('Branch already has a parent');
  ABranch.FParent := self;
  if FBranches = nil then FBranches := TList.Create;
  FBranches.Add(ABranch);
end;

procedure TBidiTree.Shorten(AEndIndex: integer);
var
  i: Integer;
begin
  if AEndIndex = EndIndex then exit;
  if AEndIndex > EndIndex then raise exception.Create('Cannot extend the branch');
  if AEndIndex < StartIndex then raise exception.Create('End index before start');
  for i := Count-1 downto 0 do
    if AEndIndex <= Branch[i].StartIndex then
    begin
      Branch[i].Free;
      FBranches.Delete(i);
    end else
    if AEndIndex < Branch[i].EndIndex then
      Branch[i].Shorten(AEndIndex);
  FEndIndex:= AEndIndex;
end;

function TBidiTree.TrySplit: boolean;
begin
  result := false;
end;

{ TUnicodeAnalysis }

function TUnicodeAnalysis.GetParagraphFirstUnbrokenLine(AIndex: integer): integer;
begin
  if (AIndex < 0) or (AIndex >= ParagraphCount) then raise exception.Create('Paragraph index out of bounds');
  result := FParagraph[AIndex].firstUnbrokenLineIndex;
end;

procedure TUnicodeAnalysis.SetBidiMode(AValue: TFontBidiMode);
var
  i, bidiStart, bidiCount: LongInt;
begin
  if FBidiMode=AValue then Exit;
  FBidiMode:=AValue;
  for i := 0 to ParagraphCount-1 do
  begin
    bidiStart := ParagraphStartIndex[i];
    bidiCount := ParagraphEndIndex[i]-bidiStart;
    InternalUpdateBidiIsolate(bidiStart,bidiCount);
  end;
  if Assigned(FOnBidiModeChanged) then FOnBidiModeChanged(self);
end;

function TUnicodeAnalysis.GetParagraphEndIndex(AIndex: integer): integer;
begin
  if (AIndex < 0) or (AIndex >= ParagraphCount) then raise exception.Create('Paragraph index out of bounds');
  result := FUnbrokenLine[FParagraph[AIndex+1].firstUnbrokenLineIndex].startIndex;

end;

function TUnicodeAnalysis.GetParagraphEndIndexBeforeParagraphSeparator(
  AIndex: integer): integer;
var
  u: LongWord;
begin
  result := GetParagraphEndIndex(AIndex);
  if (result > 0) and (AIndex < ParagraphCount) then // last paragraph separator would be temporary before split
  begin
    u := UnicodeChar[result-1];
    if (result>0) and IsUnicodeParagraphSeparator(u) then
    begin
      dec(result);
      if IsUnicodeCrLf(u) and (result>0) and IsUnicodeCrLf(UnicodeChar[result-1]) and
        (UnicodeChar[result-1] <> u) then dec(result);
    end;
  end;
end;

function TUnicodeAnalysis.GetParagraphStartIndex(AIndex: integer): integer;
begin
  if (AIndex < 0) or (AIndex >= ParagraphCount) then raise exception.Create('Paragraph index out of bounds');
  result := FUnbrokenLine[FParagraph[AIndex].firstUnbrokenLineIndex].startIndex;
end;

function TUnicodeAnalysis.GetUnbrokenLineParagraphIndex(AIndex: integer): integer;
begin
  if (AIndex < 0) or (AIndex >= UnbrokenLineCount) then raise exception.Create('Unbroken line index out of bounds');
  result := FUnbrokenLine[AIndex].paragraphIndex;
end;

function TUnicodeAnalysis.GetBidiInfo(APosition0: integer): TUnicodeBidiInfo;
begin
  if (APosition0 < 0) or (APosition0 >= CharCount) then raise ERangeError.Create('Char position out of bounds');
  result := FBidi[APosition0].BidiInfo;
end;

function TUnicodeAnalysis.GetUnbrokenLineStartIndex(AIndex: integer): integer;
begin
  if (AIndex < 0) or (AIndex >= UnbrokenLineCount) then raise exception.Create('Unbroken line index out of bounds');
  result := FUnbrokenLine[AIndex].startIndex;
end;

function TUnicodeAnalysis.GetParagraphLastUnbrokenLinePlusOne(AIndex: integer): integer;
begin
  if (AIndex < 0) or (AIndex >= ParagraphCount) then raise exception.Create('Paragraph index out of bounds');
  result := FParagraph[AIndex+1].firstUnbrokenLineIndex;
end;

function TUnicodeAnalysis.GetUnbrokenLineEndIndex(AIndex: integer): integer;
begin
  if (AIndex < 0) or (AIndex >= UnbrokenLineCount) then raise exception.Create('Unbroken line index out of bounds');
  result := FUnbrokenLine[AIndex+1].startIndex;
end;

procedure TUnicodeAnalysis.Analyze;
var
  lineIndex, i: Integer;
  curParaIndex: integer;
begin
  if FBidiMode <> fbmAuto then
    FBidi:= AnalyzeBidiUTF8(FText, FBidiMode = fbmRightToLeft)
  else
    FBidi:= AnalyzeBidiUTF8(FText);
  FCharCount := length(FBidi);

  FUnbrokenLineCount := 1;
  FParagraphCount := 1;
  for i := 0 to high(FBidi) do
  begin
    if FBidi[i].BidiInfo.IsEndOfLine or FBidi[i].BidiInfo.IsExplicitEndOfParagraph then
    begin
      if FBidi[i].BidiInfo.IsExplicitEndOfParagraph then inc(FParagraphCount);
      inc(FUnbrokenLineCount);
    end;
  end;

  curParaIndex := 0;
  lineIndex := 0;
  setlength(FParagraph, FParagraphCount+1);
  FParagraph[curParaIndex].firstUnbrokenLineIndex:= lineIndex;
  setlength(FUnbrokenLine, FUnbrokenLineCount+1);
  FUnbrokenLine[lineIndex].startIndex := 0;
  FUnbrokenLine[lineIndex].paragraphIndex := curParaIndex;
  inc(lineIndex);
  for i := 0 to high(FBidi) do
  begin
    if FBidi[i].BidiInfo.IsEndOfLine or FBidi[i].BidiInfo.IsExplicitEndOfParagraph then
    begin
      if FBidi[i].BidiInfo.IsExplicitEndOfParagraph then
      begin
        inc(curParaIndex);
        FParagraph[curParaIndex].firstUnbrokenLineIndex:= lineIndex;
      end;
      FUnbrokenLine[lineIndex].startIndex := i+1;
      FUnbrokenLine[lineIndex].paragraphIndex := curParaIndex;
      inc(lineIndex);
    end;
  end;
  FParagraph[curParaIndex+1].firstUnbrokenLineIndex:= lineIndex;
  FUnbrokenLine[lineIndex].startIndex := length(FBidi);
  FUnbrokenLine[lineIndex].paragraphIndex:= curParaIndex+1;

  setlength(FBidi, length(FBidi)+1);
  FBidi[High(FBidi)].Offset := length(FText);
end;

constructor TUnicodeAnalysis.Create(ATextUTF8: string; ABidiMode: TFontBidiMode);
begin
  FText:= ATextUTF8;
  FBidiMode:= ABidiMode;
  Analyze;
end;

function TUnicodeAnalysis.GetParagraphAt(ACharIndex: integer): integer;
  procedure FindRec(AFirstParagraphIndex, ALastParagraphIndex: integer);
  var
    midIndex: Integer;
  begin
    if ALastParagraphIndex<AFirstParagraphIndex then
      raise exception.Create('Cannot find paragraph');
    midIndex := (AFirstParagraphIndex+ALastParagraphIndex) shr 1;
    if (ACharIndex < ParagraphStartIndex[midIndex]) then
      FindRec(AFirstParagraphIndex, midIndex-1)
    else if (midIndex < ParagraphCount-1) and (ACharIndex >= ParagraphStartIndex[midIndex+1]) then
      FindRec(midIndex+1, ALastParagraphIndex)
    else
    begin
      result := midIndex;
      exit;
    end;
  end;

begin
  if (ACharIndex < 0) or (ACharIndex > CharCount) then raise exception.Create('Position out of bounds');
  FindRec(0, ParagraphCount-1);
end;

function TUnicodeAnalysis.CopyTextUTF8(AStartIndex, ACount: integer): string;
begin
  if (AStartIndex < 0) or (AStartIndex+ACount > CharCount) then raise exception.Create('Char range out of bounds');
  result := copy(FText, FBidi[AStartIndex].Offset+1, FBidi[AStartIndex+ACount].Offset-FBidi[AStartIndex].Offset)
end;

function TUnicodeAnalysis.CopyTextUTF8WithoutRemovedChars(AStartIndex,
  AEndIndex: integer; out ANonRemovedCount: integer): string;
var i, len, charLen: integer;
begin
  CheckCharRange(AStartIndex, AEndIndex, 0, CharCount);

  ANonRemovedCount:= 0;
  len := 0;
  for i := AStartIndex to AEndIndex-1 do
    if not FBidi[i].BidiInfo.IsRemoved then
    begin
      inc(len, FBidi[i+1].Offset - FBidi[i].Offset);
      inc(ANonRemovedCount);
    end;

  setlength(result, len);
  len := 0;
  for i := AStartIndex to AEndIndex-1 do
    if not FBidi[i].BidiInfo.IsRemoved then
    begin
      charLen := FBidi[i+1].Offset - FBidi[i].Offset;
      move(FText[FBidi[i].Offset+1], result[len+1], charLen);
      inc(len, charLen);
    end;
end;

function TUnicodeAnalysis.InsertText(ATextUTF8: string; APosition: integer): integer;
var
  newBidi: TBidiUTF8Array;
begin
  if (APosition < 0) or (APosition > CharCount) then raise exception.Create('Position out of bounds');
  if length(ATextUTF8)=0 then exit;

  if FBidiMode <> fbmAuto then
    newBidi:= AnalyzeBidiUTF8(ATextUTF8, FBidiMode = fbmRightToLeft)
  else
    newBidi:= AnalyzeBidiUTF8(ATextUTF8);
  result:= InternalInsertText(APosition, newBidi, ATextUTF8);
end;

function TUnicodeAnalysis.DeleteText(APosition, ACount: integer): integer;
begin
  ACount := IncludeNonSpacingChars(APosition, ACount);
  if ACount = 0 then exit(0);
  InternalDeleteText(APosition, ACount);
  result := ACount;
end;

function TUnicodeAnalysis.DeleteTextBefore(APosition, ACount: integer): integer;
begin
  ACount := IncludeNonSpacingCharsBefore(APosition, ACount);
  if ACount = 0 then exit(0);
  InternalDeleteText(APosition-ACount, ACount);
  result := ACount;
end;

function TUnicodeAnalysis.IncludeNonSpacingChars(APosition, ACount: integer): integer;
var
  idxPara: Integer;
begin
  if (APosition < 0) or (APosition > CharCount) then raise exception.Create('Position out of bounds');
  if APosition+ACount > CharCount then raise exception.Create('Exceed end of text');
  if ACount = 0 then exit(0);

  //keep Cr/Lf pair together
  if IsUnicodeCrLf(UnicodeChar[APosition+ACount-1]) then
  begin
    idxPara := GetParagraphAt(APosition+ACount-1);
    if (ParagraphEndIndex[idxPara] > APosition+ACount) and
       IsUnicodeCrLf(UnicodeChar[APosition+ACount]) and
       (UnicodeChar[APosition+ACount] <> UnicodeChar[APosition+ACount-1]) then Inc(ACount);
  end;

  //keep non spacing marks after last char together
  while (APosition+ACount < CharCount) and
    (GetUnicodeBidiClass(UnicodeChar[APosition+ACount])=ubcNonSpacingMark)
  do inc(ACount);

  result := ACount;
end;

function TUnicodeAnalysis.IncludeNonSpacingCharsBefore(APosition, ACount: integer): integer;
var
  idxPara: Integer;
begin
  if (APosition < 0) or (APosition > CharCount) then raise exception.Create('Position out of bounds');
  if APosition-ACount < 0 then raise exception.Create('Exceed start of text');
  if ACount = 0 then exit(0);

  //keep Cr/Lf pair together
  if IsUnicodeCrLf(UnicodeChar[APosition-1]) then
   begin
     idxPara := GetParagraphAt(APosition-1);
     if (ParagraphStartIndex[idxPara] < APosition-1) and
        IsUnicodeCrLf(UnicodeChar[APosition-2]) and
        (UnicodeChar[APosition-2] <> UnicodeChar[APosition-1]) then
       Inc(ACount);
   end;

  //keep before non spacing marks until real char together
  idxPara := GetParagraphAt(APosition-ACount);
  while (APosition-ACount > ParagraphStartIndex[idxPara]) and
    (GetUnicodeBidiClass(UnicodeChar[APosition-ACount])=ubcNonSpacingMark) and
    not IsUnicodeIsolateOrFormatting(UnicodeChar[APosition-ACount-1])
  do inc(ACount);

  result := ACount;
end;

function TUnicodeAnalysis.CreateBidiTree(ABidiTreeFactory: TBidiTreeAny;
  AData: pointer; AStartIndex, AEndIndex: integer; AEmbeddingBidiLevel: integer): TBidiTree;
begin
  result := ABidiTreeFactory.Create(AData, AStartIndex, AEndIndex, AEmbeddingBidiLevel, false);
  CreateBidiTreeRec(ABidiTreeFactory, AData, result);
end;

procedure TUnicodeAnalysis.CreateBidiTreeRec(ABidiTreeFactory: TBidiTreeAny; AData: pointer; ABidiTree: TBidiTree);
var
  startIndex, endIndex, i: integer;
  subLevel: byte;
  subStart: integer;
  subTree: TBidiTree;
begin
  startIndex := ABidiTree.StartIndex;
  endIndex:= ABidiTree.EndIndex;

  while (startIndex < endIndex) and FBidi[startIndex].BidiInfo.IsRemoved do inc(startIndex);
  while (startIndex < endIndex) and FBidi[endIndex-1].BidiInfo.IsRemoved do dec(endIndex);
  if endIndex = startIndex then exit;

  i := startIndex;
  while i < endIndex do
  begin
    if not FBidi[i].BidiInfo.IsRemoved then
    begin
      if FBidi[i].BidiInfo.BidiLevel > ABidiTree.BidiLevel then
      begin
        subStart := i;
        subLevel := FBidi[i].BidiInfo.BidiLevel;
        inc(i);
        while (i < endIndex) and (FBidi[i].BidiInfo.BidiLevel > ABidiTree.BidiLevel) do
        begin
          if FBidi[i].BidiInfo.BidiLevel < subLevel then
            subLevel := FBidi[i].BidiInfo.BidiLevel;
          inc(i);
        end;

        subTree := ABidiTreeFactory.Create(AData, subStart, i, subLevel, false);
        ABidiTree.AddBranch(subTree);
        CreateBidiTreeRec(ABidiTreeFactory, AData, subTree);
        subTree.AfterFinish;
        if subTree.EndIndex < i then
        begin
          ABidiTree.Shorten(subTree.EndIndex);
          exit;
        end;
      end else
      begin
        subStart:= i;
        inc(i);
        while (i < endIndex) and (FBidi[i].BidiInfo.BidiLevel = ABidiTree.BidiLevel) do inc(i);

        subTree := ABidiTreeFactory.Create(AData, subStart, i, ABidiTree.BidiLevel, true);
        ABidiTree.AddBranch(subTree);
        if subTree.TrySplit then
        begin
          ABidiTree.Shorten(subTree.EndIndex);
          exit;
        end;
      end;

    end else
      inc(i);
  end;
end;

procedure TUnicodeAnalysis.CheckCharRange(AStartIndex, AEndIndex: integer;
  AMinIndex, AMaxIndex: integer);
begin
  if AEndIndex<AStartIndex then raise exception.Create('Invalid char range');
  if (AStartIndex < AMinIndex) or (AEndIndex > AMaxIndex) then
    raise exception.Create('Char range out of bounds ['+inttostr(AStartIndex)+','+IntToStr(AEndIndex)+'] > ['+inttostr(AMinIndex)+','+IntToStr(AMaxIndex)+']');
end;

procedure TUnicodeAnalysis.CheckTextAnalysis;
var
  i: Integer;
begin
  for i := 1 to high(FBidi)-1 do
    if (FBidi[i].Offset <= 0) or (FBidi[i].Offset > length(FText)-1) then
      raise exception.Create('UTF8 offset out of range for char '+inttostr(i));
  if (length(FBidi)>0) and ((FBidi[0].Offset <> 0) or (FBidi[high(FBidi)].Offset <> length(FText))) then
    raise exception.Create('Unexpected UTF8 offset');
  for i := 0 to high(FUnbrokenLine) do
  begin
    if (i > 0) and (FUnbrokenLine[i].startIndex < FUnbrokenLine[i-1].startIndex) then
      raise exception.Create('Unbroken line position must be increasing');
    if (i > 0) and (FUnbrokenLine[i].paragraphIndex < FUnbrokenLine[i-1].paragraphIndex) then
      raise exception.Create('Unbroken line paragraph must be increasing');
    if (i > 0) and (FUnbrokenLine[i].paragraphIndex > FUnbrokenLine[i-1].paragraphIndex+1) then
      raise exception.Create('Unbroken line must not skip paragraph');
  end;
  if (length(FUnbrokenLine)>0) and ((FUnbrokenLine[0].paragraphIndex <> 0)
     or (FUnbrokenLine[High(FUnbrokenLine)].paragraphIndex <> high(FParagraph))) then
    raise exception.Create('Unexpected paragraph index');
  for i := 0 to high(FParagraph) do
  begin
    if (i > 0) and (FParagraph[i].firstUnbrokenLineIndex <= FParagraph[i-1].firstUnbrokenLineIndex) then
      raise exception.Create('Paragraph unbroken line index must be strictly increasing');
  end;
  if (length(FParagraph)>0) and ((FParagraph[0].firstUnbrokenLineIndex <> 0) or
    (FParagraph[high(FParagraph)].firstUnbrokenLineIndex <> high(FUnbrokenLine))) then
    raise exception.Create('Unexpected paragraph unbroken line index');
end;

function TUnicodeAnalysis.GetUnicodeChar(APosition0: integer): cardinal;
var p : PChar;
  charLen: Integer;
begin
  if (APosition0 < 0) or (APosition0 >= CharCount) then raise ERangeError.Create('Char position out of bounds');
  p := @FText[FBidi[APosition0].Offset+1];
  charLen := UTF8CharacterLength(p);
  result := UTF8CodepointToUnicode(p, charLen);
end;

function TUnicodeAnalysis.GetUTF8Char(APosition0: integer): string4;
begin
  if (APosition0 < 0) or (APosition0 >= CharCount) then raise ERangeError.Create('Char position out of bounds');
  result := copy(FText, FBidi[APosition0].Offset+1, FBidi[APosition0+1].Offset-FBidi[APosition0].Offset);
end;

procedure TUnicodeAnalysis.InternalDeleteText(APosition, ACount: integer);
var
  i, delStart: Integer;
  hasParaSep: Boolean;
  indexBeforeSep: LongInt;
begin
  for i := ParagraphCount-1 downto 0 do
  if (APosition < ParagraphEndIndex[i]) and (APosition+ACount > ParagraphStartIndex[i]) then
  begin
    indexBeforeSep := ParagraphEndIndexBeforeParagraphSeparator[i];
    hasParaSep := indexBeforeSep<>ParagraphEndIndex[i];

    if (i < ParagraphCount-1) and hasParaSep and (APosition+ACount > indexBeforeSep) then //paragraph separator removed
    begin
      if APosition <= ParagraphStartIndex[i] then
        InternalDeleteParagraph(i)
      else
      begin
        delStart := max(APosition,ParagraphStartIndex[i]);
        InternalDeleteWithinParagraph(i, delStart, min(APosition+ACount,indexBeforeSep)-delStart, False);
        InternalMergeParagraphWithNext(i);
      end;
    end else
    begin
      delStart := max(APosition,ParagraphStartIndex[i]);
      InternalDeleteWithinParagraph(i, delStart, min(APosition+ACount,ParagraphEndIndex[i])-delStart, True);
    end;
  end;
  CheckTextAnalysis;
end;

procedure TUnicodeAnalysis.InternalDeleteParagraph(AParagraphIndex: integer);
var
  unbrokenStart, unbrokenEnd, unbrokenCount: Integer;
  bidiStart, bidiCount, i: LongInt;
begin
  if (AParagraphIndex < 0) or (AParagraphIndex >= ParagraphCount) then
    raise exception.Create('Paragraph index out of bounds');

  unbrokenStart := FParagraph[AParagraphIndex].firstUnbrokenLineIndex;
  unbrokenEnd := FParagraph[AParagraphIndex+1].firstUnbrokenLineIndex;
  unbrokenCount := unbrokenEnd-unbrokenStart;

  bidiStart := ParagraphStartIndex[AParagraphIndex];
  bidiCount := ParagraphEndIndex[AParagraphIndex]-bidiStart;
  InternalDeleteBidiAndUTF8(bidiStart, bidiCount);

  for i := unbrokenStart to high(FUnbrokenLine)-unbrokenCount do
  begin
    FUnbrokenLine[i] := FUnbrokenLine[i+unbrokenCount];
    dec(FUnbrokenLine[i].paragraphIndex);
    dec(FUnbrokenLine[i].startIndex, bidiCount);
  end;
  setlength(FUnbrokenLine, length(FUnbrokenLine)-unbrokenCount);
  dec(FUnbrokenLineCount, unbrokenCount);

  for i := AParagraphIndex+1 to ParagraphCount do
    dec(FParagraph[i].firstUnbrokenLineIndex, unbrokenCount);
  if Assigned(FOnCharDeleted) then FOnCharDeleted(self, AParagraphIndex, bidiStart, bidiCount);

  for i := AParagraphIndex to ParagraphCount-1 do
    FParagraph[i] := FParagraph[i+1];
  dec(FParagraphCount);
  setlength(FParagraph, FParagraphCount+1);
  if Assigned(FOnParagraphDeleted) then FOnParagraphDeleted(self, AParagraphIndex);
end;

procedure TUnicodeAnalysis.InternalDeleteWithinParagraph(
  AParagraphIndex: integer; APosition, ACount: integer; AUpdateBidi: boolean);
var
  unbrokenEnd: Integer;
  bidiStart, bidiCount: LongInt;
  i: integer;
begin
  if (AParagraphIndex < 0) or (AParagraphIndex >= ParagraphCount) then
    raise exception.Create('Paragraph index out of bounds');

  InternalDeleteBidiAndUTF8(APosition, ACount);

  unbrokenEnd := FParagraph[AParagraphIndex+1].firstUnbrokenLineIndex;
  for i := unbrokenEnd to high(FUnbrokenLine) do
    dec(FUnbrokenLine[i].startIndex, ACount);

  bidiStart := ParagraphStartIndex[AParagraphIndex];
  bidiCount := ParagraphEndIndex[AParagraphIndex]-bidiStart;

  if bidiCount > 0 then
  begin
    if AUpdateBidi then InternalUpdateBidiIsolate(bidiStart, bidiCount);
    InternalUpdateUnbrokenLines(AParagraphIndex);
  end;

  if Assigned(FOnCharDeleted) then FOnCharDeleted(self, AParagraphIndex, bidiStart, bidiCount);
end;

procedure TUnicodeAnalysis.InternalMergeParagraphWithNext(AParagraphIndex: integer);
var
  indexBeforeSep, bidiStart, bidiCount, i: LongInt;
  hasParaSep: Boolean;
  unbrokenEnd: Integer;
begin
  if (AParagraphIndex < 0) or (AParagraphIndex >= ParagraphCount-1) then
    raise exception.Create('Paragraph index out of bounds');

  indexBeforeSep := ParagraphEndIndexBeforeParagraphSeparator[AParagraphIndex];
  hasParaSep := indexBeforeSep<>ParagraphEndIndex[AParagraphIndex];
  if not hasParaSep then exit;

  bidiStart := indexBeforeSep;
  bidiCount := ParagraphEndIndex[AParagraphIndex]-bidiStart;
  InternalDeleteBidiAndUTF8(bidiStart, bidiCount);

  unbrokenEnd := FParagraph[AParagraphIndex+1].firstUnbrokenLineIndex;
  for i := unbrokenEnd to high(FUnbrokenLine)-1 do
  begin
    FUnbrokenLine[i] := FUnbrokenLine[i+1];
    dec(FUnbrokenLine[i].paragraphIndex);
    dec(FUnbrokenLine[i].startIndex, bidiCount);
  end;
  setlength(FUnbrokenLine, length(FUnbrokenLine)-1);
  dec(FUnbrokenLineCount);

  for i := AParagraphIndex+1 to high(FParagraph)-1 do
  begin
    FParagraph[i] := FParagraph[i+1];
    dec(FParagraph[i].firstUnbrokenLineIndex);
  end;
  setlength(FParagraph, length(FParagraph)-1);
  dec(FParagraphCount);

  bidiStart := ParagraphStartIndex[AParagraphIndex];
  bidiCount := ParagraphEndIndex[AParagraphIndex]-bidiStart;
  InternalUpdateBidiIsolate(bidiStart, bidiCount);

  if Assigned(FOnParagraphMergedWithNext) then
    FOnParagraphMergedWithNext(self, AParagraphIndex);
end;

procedure TUnicodeAnalysis.InternalDeleteBidiAndUTF8(ABidiStart,
  ABidiCount: integer);
var
  utf8Start, utf8Count, bidiEnd, i: Integer;
begin
  if ABidiCount = 0 then exit;
  if ABidiCount < 0 then raise exception.Create('Bidi count must be positive');
  bidiEnd := ABidiStart+ABidiCount;
  CheckCharRange(ABidiStart, bidiEnd, 0, CharCount);

  utf8Start := FBidi[ABidiStart].Offset+1;
  if bidiEnd >= CharCount then
    utf8Count := length(FText) - (utf8Start-1)
  else
    utf8Count := FBidi[bidiEnd].Offset - (utf8Start-1);
  delete(FText, utf8Start, utf8Count);

  for i := ABidiStart to high(FBidi)-ABidiCount do
  begin
    FBidi[i] := FBidi[i+ABidiCount];
    dec(FBidi[i].Offset, utf8Count);
  end;
  setlength(FBidi, length(FBidi)-ABidiCount);
  dec(FCharCount, ABidiCount);
end;

procedure TUnicodeAnalysis.InternalUpdateBidiIsolate(ABidiStart, ABidiCount: integer);
var
  utf8Start, utf8Count, bidiEnd, i: Integer;
  newBidi: TBidiUTF8Array;
begin
  if ABidiCount = 0 then exit;
  if ABidiCount < 0 then raise exception.Create('Bidi count must be positive');
  bidiEnd := ABidiStart+ABidiCount;
  CheckCharRange(ABidiStart, bidiEnd, 0, CharCount);

  utf8Start := FBidi[ABidiStart].Offset+1;
  if bidiEnd >= CharCount then
    utf8Count := length(FText) - (utf8Start-1)
  else
    utf8Count := FBidi[bidiEnd].Offset - (utf8Start-1);

  if FBidiMode <> fbmAuto then
    newBidi:= AnalyzeBidiUTF8(copy(FText, utf8Start, utf8Count), FBidiMode = fbmRightToLeft)
  else
    newBidi:= AnalyzeBidiUTF8(copy(FText, utf8Start, utf8Count));

  for i := 0 to min(ABidiCount, length(newBidi))-1 do
  begin
    FBidi[ABidiStart+i] := newBidi[i];
    inc(FBidi[ABidiStart+i].Offset, utf8Start-1);
  end;
end;

procedure TUnicodeAnalysis.InternalUpdateUnbrokenLines(AParagraphIndex: integer);
var
  newUnbrokenCount, unbrokenStart, unbrokenEnd, unbrokenCount,
  unbrokenDelta, curUnbrokenIndex: Integer;
  bidiStart, bidiEnd, i: LongInt;
begin
  if (AParagraphIndex < 0) or (AParagraphIndex >= ParagraphCount) then
    raise exception.Create('Paragraph index out of bounds');

  bidiStart := ParagraphStartIndex[AParagraphIndex];
  if AParagraphIndex = ParagraphCount-1 then
    bidiEnd := ParagraphEndIndex[AParagraphIndex]
  else
    bidiEnd := ParagraphEndIndexBeforeParagraphSeparator[AParagraphIndex];
  unbrokenStart := FParagraph[AParagraphIndex].firstUnbrokenLineIndex;
  unbrokenEnd := FParagraph[AParagraphIndex+1].firstUnbrokenLineIndex;
  unbrokenCount := unbrokenEnd-unbrokenStart;

  newUnbrokenCount := 1;
  for i := bidiStart to bidiEnd-1 do
    if FBidi[i].BidiInfo.IsEndOfLine or
       FBidi[i].BidiInfo.IsExplicitEndOfParagraph then inc(newUnbrokenCount);

  if newUnbrokenCount < unbrokenCount then
  begin
    unbrokenDelta := unbrokenCount-newUnbrokenCount;
    for i := unbrokenEnd-unbrokenDelta to high(FUnbrokenLine)-unbrokenDelta do
      FUnbrokenLine[i] := FUnbrokenLine[i+unbrokenDelta];
    setlength(FUnbrokenLine, length(FUnbrokenLine)-unbrokenDelta);
    dec(FUnbrokenLineCount, unbrokenDelta);
  end else
  if newUnbrokenCount > unbrokenCount then
  begin
    unbrokenDelta := newUnbrokenCount-unbrokenCount;
    setlength(FUnbrokenLine, length(FUnbrokenLine)+unbrokenDelta);
    inc(FUnbrokenLineCount, unbrokenDelta);
    for i := high(FUnbrokenLine) downto unbrokenEnd+unbrokenDelta do
      FUnbrokenLine[i] := FUnbrokenLine[i-unbrokenDelta];
  end;
  for i := AParagraphIndex+1 to high(FParagraph) do
    inc(FParagraph[i].firstUnbrokenLineIndex, newUnbrokenCount-unbrokenCount);

  curUnbrokenIndex := unbrokenStart;
  FUnbrokenLine[curUnbrokenIndex].startIndex:= bidiStart;
  FUnbrokenLine[curUnbrokenIndex].paragraphIndex:= AParagraphIndex;
  for i := bidiStart to bidiEnd-1 do
  begin
    if FBidi[i].BidiInfo.IsEndOfLine or
       FBidi[i].BidiInfo.IsExplicitEndOfParagraph then // paragraph separator before split
    begin
      inc(curUnbrokenIndex);
      FUnbrokenLine[curUnbrokenIndex].startIndex := i+1;
      FUnbrokenLine[curUnbrokenIndex].paragraphIndex:= AParagraphIndex;
    end;
  end;
end;

function TUnicodeAnalysis.InternalInsertText(APosition: integer;
  const ANewBidi: TBidiUTF8Array; ANewTextUTF8: string): integer;
var
  utf8Start, utf8Count,
  prevCharCount, bidiStart, bidiCount,
  i, unbrokenEnd, paraIndex: integer;
begin
  if (APosition < 0) or (APosition>CharCount) then
    raise exception.Create('Position out of bounds');
  if length(ANewBidi)=0 then exit;

  prevCharCount:= CharCount;
  paraIndex := GetParagraphAt(APosition);
  bidiCount := length(ANewBidi);

  utf8Start := FBidi[APosition].Offset+1;
  utf8Count := length(ANewTextUTF8);
  Insert(ANewTextUTF8, FText, utf8Start);

  setlength(FBidi, length(FBidi)+bidiCount);
  for i := high(FBidi) downto APosition+bidiCount do
  begin
    FBidi[i] := FBidi[i-bidiCount];
    inc(FBidi[i].Offset, utf8Count);
  end;
  for i := 0 to high(ANewBidi) do
  begin
    FBidi[APosition+i] := ANewBidi[i];
    inc(FBidi[APosition+i].Offset, utf8Start-1);
  end;
  inc(FCharCount, bidiCount);

  unbrokenEnd := FParagraph[paraIndex+1].firstUnbrokenLineIndex;
  for i := unbrokenEnd to high(FUnbrokenLine) do
    inc(FUnbrokenLine[i].startIndex, bidiCount);

  bidiStart := ParagraphStartIndex[paraIndex];
  bidiCount := ParagraphEndIndex[paraIndex]-bidiStart;
  InternalUpdateBidiIsolate(bidiStart, bidiCount);

  InternalUpdateUnbrokenLines(paraIndex);
  if Assigned(FOnCharInserted) then
    FOnCharInserted(self, paraIndex, APosition, bidiCount);

  InternalSplitParagraph(paraIndex);
  CheckTextAnalysis;
  result := CharCount-prevCharCount;
end;

procedure TUnicodeAnalysis.InternalSplitParagraph(AParagraphIndex: integer);
var
  i, unbrokenStart, unbrokenEndIncl, j, paraIndex: integer;
begin
  unbrokenStart := FParagraph[AParagraphIndex].firstUnbrokenLineIndex;
  unbrokenEndIncl := FParagraph[AParagraphIndex+1].firstUnbrokenLineIndex-1;
  for i := unbrokenStart+1 to unbrokenEndIncl do
  begin
    if (FUnbrokenLine[i].startIndex > 0) and
      FBidi[FUnbrokenLine[i].startIndex-1].BidiInfo.IsExplicitEndOfParagraph then
    begin
      paraIndex := FUnbrokenLine[i].paragraphIndex;
      setlength(FParagraph, length(FParagraph)+1);
      inc(FParagraphCount);
      for j := high(FParagraph) downto paraIndex+2 do
        FParagraph[j] := FParagraph[j-1];
      FParagraph[paraIndex+1].firstUnbrokenLineIndex:= i;
      for j := i to high(FUnbrokenLine) do
        inc(FUnbrokenLine[j].paragraphIndex);

      if Assigned(OnParagraphSplit) then
        OnParagraphSplit(self, paraIndex, FUnbrokenLine[i].startIndex);
    end;
  end;
end;

end.

