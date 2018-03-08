unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private

  public

  end;

const
  C_FNAME = 'Sample_Time_Series_Daily.txt';

var
  Form1: TForm1;
  tf: TextFile;
  s: string;
  data: string;
  dataList: TStringList;
  temp: TStringList;
  index: integer;
  parsedData: array of TStringList;
  P: PChar;

implementation

{$R *.lfm}

{ TForm1 }

procedure addToData (i : integer; entry : TStringList; VAR list : array of TStringList);
begin
  list[i] := entry;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  Memo1.Lines.Clear;
  Memo1.Lines.add('Reading file: ');
  Memo1.Lines.add(C_FNAME);

  AssignFile(tf, C_FNAME);

  data := '';
  try
    reset(tf);

    while not eof(tf) do
    begin
      readln(tf, s);
      data := data + s;
    end;
    Memo1.Lines.add('eof');
    CloseFile(tf);
  except
    on E: EInOutError do
       Memo1.Lines.add(E.Message);
  end;

  dataList := TStringList.Create;
  dataList.Delimiter := '}';
  dataList.StrictDelimiter := True;
  dataList.DelimitedText := data;

  dataList.Delete(0);

  SetLength(parsedData, dataList.count - 3);
  temp := TStringList.Create;
  s := '';

  for index := 0 to dataList.count - 4 do
  begin

    if index = 0 then
      s := Copy(dataList[0], 38, 999)
    else
      s := Copy(dataList[index], 10, 999);

    parsedData[index] := TStringList.Create;

    P := Pchar(s);
    parsedData[index].add(AnsiExtractQuotedStr(P, '"'));

    s := Copy(s, Pos('open', s) + 7, 999);
    P := Pchar(s);
    parsedData[index].add(AnsiExtractQuotedStr(P, '"'));

    s := Copy(s, Pos('high', s) + 7, 999);
    P := Pchar(s);
    parsedData[index].add(AnsiExtractQuotedStr(P, '"'));

    s := Copy(s, Pos('low', s) + 6, 999);
    P := Pchar(s);
    parsedData[index].add(AnsiExtractQuotedStr(P, '"'));

    s := Copy(s, Pos('close', s) + 8, 999);
    P := Pchar(s);
    parsedData[index].add(AnsiExtractQuotedStr(P, '"'));

    s := Copy(s, Pos('volume', s) + 9, 999);
    P := Pchar(s);
    parsedData[index].add(AnsiExtractQuotedStr(P, '"'));

    Memo1.lines.add(parsedData[index][0]);
    Memo1.lines.add('---------------------------');
  end;

  Memo1.lines.add('First node: ');
  for index := 0 to 5 do
  begin
    Memo1.lines.add(parsedData[0][index]);
  end;

  Memo1.lines.add('Last node: ');
  for index := 0 to 5 do
  begin
    Memo1.lines.add(parsedData[length(parsedData) - 1][index]);
  end;

  temp.Free;
  dataList.Free;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  Close;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin

end;

end.

