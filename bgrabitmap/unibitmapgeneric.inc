{$IFDEF INCLUDE_INTERFACE}
{$UNDEF INCLUDE_INTERFACE}

type
  { TGenericUniversalBitmap }

  generic TGenericUniversalBitmap<TPixel,TColorspace> = class(TCustomUniversalBitmap)
  private
    type PPixel = ^TPixel;
    function GetDataPtr: PPixel; inline;
    function GetScanLine(y: integer): PPixel; inline;
  protected
    class function DefaultColorspace: TColorspaceAny; override;
    procedure Init; override; //ensure colorspace
    function GetScanlineFast(y: integer): PPixel; inline; //typed function
    procedure InternalCopyPixels(ASource,ADest: PByte; ASourceStride,ADestStride: PtrInt; ACount: integer); override;
    procedure InternalSwapPixels(ABuf1,ABuf2: PByte; AStride1,AStride2: PtrInt; ACount: integer); override;
  public
    //typed functions

    {** Creates an image of dimensions ''AWidth'' and ''AHeight'' and fills it with ''Color'' }
    constructor Create(AWidth, AHeight: integer; const AColor: TPixel);
    class procedure SolidBrush(out ABrush: TUniversalBrush; const AColor: TPixel; ADrawMode: TDrawMode = dmDrawWithTransparency); overload;
    procedure SetPixel(x,y: int32or64; const AColor: TPixel); overload; virtual;
    function GetPixel(x,y: int32or64): TPixel; inline;
    function GetPixelCycle(x,y: int32or64): TPixel; inline;
    {** Returns the address of the left-most pixel of any line.
        The parameter y ranges from 0 to Height-1 }
    property ScanLine[y: integer]: PPixel Read GetScanLine;
    property Data: PPixel read GetDataPtr;

    procedure Fill(const AColor: TPixel); overload; virtual;
    procedure Fill(const AColor: TPixel; AMode : TDrawMode; AAlpha : Word = 65535); overload; virtual;
    procedure FillRect(ALeft, ATop, ARight, ABottom: integer; const AColor: TPixel; ADrawMode: TDrawMode = dmSet; AAlpha: Word = 65535); overload; virtual;
    procedure FillRect(const ARect: TRect; const AColor: TPixel; ADrawMode: TDrawMode = dmSet; AAlpha: Word = 65535); overload; virtual;
    procedure DrawPixel(x,y: Int32or64; const AColor: TPixel); overload; virtual;
    procedure DrawPixel(x,y: Int32or64; const AColor: TPixel; ADrawMode: TDrawMode); overload; virtual;
    procedure DrawPixel(x,y: Int32or64; const AColor: TPixel; ADrawMode: TDrawMode; AAlpha: Word); overload; virtual;
    procedure HorizLine(x, y, x2: int32or64; const AColor: TPixel; AMode : TDrawMode = dmDrawWithTransparency; AAlpha: Word = 65535); overload; virtual;
    procedure VertLine(x, y, y2: int32or64; const AColor: TPixel; AMode : TDrawMode = dmDrawWithTransparency; AAlpha: Word = 65535); overload; virtual;
    procedure DrawLine(x1, y1, x2, y2: integer; const AColor: TPixel; ADrawLastPixel: boolean; AMode : TDrawMode = dmDrawWithTransparency; AAlpha: Word = 65535); overload; virtual;
    procedure DrawLineAntialias(x1, y1, x2, y2: integer; const AColor: TPixel; ADrawLastPixel: boolean; AAlpha: Word = 65535); overload; virtual;
    procedure DrawLineAntialias(x1, y1, x2, y2: integer; const AColor1, AColor2: TPixel; ADashLen: integer; ADrawLastPixel: boolean; AAlpha: Word = 65535); overload; virtual;
    procedure DrawLineAntialias(x1, y1, x2, y2: integer; const AColor1, AColor2: TPixel; ADashLen: integer; var ADashPos: integer; ADrawLastPixel: boolean; AAlpha: Word = 65535); overload; virtual;
    procedure DrawPolyLine(const points: array of TPoint; const AColor: TPixel; ADrawLastPixel: boolean; AMode : TDrawMode = dmDrawWithTransparency; AAlpha: Word = 65535); overload;
    procedure DrawPolyLineAntialias(const points: array of TPoint; const AColor: TPixel; ADrawLastPixel: boolean; AAlpha: Word = 65535); overload;
    procedure DrawPolyLineAntialias(const points: array of TPoint; const AColor1, AColor2: TPixel; ADashLen: integer; ADrawLastPixel: boolean; AAlpha: Word = 65535); overload;
    procedure DrawPolygon(const points: array of TPoint; const AColor: TPixel; AMode : TDrawMode = dmDrawWithTransparency; AAlpha: Word = 65535); overload;
    procedure DrawPolygonAntialias(const points: array of TPoint; const AColor: TPixel; AAlpha: Word = 65535); overload;
    procedure DrawPolygonAntialias(const points: array of TPoint; const AColor1, AColor2: TPixel; ADashLen: integer; AAlpha: Word = 65535); overload;
    procedure DrawPathAliased(APath: IBGRAPath; const AColor: TPixel; AMode : TDrawMode = dmDrawWithTransparency; APixelCenteredCoordinates: boolean = true; AAlpha: Word = 65535); overload;
    procedure DrawPathAliased(APath: IBGRAPath; const AMatrix: TAffineMatrix; const AColor: TPixel; AMode : TDrawMode = dmDrawWithTransparency; APixelCenteredCoordinates: boolean = true; AAlpha: Word = 65535); overload;
    procedure Rectangle(x, y, x2, y2: integer; const AColor: TPixel; AMode : TDrawMode = dmDrawWithTransparency; AAlpha: Word = 65535); overload; virtual;
    procedure Rectangle(x, y, x2, y2: integer; const ABorderColor, AFillColor: TPixel; AMode : TDrawMode = dmDrawWithTransparency; AAlpha: Word = 65535); overload; virtual;
    procedure Rectangle(const ARect: TRect; const AColor: TPixel; AMode : TDrawMode = dmDrawWithTransparency; AAlpha: Word = 65535); overload; virtual;
    procedure Rectangle(const ARect: TRect; const ABorderColor, AFillColor: TPixel; AMode : TDrawMode = dmDrawWithTransparency; AAlpha: Word = 65535); overload; virtual;
    procedure RoundRect(X1, Y1, X2, Y2: integer; DX, DY: integer; const ABorderColor: TPixel; AMode : TDrawMode = dmDrawWithTransparency; AAlpha: Word = 65535); overload; virtual;
    procedure RoundRect(X1, Y1, X2, Y2: integer; DX, DY: integer; const ABorderColor, AFillColor: TPixel; AMode : TDrawMode = dmDrawWithTransparency; AAlpha: Word = 65535); overload; virtual;
    procedure FillRoundRect(X1, Y1, X2, Y2: integer; DX, DY: integer; const AFillColor: TPixel; AMode : TDrawMode = dmDrawWithTransparency; AAlpha: Word = 65535); overload; virtual;
    procedure EllipseInRect(ARect: TRect; const ABorderColor: TPixel; AMode : TDrawMode = dmDrawWithTransparency; AAlpha: Word = 65535); overload; virtual;
    procedure EllipseInRect(ARect: TRect; const ABorderColor, AFillColor: TPixel; AMode : TDrawMode = dmDrawWithTransparency; AAlpha: Word = 65535); overload; virtual;
    procedure FillEllipseInRect(ARect: TRect; const AFillColor: TPixel; AMode : TDrawMode = dmDrawWithTransparency; AAlpha: Word = 65535); overload; virtual;
    procedure FillShape(AShape: TBGRACustomFillInfo; const AFillColor: TPixel; AMode : TDrawMode = dmDrawWithTransparency; AAlpha: Word = 65535); overload; virtual;
    procedure FillPoly(const APoints: array of TPointF; const AFillColor: TPixel; AMode : TDrawMode = dmDrawWithTransparency; APixelCenteredCoordinates: boolean = true; AAlpha: Word = 65535); overload; virtual;
    procedure FillPathAliased(APath: IBGRAPath; const AFillColor: TPixel; AMode : TDrawMode = dmDrawWithTransparency; APixelCenteredCoordinates: boolean = true; AAlpha: Word = 65535); overload;
    procedure FillPathAliased(APath: IBGRAPath; const AMatrix: TAffineMatrix; const AFillColor: TPixel; AMode : TDrawMode = dmDrawWithTransparency; APixelCenteredCoordinates: boolean = true; AAlpha: Word = 65535); overload;

    //optimized
    procedure SetPixelIndirect(x,y: int32or64; AColor: pointer); override;
    procedure GetPixelIndirect(x,y: int32or64; AColor: pointer); override;
    procedure GetPixelCycleIndirect(x,y: int32or64; AColor: pointer); override;
    function GetPixelAddress(x, y: integer): PByte; override;
    procedure HorizontalFlip(ARect: TRect); overload; override;
    procedure RotateUDInplace(ARect: TRect); overload; override;
  end;

{$ENDIF}

{$IFDEF INCLUDE_IMPLEMENTATION}
{$UNDEF INCLUDE_IMPLEMENTATION}

{ TGenericUniversalBitmap }

function TGenericUniversalBitmap.GetDataPtr: PPixel;
begin
  result := PPixel(GetDataBytePtr);
end;

function TGenericUniversalBitmap.GetScanLine(y: integer): PPixel;
begin
  result := PPixel(GetScanLineByte(y));
end;

class function TGenericUniversalBitmap.DefaultColorspace: TColorspaceAny;
begin
  Result:= TColorspace;
end;

procedure TGenericUniversalBitmap.Init;
begin
  inherited Init;
  if FColorspace <> DefaultColorspace then raise exception.Create('Unexpected colorspace');
end;

{ Get scanline without checking bounds nor updated from bitmap }
function TGenericUniversalBitmap.GetScanlineFast(y: integer): PPixel;
begin
  if FLineOrder = riloBottomToTop then y := FHeight - 1 - y;
  result := PPixel(FDataByte+FRowSize*y);
end;

procedure TGenericUniversalBitmap.InternalCopyPixels(ASource, ADest: PByte;
  ASourceStride, ADestStride: PtrInt; ACount: integer);
begin
  while ACount>0 do
  begin
    PPixel(ADest)^ := PPixel(ASource)^;
    inc(ASource, ASourceStride);
    inc(ADest, ADestStride);
    dec(ACount);
  end;
end;

procedure TGenericUniversalBitmap.InternalSwapPixels(ABuf1, ABuf2: PByte;
  AStride1, AStride2: PtrInt; ACount: integer);
var temp: TPixel;
begin
  while ACount>0 do
  begin
    temp := PPixel(ABuf1)^;
    PPixel(ABuf1)^ := PPixel(ABuf2)^;
    PPixel(ABuf2)^ := temp;
    inc(ABuf1, AStride1);
    inc(ABuf2, AStride2);
    dec(ACount);
  end;
end;

constructor TGenericUniversalBitmap.Create(AWidth, AHeight: integer;
  const AColor: TPixel);
var
  p: PByte;
  i: Integer;
begin
  inherited Create(0, 0);
  SetSize(AWidth,AHeight);
  p := DataByte;
  for i := NbPixels-1 downto 0 do
  begin
    PPixel(p)^ := AColor;
    inc(p, sizeof(TPixel));
  end;
end;

class procedure TGenericUniversalBitmap.SolidBrush(out ABrush: TUniversalBrush;
  const AColor: TPixel; ADrawMode: TDrawMode);
begin
  SolidBrushIndirect(ABrush, @AColor, ADrawMode);
end;

procedure TGenericUniversalBitmap.SetPixelIndirect(x, y: int32or64;
  AColor: pointer);
begin
  if not PtInClipRect(x,y) then exit;
  LoadFromBitmapIfNeeded;
  (GetScanlineFast(y)+x)^ := PPixel(AColor)^;
  InvalidateBitmap;
end;

procedure TGenericUniversalBitmap.GetPixelIndirect(x, y: int32or64;
  AColor: pointer);
begin
  if (x < 0) or (x >= FWidth) or (y < 0) or (y >= FHeight) then //it is possible to read pixels outside of the cliprect
    FillByte(AColor^, FPixelSize, 0) else
  begin
    LoadFromBitmapIfNeeded;
    PPixel(AColor)^ := (GetScanlineFast(y)+x)^;
  end;
end;

procedure TGenericUniversalBitmap.GetPixelCycleIndirect(x, y: int32or64;
  AColor: pointer);
begin
  if (Width = 0) or (Height = 0) then
    FillByte(AColor^, FPixelSize, 0) else
  begin
    LoadFromBitmapIfNeeded;
    PPixel(AColor)^ := (GetScanlineFast(PositiveMod(y, Height)) + PositiveMod(x, Width))^;
  end;
end;

procedure TGenericUniversalBitmap.SetPixel(x, y: int32or64; const AColor: TPixel);
begin
  if not PtInClipRect(x,y) then exit;
  LoadFromBitmapIfNeeded;
  (GetScanlineFast(y)+x)^ := AColor;
  InvalidateBitmap;
end;

function TGenericUniversalBitmap.GetPixel(x, y: int32or64): TPixel;
begin
  GetPixelIndirect(x,y, @result);
end;

function TGenericUniversalBitmap.GetPixelCycle(x, y: int32or64): TPixel;
begin
  GetPixelCycleIndirect(x,y, @result);
end;

procedure TGenericUniversalBitmap.Fill(const AColor: TPixel);
var
  b: TUniversalBrush;
begin
  SolidBrush(b, AColor, dmSet);
  Fill(b);
end;

procedure TGenericUniversalBitmap.Fill(const AColor: TPixel; AMode : TDrawMode; AAlpha : Word);
var
  b: TUniversalBrush;
begin
  SolidBrush(b, AColor, AMode);
  Fill(b, AAlpha);
end;

procedure TGenericUniversalBitmap.FillRect(ALeft, ATop, ARight,
  ABottom: integer; const AColor: TPixel; ADrawMode: TDrawMode; AAlpha: Word);
var
  b: TUniversalBrush;
begin
  SolidBrush(b, AColor, ADrawMode);
  FillRect(ALeft,ATop,ARight,ABottom, b,AAlpha);
end;

procedure TGenericUniversalBitmap.FillRect(const ARect: TRect;
  const AColor: TPixel; ADrawMode: TDrawMode; AAlpha: Word);
var
  b: TUniversalBrush;
begin
  SolidBrush(b, AColor, ADrawMode);
  FillRect(ARect, b,AAlpha);
end;

procedure TGenericUniversalBitmap.DrawPixel(x, y: Int32or64;
  const AColor: TPixel);
var
  b: TUniversalBrush;
begin
  SolidBrush(b, AColor, dmDrawWithTransparency);
  DrawPixel(x,y, b);
end;

procedure TGenericUniversalBitmap.DrawPixel(x, y: Int32or64;
  const AColor: TPixel; ADrawMode: TDrawMode);
var
  b: TUniversalBrush;
begin
  SolidBrush(b, AColor, ADrawMode);
  DrawPixel(x,y, b);
end;

procedure TGenericUniversalBitmap.DrawPixel(x, y: Int32or64;
  const AColor: TPixel; ADrawMode: TDrawMode; AAlpha: Word);
var
  b: TUniversalBrush;
begin
  SolidBrush(b, AColor, ADrawMode);
  DrawPixel(x,y, b,AAlpha);
end;

procedure TGenericUniversalBitmap.HorizLine(x, y, x2: int32or64;
  const AColor: TPixel; AMode: TDrawMode; AAlpha: Word);
var
  b: TUniversalBrush;
begin
  SolidBrush(b, AColor, AMode);
  HorizLine(x,y,x2, b,AAlpha);
end;

procedure TGenericUniversalBitmap.VertLine(x, y, y2: int32or64;
  const AColor: TPixel; AMode: TDrawMode; AAlpha: Word);
var
  b: TUniversalBrush;
begin
  SolidBrush(b, AColor, AMode);
  VertLine(x,y,y2, b,AAlpha);
end;

procedure TGenericUniversalBitmap.DrawLine(x1, y1, x2, y2: integer;
  const AColor: TPixel; ADrawLastPixel: boolean; AMode: TDrawMode; AAlpha: Word);
var
  b: TUniversalBrush;
begin
  SolidBrush(b, AColor, AMode);
  DrawLine(x1,y1,x2,y2, b,ADrawLastPixel,AAlpha);
end;

procedure TGenericUniversalBitmap.DrawLineAntialias(x1, y1, x2, y2: integer;
  const AColor: TPixel; ADrawLastPixel: boolean; AAlpha: Word);
var
  b: TUniversalBrush;
begin
  SolidBrush(b, AColor, AntialiasingDrawMode);
  DrawLineAntialias(x1,y1,x2,y2, b,ADrawLastPixel,AAlpha);
end;

procedure TGenericUniversalBitmap.DrawLineAntialias(x1, y1, x2, y2: integer;
  const AColor1, AColor2: TPixel; ADashLen: integer;
  ADrawLastPixel: boolean; AAlpha: Word);
var
  b1, b2: TUniversalBrush;
begin
  SolidBrush(b1, AColor1, AntialiasingDrawMode);
  SolidBrush(b2, AColor2, AntialiasingDrawMode);
  DrawLineAntialias(x1,y1,x2,y2, b1,b2, ADashLen, ADrawLastPixel, AAlpha);
end;

procedure TGenericUniversalBitmap.DrawLineAntialias(x1, y1, x2, y2: integer;
  const AColor1, AColor2: TPixel; ADashLen: integer;
  var ADashPos: integer; ADrawLastPixel: boolean; AAlpha: Word);
var
  b1, b2: TUniversalBrush;
begin
  SolidBrush(b1, AColor1, AntialiasingDrawMode);
  SolidBrush(b2, AColor2, AntialiasingDrawMode);
  DrawLineAntialias(x1,y1,x2,y2, b1,b2, ADashLen,ADashPos, ADrawLastPixel, AAlpha);
end;

procedure TGenericUniversalBitmap.DrawPolyLine(const points: array of TPoint;
  const AColor: TPixel; ADrawLastPixel: boolean; AMode: TDrawMode; AAlpha: Word);
var
  b: TUniversalBrush;
begin
  SolidBrush(b, AColor, AMode);
  DrawPolyLine(points, b, ADrawLastPixel, AAlpha);
end;

procedure TGenericUniversalBitmap.DrawPolyLineAntialias(
  const points: array of TPoint; const AColor: TPixel;
  ADrawLastPixel: boolean; AAlpha: Word);
var
  b: TUniversalBrush;
begin
  SolidBrush(b, AColor, AntialiasingDrawMode);
  DrawPolyLineAntialias(points, b,ADrawLastPixel,AAlpha);
end;

procedure TGenericUniversalBitmap.DrawPolyLineAntialias(
  const points: array of TPoint; const AColor1, AColor2: TPixel;
  ADashLen: integer; ADrawLastPixel: boolean; AAlpha: Word);
var
  b1, b2: TUniversalBrush;
begin
  SolidBrush(b1, AColor1, AntialiasingDrawMode);
  SolidBrush(b2, AColor2, AntialiasingDrawMode);
  DrawPolyLineAntialias(points, b1,b2,ADashLen, ADrawLastPixel,AAlpha);
end;

procedure TGenericUniversalBitmap.DrawPolygon(const points: array of TPoint;
  const AColor: TPixel; AMode : TDrawMode; AAlpha: Word);
var
  b: TUniversalBrush;
begin
  SolidBrush(b, AColor, AMode);
  DrawPolygon(points, b,AAlpha);
end;

procedure TGenericUniversalBitmap.DrawPolygonAntialias(
  const points: array of TPoint; const AColor: TPixel; AAlpha: Word);
var
  b: TUniversalBrush;
begin
  SolidBrush(b, AColor, AntialiasingDrawMode);
  DrawPolygonAntialias(points, b,AAlpha);
end;

procedure TGenericUniversalBitmap.DrawPolygonAntialias(
  const points: array of TPoint; const AColor1, AColor2: TPixel;
  ADashLen: integer; AAlpha: Word);
var
  b1, b2: TUniversalBrush;
begin
  SolidBrush(b1, AColor1, AntialiasingDrawMode);
  SolidBrush(b2, AColor2, AntialiasingDrawMode);
  DrawPolygonAntialias(points, b1,b2,ADashLen, AAlpha);
end;

procedure TGenericUniversalBitmap.DrawPathAliased(APath: IBGRAPath;
  const AColor: TPixel; AMode: TDrawMode; APixelCenteredCoordinates: boolean;
  AAlpha: Word);
var
  b: TUniversalBrush;
begin
  SolidBrush(b, AColor,AMode);
  DrawPathAliased(APath, b,APixelCenteredCoordinates,AAlpha);
end;

procedure TGenericUniversalBitmap.DrawPathAliased(APath: IBGRAPath;
  const AMatrix: TAffineMatrix; const AColor: TPixel; AMode: TDrawMode;
  APixelCenteredCoordinates: boolean; AAlpha: Word);
var
  b: TUniversalBrush;
begin
  SolidBrush(b, AColor,AMode);
  DrawPathAliased(APath,AMatrix, b,APixelCenteredCoordinates,AAlpha);
end;

procedure TGenericUniversalBitmap.Rectangle(x, y, x2, y2: integer;
  const AColor: TPixel; AMode: TDrawMode; AAlpha: Word);
var
  b: TUniversalBrush;
begin
  SolidBrush(b, AColor, AMode);
  Rectangle(x,y,x2,y2, b,AAlpha);
end;

procedure TGenericUniversalBitmap.Rectangle(x, y, x2, y2: integer;
  const ABorderColor, AFillColor: TPixel; AMode: TDrawMode; AAlpha: Word);
var
  bBorder,bFill: TUniversalBrush;
begin
  SolidBrush(bBorder, ABorderColor, AMode);
  SolidBrush(bFill, AFillColor, AMode);
  Rectangle(x,y,x2,y2, bBorder,bFill,AAlpha);
end;

procedure TGenericUniversalBitmap.Rectangle(const ARect: TRect;
  const AColor: TPixel; AMode: TDrawMode; AAlpha: Word);
begin
  Rectangle(ARect.Left,ARect.Top,ARect.Right,ARect.Bottom, AColor,AMode,AAlpha);
end;

procedure TGenericUniversalBitmap.Rectangle(const ARect: TRect;
  const ABorderColor, AFillColor: TPixel; AMode: TDrawMode; AAlpha: Word);
begin
  Rectangle(ARect.Left,ARect.Top,ARect.Right,ARect.Bottom, ABorderColor,AFillColor,AMode,AAlpha);
end;

procedure TGenericUniversalBitmap.RoundRect(X1, Y1, X2, Y2: integer; DX,
  DY: integer; const ABorderColor: TPixel; AMode: TDrawMode; AAlpha: Word);
var
  b: TUniversalBrush;
begin
  SolidBrush(b, ABorderColor,AMode);
  RoundRect(X1,Y1,X2,Y2,DX,DY, b,AAlpha);
end;

procedure TGenericUniversalBitmap.RoundRect(X1, Y1, X2, Y2: integer; DX,
  DY: integer; const ABorderColor, AFillColor: TPixel; AMode: TDrawMode;
  AAlpha: Word);
var
  bBorder, bFill: TUniversalBrush;
begin
  SolidBrush(bBorder, ABorderColor,AMode);
  SolidBrush(bFill, AFillColor,AMode);
  RoundRect(X1,Y1,X2,Y2,DX,DY, bBorder,bFill,AAlpha);
end;

procedure TGenericUniversalBitmap.FillRoundRect(X1, Y1, X2, Y2: integer; DX,
  DY: integer; const AFillColor: TPixel; AMode: TDrawMode; AAlpha: Word);
var
  bFill: TUniversalBrush;
begin
  SolidBrush(bFill, AFillColor,AMode);
  FillRoundRect(X1,Y1,X2,Y2,DX,DY, bFill,AAlpha);
end;

procedure TGenericUniversalBitmap.EllipseInRect(ARect: TRect;
  const ABorderColor: TPixel; AMode: TDrawMode; AAlpha: Word);
var
  b: TUniversalBrush;
begin
  SolidBrush(b, ABorderColor,AMode);
  EllipseInRect(ARect, b,AAlpha);
end;

procedure TGenericUniversalBitmap.EllipseInRect(ARect: TRect;
  const ABorderColor, AFillColor: TPixel; AMode: TDrawMode; AAlpha: Word);
var
  bBorder, bFill: TUniversalBrush;
begin
  SolidBrush(bBorder, ABorderColor,AMode);
  SolidBrush(bFill, AFillColor,AMode);
  EllipseInRect(ARect, bBorder,bFill,AAlpha);
end;

procedure TGenericUniversalBitmap.FillEllipseInRect(ARect: TRect;
  const AFillColor: TPixel; AMode: TDrawMode; AAlpha: Word);
var
  bFill: TUniversalBrush;
begin
  SolidBrush(bFill, AFillColor,AMode);
  FillEllipseInRect(ARect, bFill,AAlpha);
end;

procedure TGenericUniversalBitmap.FillShape(AShape: TBGRACustomFillInfo;
  const AFillColor: TPixel; AMode: TDrawMode; AAlpha: Word);
var
  bFill: TUniversalBrush;
begin
  SolidBrush(bFill, AFillColor,AMode);
  FillShape(AShape, bFill,AAlpha);
end;

procedure TGenericUniversalBitmap.FillPoly(const APoints: array of TPointF;
  const AFillColor: TPixel; AMode: TDrawMode;
  APixelCenteredCoordinates: boolean; AAlpha: Word);
var
  bFill: TUniversalBrush;
begin
  SolidBrush(bFill, AFillColor,AMode);
  FillPoly(APoints,bFill,APixelCenteredCoordinates,AAlpha);
end;

procedure TGenericUniversalBitmap.FillPathAliased(APath: IBGRAPath;
  const AFillColor: TPixel; AMode: TDrawMode;
  APixelCenteredCoordinates: boolean; AAlpha: Word);
var
  bFill: TUniversalBrush;
begin
  SolidBrush(bFill, AFillColor,AMode);
  FillPathAliased(APath,bFill,APixelCenteredCoordinates,AAlpha);
end;

procedure TGenericUniversalBitmap.FillPathAliased(APath: IBGRAPath;
  const AMatrix: TAffineMatrix; const AFillColor: TPixel; AMode: TDrawMode;
  APixelCenteredCoordinates: boolean; AAlpha: Word);
var
  bFill: TUniversalBrush;
begin
  SolidBrush(bFill, AFillColor,AMode);
  FillPathAliased(APath,AMatrix, bFill,APixelCenteredCoordinates,AAlpha);
end;

function TGenericUniversalBitmap.GetPixelAddress(x, y: integer): PByte;
begin
  if FLineOrder = riloBottomToTop then y := FHeight - 1 - y;
  result := FDataByte + FRowSize * y + IntPtr(x)*sizeof(TPixel);
end;

procedure TGenericUniversalBitmap.HorizontalFlip(ARect: TRect);
begin
  inherited HorizontalFlip(ARect);
end;

procedure TGenericUniversalBitmap.RotateUDInplace(ARect: TRect);
begin
  inherited RotateUDInplace(ARect);
end;

{$ENDIF}