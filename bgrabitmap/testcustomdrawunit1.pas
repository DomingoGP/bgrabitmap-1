unit TestCustomDrawUnit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls
  ,BGRABitmap,BGRAGraphics, BGRABitmapTypes, BGRAGradients;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

uses
  math,bgracustomdrawmode,bgrablend,BGRAPolygon,bgradefaultbitmap,bgrapen;

var
  BackgroundColor:TBGRAPixel;

{ TForm1 }

// definition of the custom draw modes.
// custom draw mode samples 2 function for mode, with and without opacity

// custom draw mode only write if not empty-----------------------------------------------
procedure ColorProcCustomDrawNotEmpty(colSource: TBGRAPixel;colDest: PBGRAPixel);
var
  wTemp:TBGRAPixel;
begin
  if colDest^<>BackgroundColor then
  begin
    wTemp:=colDest^;
    DrawPixelInlineWithAlphaCheck(@wTemp, colSource);
    //  wTemp.blue:=128;
    colDest^:=wTemp;
  end;
end;

procedure ColorProcWithOpacityCustomDrawNotEmpty(colSource: TBGRAPixel;colDest: PBGRAPixel;AOpacity:byte);
begin
  if colDest^<>BackgroundColor then
    colDest^:=MergeBGRAWithGammaCorrection(colSource,AOpacity,colDest^,not AOpacity);
end;

var
  CustomDrawModeNotEmpty:TCustomDrawMode=(ColorProc:@ColorProcCustomDrawNotEmpty;ColorProcWithOpacity:@ColorProcWithOpacityCustomDrawNotEmpty;Data:0;Value:0);

// custom draw mode only write if empty ----------------------------------------------
procedure ColorProcCustomDrawEmpty(colSource: TBGRAPixel;colDest: PBGRAPixel);
begin
  if colDest^=BackgroundColor then
   colDest^:=colSource;
end;

procedure ColorProcWithOpacityCustomDrawEmpty(colSource: TBGRAPixel;colDest: PBGRAPixel;AOpacity:byte);
begin
  if colDest^=BackgroundColor then
    colDest^:=MergeBGRAWithGammaCorrection(colSource,AOpacity,colDest^,not AOpacity);
end;

var
  CustomDrawModeEmpty:TCustomDrawMode=(ColorProc:@ColorProcCustomDrawEmpty;ColorProcWithOpacity:@ColorProcWithOpacityCustomDrawEmpty;Data:0;Value:0);

// custom draw mode invert dest----------------------------------------------------------
procedure ColorProcCustomDrawInvertDst(colSource: TBGRAPixel;colDest: PBGRAPixel);
var
  wR : TBGRAPixel;
begin
   wR:=colDest^;
   wR.red:=255-colDest^.red;
   wR.green:=255-colDest^.green;
   wR.blue:=255-colDest^.blue;
   wR.alpha:=colDest^.alpha;
   colDest^:=wR;
end;

procedure ColorProcWithOpacityCustomDrawInvertDst(colSource: TBGRAPixel;colDest: PBGRAPixel;AOpacity:byte);
var
  wR : TBGRAPixel;
begin
  wR:=MergeBGRAWithGammaCorrection(colSource,AOpacity,colDest^,not AOpacity);
  wR.red:=255-wR.red;
  wR.green:=255-wR.green;
  wR.blue:=255-wR.blue;
  colDest^:=wR;
end;

var
  CustomDrawModeInvertDst:TCustomDrawMode=(ColorProc:@ColorProcCustomDrawInvertDst;ColorProcWithOpacity:@ColorProcWithOpacityCustomDrawInvertDst;Data:0;Value:0);

// custom draw mode equal to dmFastBlend-----------------------------------------------
procedure ColorProcCustomDrawFastBlend(colSource: TBGRAPixel;colDest: PBGRAPixel);
begin
  FastBlendPixelInline(colDest,colSource);
end;

procedure ColorProcWithOpacityCustomDrawFastBlend(colSource: TBGRAPixel;colDest: PBGRAPixel;AOpacity:byte);
begin
  FastBlendPixelInline(colDest,colSource,AOpacity);
end;
var
  CustomDrawModeFastBlend:TCustomDrawMode=(ColorProc:@ColorProcCustomDrawFastBlend;ColorProcWithOpacity:@ColorProcWithOpacityCustomDrawFastBlend;Data:0;Value:0);
//-------------------------------------------------------------------------------------------------------------------

procedure TForm1.Button1Click(Sender: TObject);
var
  image: TBGRABitmap;
  YellowColor: TBGRAPixel;
const
  X0_linea=130;
  X1_linea=X0_linea+250;
begin
  //BackgroundColor:=BGRA(240,240,240,255);
  BackgroundColor:=BGRA(240,255,240,255);
  YellowColor:=BGRA(200,200,0,255);
  image := TBGRABitmap.Create(ClientWidth,ClientHeight,BackgroundColor);

  CurrentCustomDrawMode:=CustomDrawModeInvertDst;
  image.DrawPolygon([Point(50,50),Point(100,100),Point(75,150),Point(50,100)],BGRA(200,0,0),dmCustomDraw);

  PushCustomDrawMode;

  image.DrawPolygonAntialias([PointF(50,150),PointF(100,200),PointF(75,250),PointF(50,200)],BGRA(200,0,0),3,BGRA(0,200,0),dmCustomDraw);
  image.fillPolyAntialias([PointF(300,150),PointF(450,200),PointF(475,550),PointF(300,500)],BGRA(160,140,240,128),true);     //lavender

  CurrentCustomDrawMode:=CustomDrawModeNotEmpty;
  image.Rectangle(280,230,500,280,BGRA(120,0,0,128),dmSet);
  image.FillRect(280,230,500,280,BGRA(120,0,0,170),dmCustomDraw);

  CurrentCustomDrawMode:=CustomDrawModeEmpty;
  image.Rectangle(280,300,500,350,BGRA(120,0,0,128),dmSet);
  image.FillRect(280,300,500,350,BGRA(120,0,0,128),dmCustomDraw);
  //CurrentCustomDrawMode:=CustomDrawModeInvertDst;
  PopCustomDrawMode;

  image.Rectangle(280,380,500,430,BGRA(120,0,0,128),dmSet);
  image.FillRect(280,380,500,430,BGRA(120,0,0,128),dmCustomDraw);
  image.PenStyle := psDot;
  image.DrawLineAntialias(240,150,490,480,BGRA(200,0,0,255),10,true);
  image.DrawPolyLineAntialias([PointF(270,150),PointF(520,480)],YellowColor,10,YellowColor,true,dmCustomDraw);
  CurrentCustomDrawMode:=CustomDrawModeFastBlend;
  image.DrawPolyLineAntialias([PointF(270+30,150),PointF(520+30,480)],BGRA(255,0,0),10,YellowColor,true,dmCustomdraw);
  CurrentCustomDrawMode:=CustomDrawModeEmpty;
  //CurrentCustomDrawMode:=CustomDrawModeNotEmpty;
  FillEllipseAntialias(image,280,130,90,80,BGRA(0,255,0,80),false,dmCustomDraw);
  image.Draw(Canvas,0,0,True);
  image.free;
end;

end.

