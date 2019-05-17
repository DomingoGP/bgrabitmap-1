unit bgracustomdrawmode;
{
   Note: for implement a custom draw mode is necesary implement 2 functions and create a record with pointers to these functions.
   It is easy to implement a custom draw mode only writing 2 procedures but it's slower than native modes.


  TCustomDrawMode=record
    ColorProc: procedure(colSource: TBGRAPixel;colDest: PBGRAPixel);
    ColorProcWithOpacity: procedure(colSource: TBGRAPixel;colDest: PBGRAPixel;AOpacity:byte);
    Data:NativeUint; //placeholder for needed data pointer, for zbuffer, etc.
    Value:Byte;      //placeholder for possibly needed value umbral, etc.
  end;

  USING IN MULTITHREAD.
    it is necessary call CustomDrawThreadFinalize before exit the thread to avoid a memory leak, also
    it is necessay call CustomDrawThreadInit when starting the thread.
}

interface
uses
  BGRABitmapTypes;

type
  TCustomDrawMode=record
    //colDest^:= colSource;//  for dmSet;
    ColorProc: procedure(colSource: TBGRAPixel;colDest: PBGRAPixel);
    ColorProcWithOpacity: procedure(colSource: TBGRAPixel;colDest: PBGRAPixel;AOpacity:byte);
    Data:NativeUint; //placeholder for needed data pointer, for zbuffer, etc.
    Value:Byte;      //placeholder for possibly needed value umbral, etc.
  end;

procedure ColorProcCustomDrawDef(colSource: TBGRAPixel;colDest: PBGRAPixel);
procedure ColorProcWithOpacityCustomDrawDef(colSource: TBGRAPixel;colDest: PBGRAPixel;AOpacity:byte);

procedure PushCustomDrawMode;
procedure PopCustomDrawMode;
procedure CustomDrawThreadInit;
procedure CustomDrawThreadFinalize;

var

{$IFDEF FPC}
  CustomDrawDefault:TCustomDrawMode=(ColorProc:@ColorProcCustomDrawDef;ColorProcWithOpacity:@ColorProcWithOpacityCustomDrawDef;Data:0;Value:0);
  CustomDrawSet:TCustomDrawMode=(ColorProc:@ColorProcCustomDrawDef;ColorProcWithOpacity:@ColorProcWithOpacityCustomDrawDef;Data:0;Value:0);
{$ELSE} //delphi
  CustomDrawDefault:TCustomDrawMode=(ColorProc:ColorProcCustomDrawDef;ColorProcWithOpacity:ColorProcWithOpacityCustomDrawDef;Data:0;Value:0);
  CustomDrawSet:TCustomDrawMode=(ColorProc:ColorProcCustomDrawDef;ColorProcWithOpacity:ColorProcWithOpacityCustomDrawDef;Data:0;Value:0);
{$ENDIF}

// Mode used
threadvar
  CurrentCustomDrawMode:TCustomDrawMode;

implementation

uses
  sysutils,Generics.Collections;

type
  TStackCDM  =specialize TStack<TCustomDrawMode>;
threadvar
  CustomDrawModesStack:TStackCDM;

{------------------------------------------------------------------------------}
{ functions custom draw mode default. =dmSet}
{ these functions returns the color that will be set in dest.}
procedure ColorProcCustomDrawDef(colSource: TBGRAPixel;colDest: PBGRAPixel);
begin
  colDest^:=colSource;
end;

procedure ColorProcWithOpacityCustomDrawDef(colSource: TBGRAPixel;colDest: PBGRAPixel;AOpacity:byte);
begin
  colDest^:=MergeBGRAWithGammaCorrection(colSource,AOpacity,colDest^,not AOpacity);
end;
{------------------------------------------------------------------------------}

procedure PushCustomDrawMode;
begin
  if CustomDrawModesStack=nil then
    CustomDrawModesStack:=TStackCDM.Create;
  CustomDrawModesStack.Push(CurrentCustomDrawMode);
end;

procedure PopCustomDrawMode;
begin
  if CustomDrawModesStack=nil then
  begin
    raise Exception.Create('CustomDraw Stack Pop Error');
    Exit;
  end;
  CurrentCustomDrawMode:=CustomDrawModesStack.Pop;
end;


procedure CustomDrawThreadInit;
begin
  CurrentCustomDrawMode:=CustomDrawDefault;
end;

procedure CustomDrawThreadFinalize;
begin
  CustomDrawModesStack.Free;

end;

initialization
  CustomDrawThreadInit;
finalization
  CustomDrawThreadFinalize;
end.
