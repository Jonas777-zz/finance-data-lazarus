unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  //record to contain each node of data
  TData = record
    date : string;
    open, high, low, close, volume : extended;
  end;

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
  //file to be read in
  tf: TextFile;
  //temporary storage variables to parse data
  s: string;
  data: string;
  dataList: TStringList;
  index: integer;
  P: PChar;
  //array to hold parsed data
  parsedData: array of TData;


implementation

{$R *.lfm}

{ TForm1 }

//helper to print a node's data
procedure printNode(i : integer; VAR Memo1 : TMemo);
begin
  Memo1.lines.add(parsedData[i].date);
  Memo1.lines.add(FloatToStr(parsedData[i].open));
  Memo1.lines.add(FloatToStr(parsedData[i].high));
  Memo1.lines.add(FloatToStr(parsedData[i].low));
  Memo1.lines.add(FloatToStr(parsedData[i].close));
  Memo1.lines.add(FloatToStr(parsedData[i].volume));
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

    //loop to read in file line by line
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

  //split data on closing bracket to separate nodes
  dataList := TStringList.Create;
  dataList.Delimiter := '}';
  dataList.StrictDelimiter := True;
  dataList.DelimitedText := data;

  //get rid of header and 3 trailing closing brackets
  dataList.Delete(0);
  for index := 0 to 2 do
  begin
    dataList.Delete(dataList.count - 1);
  end;

  //main parsing loop
  SetLength(parsedData, dataList.count);
  s := '';
  for index := 0 to dataList.count - 1 do
  begin

    //must trim meta data off front if it is the first node
    if index = 0 then
      s := Copy(dataList[0], 38, 999)
    else
      s := Copy(dataList[index], 10, 999);

    P := Pchar(s);
    parsedData[index].date := AnsiExtractQuotedStr(P, '"');

    //seek through string using the Pos fucntion to find each value
    s := Copy(s, Pos('open', s) + 7, 999);
    P := Pchar(s);
    parsedData[index].open := StrToFloat(AnsiExtractQuotedStr(P, '"'));

    s := Copy(s, Pos('high', s) + 7, 999);
    P := Pchar(s);
    parsedData[index].high := StrToFloat(AnsiExtractQuotedStr(P, '"'));

    s := Copy(s, Pos('low', s) + 6, 999);
    P := Pchar(s);
    parsedData[index].low := StrToFloat(AnsiExtractQuotedStr(P, '"'));

    s := Copy(s, Pos('close', s) + 8, 999);
    P := Pchar(s);
    parsedData[index].close := StrToFloat(AnsiExtractQuotedStr(P, '"'));

    s := Copy(s, Pos('volume', s) + 9, 999);
    P := Pchar(s);
    parsedData[index].volume := StrToFloat(AnsiExtractQuotedStr(P, '"'));
  end;

  Memo1.lines.add('First node: ');
  printNode(0, Memo1);

  Memo1.lines.add('Last node: ');
  printNode(length(parsedData) - 1, Memo1);

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

