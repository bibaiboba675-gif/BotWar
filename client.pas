
unit client;

interface // описывает все переменные и функции которые доступны подключив модуль

uses System, System.IO, System.Net, System.Net.Sockets;

const
  size = 10;

var
  board: array[0..size-1, 0..size-1] of integer;
  yourturn: boolean;
  curtype: string;

procedure Connect();
procedure GetState();
procedure SendMove(row, col: integer);
procedure Disconnect();
procedure Play(fchoose : procedure(var row,col : integer));
procedure Init(ip: string; port: integer);
implementation // здесь само описание функций 

var
  connection: TcpClient;
  reader: StreamReader;
  writer: StreamWriter;
  ServerIP: string := '127.0.0.1';
  ServerPort: integer := 5000;
procedure Connect();
begin
  connection := new TcpClient();
  connection.Connect(ServerIp,ServerPort);
  var net := connection.GetStream();
  reader := new StreamReader(net);
  writer := new StreamWriter(net);
end;

procedure GetState();
begin
  curtype := reader.ReadLine();//state,move,game_over,error
  yourturn := reader.ReadLine() = 'True';
  for var i := 0 to size-1 do
    for var j := 0 to size-1 do
      board[i,j] := StrToInt(reader.ReadLine());
end;

procedure SendMove(row, col: integer);
begin
  writer.WriteLine(row);
  writer.WriteLine(col);
  writer.Flush();
end;

procedure Disconnect();
begin
  connection.close;
end;
procedure Init(ip: string; port: integer);
begin
  ServerIP:=ip;
  ServerPort:=port;
end;
procedure Play(fchoose: procedure(var row, col: integer));
begin
  Connect();
  try
    while true do
    begin
      GetState();
      if curtype = 'game_over' then
        begin
          if yourturn then writeln('я победил')
          else writeln('я проиграл');
          break;
        end
        else if curtype = 'draw' then
        begin
          writeln('ничья');
          break;
        end
        else if curtype = 'error' then
        begin
          if yourturn then writeln('я ошибся, прости')
          else writeln('он ошибся, ахахахаха');
          break;
        end;
      if yourturn then
      begin
        var row, col: integer;
        fchoose(row, col);
        SendMove(row, col);
      end;
    end;
  finally
    Disconnect();
  end;
end;
end.
