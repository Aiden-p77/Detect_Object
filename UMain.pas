unit UMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtDlgs, Vcl.StdCtrls, Vcl.ExtCtrls;
//  sysutils,Ioutils;

type
  TFMain = class(TForm)
    MainImg: TImage;
    DetectImg: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Button1: TButton;
    Button2: TButton;
    MainImg2: TImage;
    Label3: TLabel;
    Button3: TButton;
    Button4: TButton;
    LDarsad: TLabel;
    OpenPicture: TOpenPictureDialog;
    Button5: TButton;
    CbBackground: TColorBox;
    Label4: TLabel;
    CbDraw: TColorBox;
    Label5: TLabel;
    CBDetect: TCheckBox;
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FMain: TFMain;
type
  PRGBTripleArray = ^TRGBTripleArray;
  TRGBTripleArray = array[0..4095] of TRGBTriple;
implementation

{$R *.dfm}
Procedure  CreateObject (ColorP:TColor;X,Y:Integer;Var BMap:TBitmap;PKamel:Boolean);
begin
  if PKamel = false then
  begin
    BMap:=TBitmap.Create;
    BMap.Height:=100000;
    BMap.Width:=100000;
    BMap.Canvas.Pixels[X,Y]:=ColorP;
  end;
end;

Function  DetectObject (IMG:TImage):TBITMAP;
var
  C: TColor;
  X,Y,PosH,PosW: Integer;
  Bitmap: TBitmap;
  Pixels: PRGBTripleArray;
begin
  PosH:=0;
  Bitmap := TBitmap.Create;
  try
    Bitmap.Assign(Img.Picture.Graphic);
    PosW:=Bitmap.Width;
    for Y := 0 to Bitmap.Height - 1 do
    begin
      Pixels := Bitmap.ScanLine[Y];
      for X := 0 to Bitmap.Width - 1 do
      begin
        if (Pixels[X].rgbtRed > 230) and (Pixels[X].rgbtGreen > 200) then
        begin
          C := RGB(Pixels[X].rgbtRed,Pixels[X].rgbtGreen,Pixels[X].rgbtBlue);
          if (C = clBlack) or (C = clWhite) then
            Continue
          else
          begin
            CreateObject(C,X,Y,Result,false);
            if (Y > PosH) and (X < PosW) then
            begin
              PosH:=Y;
              PosW:=X;
            end
            else
            begin
              PosH:=Y;
              PosW:=X-1;
            end;
          end;
        end;
      end;
    end;
  finally
    Bitmap.Free;
  end;
end;

procedure TFMain.Button1Click(Sender: TObject);
var    BMp:TBitmap;
begin
   DetectImg.Picture.Bitmap:=DetectObject(MainImg);
   BMp:=TBitmap.Create;
   BMp.Height:=100;
   BMp.Width:=100;
   BMp.Canvas.Pixels[10,10]:=Clred;
   DetectImg.Picture.Bitmap:=BMp;
   BMp.Free;
end;

procedure TFMain.Button2Click(Sender: TObject);
begin
  OpenPicture.Execute;
  MainImg.Picture.LoadFromFile(OpenPicture.FileName);
end;

procedure TFMain.Button3Click(Sender: TObject);
begin
  OpenPicture.Execute;
  MainImg2.Picture.LoadFromFile(OpenPicture.FileName);
end;



procedure Detect_Obj(bit:TBitmap;ColorBack,ColorDraw:TColor;BDetectColor:boolean);
var hei,wid,x,y:integer;
    Count,Count2:integer;
    piece:Double;
    Color2:TColor;
begin
  Count:=0;
  Count2:=0;
  hei:=bit.Height;
  wid:=bit.Width;
  piece:=(bit.Width*2)/3;
  if BDetectColor = true then
  begin
    ColorBack:=bit.Canvas.Pixels[1,1];
    for x := 1 to wid do
    begin
      if bit.Canvas.Pixels[x,1] = ColorBack then
      begin
        Count:=Count+1;
      end
      else
      begin
        Color2:=bit.Canvas.Pixels[x,1];
        Count2:=Count2+1;
      end;
    end;
    if Count >= piece then
    begin
      ColorBack:=bit.Canvas.Pixels[1,1];
    end;
    if Count2 >= piece then
    begin
      ColorBack:=Color2;
    end;
  end;
  for y := 1 to hei do
  begin
    for x := 1 to wid do
    begin
      if bit.Canvas.Pixels[x,y] <> ColorBack then
      begin
        bit.Canvas.Pixels[x,y] := ColorDraw;
      end
      else
      begin
        bit.Canvas.Pixels[x,y] := bit.Canvas.Pixels[x,y];
      end;
    end;
  end;
end;

function timeGetTime: DWord; stdcall; external 'winmm.dll' name 'timeGetTime';

procedure TFMain.Button5Click(Sender: TObject);
var Time:DWORD;
begin
  Time:=timeGetTime;
  Detect_Obj(MainImg2.Picture.Bitmap,CbBackground.Selected,CbDraw.Selected,CBDetect.Checked);
  Time:=timeGetTime-Time;
  Caption:=IntToStr(Time)+' Ms.';
end;

{procedure Test;
var
  Pict, StoredPict : OleVariant;
begin
  // Obtains one of the images
  Pict := Sys.Desktop.PictureUnderMouse(20, 20, False);

  // Obtains stored image
  StoredPict := Regions.GetPicture('StoredImageName');

  if ( Pict.Find(StoredPict) = nil ) then
    Log.Warning('Not found');
end; }

end.
