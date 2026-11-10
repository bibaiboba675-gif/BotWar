// BotWar v2 - сервер
uses System, System.IO, System.Net, System.Net.Sockets, System.Diagnostics;

const

  VPort = 5001; // НЕДОДЕЛАНО, порт зрителя
  TurnTimeoutMs = 2000;
type
  Tplayer = class
    Client: TcpClient;
    Reader: StreamReader;
    Writer: StreamWriter;
  end;

var
  N : integer = 10;
  wincount : integer = 5;
  board: array of array of integer;
  FigTurn: integer;
  Players: array[1..2] of Tplayer;
  listener: TCPlistener;
  

procedure StartServer();
begin
  listener := new TcpListener(IPAddress.Loopback, 6767);
  listener.Start;

  for var i := 1 to 2 do
  begin
    Writeln('Ждём бота ', i);
    
    players[i] := new Tplayer;
    players[i].client := listener.AcceptTcpClient();
    
    var net := players[i].Client.GetStream;
    players[i].reader := new streamreader(net);
    players[i].writer := new streamwriter(net);
    
    Writeln('Бот ', i, ' подключён!');
  end;
end;
procedure SendState(id: integer;curtype: string);
begin
  var writer := players[id].Writer;
  writer.writeline(curtype);
  if figturn = id then writer.writeline(True)
  else writer.writeline(False);
  writer.WriteLine(N);
  writer.WriteLine(Wincount);
  for var i:=0 to N-1 do
    for var j := 0 to N-1 do
      writer.writeline(board[i,j]);
  writer.Flush;
end;
function CheckDraw(): boolean;
begin
  Result := true;
  for var i := 0 to N - 1 do
    for var j := 0 to N - 1 do
      if board[i, j] = 0 then
      begin
        Result := false;
        exit;
      end;
end;

procedure SwitchTurn();
begin
  if FigTurn = 1 then FigTurn := 2
  else FigTurn := 1;
end;

function ValidMove(row, col: integer): boolean;
begin
  Result := false;
  if (row >= 0) and (row < N) and (col >= 0) and (col < N) then
    Result := board[row, col] = 0;
end;

function ApplyMove(row, col: integer): boolean;
begin
  Result := ValidMove(row, col);
  if Result then
    board[row, col] := FigTurn;
end;

function CheckWin(col, row, fig, win: integer): boolean;
var
  count: integer;
begin
  Result := false;
  count := 0;
  for var i := 0 to N - 1 do
  begin
    if board[i, col] = fig then
    begin
      count += 1;
      if count >= win then begin Result := true; exit; end;
    end
    else count := 0;
  end;

  count := 0;
  for var i := 0 to N - 1 do
  begin
    if board[row, i] = fig then
    begin
      count += 1;
      if count >= win then begin Result := true; exit; end;
    end
    else count := 0;
  end;

  count := 0;
  for var i := -N to N do
  begin
    var r := row + i;
    var c := col + i;
    if (r >= 0) and (r < N) and (c >= 0) and (c < N) then
    begin
      if board[r, c] = fig then
      begin
        count += 1;
        if count >= win then begin Result := true; exit; end;
      end
      else count := 0;
    end;
  end;

  count := 0;
  for var i := -N to N do
  begin
    var r := row + i;
    var c := col - i;
    if (r >= 0) and (r < N) and (c >= 0) and (c < N) then
    begin
      if board[r, c] = fig then
      begin
        count += 1;
        if count >= win then begin Result := true; exit; end;
      end
      else count := 0;
    end;
  end;
end;


procedure GetBotMove(id: integer; var row, col: integer);
begin
  row := StrToInt(players[id].Reader.ReadLine());
  col := StrToInt(players[id].Reader.ReadLine());
end;

procedure InitGame();
begin
  FigTurn := 1;
  Setlength(board,N);
  for var i := 0 to N - 1 do
    begin
      SetLength(board[i],N);
      for var j := 0 to N - 1 do
        board[i, j] := 0;
    end;
end;

procedure DrawField();
begin
  Writeln();
  for var i := 0 to N - 1 do
  begin
    for var j := 0 to N - 1 do
      Write(board[i, j], ' ');
    Writeln();
  end;
end;



procedure GameLoop();
begin
  while true do
  begin
    var row, col: integer;

    SendState(1, 'state'); // отправляем поле первому боту
    SendState(2, 'state'); // и второму
    
    GetBotMove(FigTurn, row, col); // ждем ход текущего бота

    if not ApplyMove(row,col) then 
    begin
      SendState(1, 'error');
      SendState(2, 'error');
      exit;
    end;


    if CheckWin(col,row,FigTurn,WinCount) then
    begin
      SendState(1, 'game_over');
      SendState(2, 'game_over');
      exit;
    end;

    if CheckDraw() then
    begin
      SendState(1, 'draw');
      SendState(2, 'draw');
      exit;
    end;

    SwitchTurn(); 
  end;
end;

begin
  InitGame;
  StartServer;
  GameLoop;
end.