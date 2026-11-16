// BotWar v2 - сервер
//==================================USES==================================
uses System, System.IO, System.Net, System.Net.Sockets, System.Diagnostics;
//==================================CONSTS================================
const
  GameCount = 4;
  VPort = 5001; // НЕДОДЕЛАНО, порт зрителя
  TurnTimeoutMs = 2000;
//==================================TYPES=================================
type
  Tplayer = class
    Client: TcpClient;
    Reader: StreamReader;
    Writer: StreamWriter;
    Name: string;
    Wins,Draws,Looses,Points: integer;
  end;
//==================================VARS==================================
var
  N : integer = 10;
  wincount : integer = 5;
  board: array[,] of integer;
  FigTurn, BotCount: integer;
  Players: array of Tplayer;
  listener: TCPlistener;
  Wins1, Wins2, Draws: integer;
  TournamentStarted: boolean;
  ActivePlayers: array[1..2] of integer;
//===============================FUNCTIONS================================
procedure StartServer();
begin
  listener := new TcpListener(IPAddress.Loopback, 6767);
  listener.Start;
  Writeln('ждем игркоов...');
  while not tournamentStarted do
  begin
    if listener.Pending() then
    begin
      BotCount+=1;
      SetLength(Players, BotCount+1);
      players[BotCount] := new Tplayer;
      players[BotCount].client := listener.AcceptTcpClient();
      
      var net := players[BotCount].Client.GetStream;
      players[BotCount].reader := new streamreader(net);
      players[BotCount].writer := new streamwriter(net);
      
      Players[BotCount].name := Players[BotCount].reader.ReadLine();
      Writeln(Players[BotCount].name, ' подключён!');
    end;
    if Console.KeyAvailable then // обработчик ошибок по сути
    begin
      var key := Console.ReadKey(true); //читаем клавишу в консоли, при том true- обозначает что клавишу не надо отображать

      if (key.Key = ConsoleKey.Enter) and (BotCount >= 2) then
        TournamentStarted := true;
    end;
    sleep(50);
  end;
end;
procedure SendState(id: integer;curtype: string);
begin
  var writer := players[id].Writer;
  writer.writeline(curtype);
  if ActivePlayers[FigTurn] = id then writer.writeline(True)
  else writer.writeline(False);
  writer.WriteLine(N);
  writer.WriteLine(Wincount);
  if id = ActivePlayers[1] then writer.WriteLine(1)
  else if id = ActivePlayers[2] then writer.WriteLine(2)
  else writer.WriteLine(0);
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
  board := new integer[N,N];
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



function GameLoop(): integer;
begin
  while true do
  begin
    var row, col: integer;

    SendState(ActivePlayers[1], 'state'); // отправляем поле первому боту
    SendState(ActivePlayers[2], 'state'); // и второму
    
    GetBotMove(ActivePlayers[FigTurn], row, col); // ждем ход текущего бота

    if not ApplyMove(row,col) then 
    begin
      SendState(ActivePlayers[1], 'error');
      SendState(ActivePlayers[2], 'error');
      result := -1;
      exit;
    end;


    if CheckWin(col,row,FigTurn,WinCount) then
    begin
      SendState(ActivePlayers[1], 'game_over');
      SendState(ActivePlayers[2], 'game_over');
      result := FigTurn;
      exit;
    end;

    if CheckDraw() then
    begin
      SendState(ActivePlayers[1], 'draw');
      SendState(ActivePlayers[2], 'draw');
      result := 0;
      exit;
    end;

    SwitchTurn(); 
  end;
end;
//==================================MAIN==================================
begin
  StartServer();
  for var i := 1 to BotCount - 1 do
    for var j := i + 1 to BotCount do
    begin
      ActivePlayers[1] := i;
      ActivePlayers[2] := j;
      Wins1 := 0;
      Wins2 := 0;
      Draws := 0;
      for var game := 1 to GameCount do
      begin
        InitGame();
        if game mod 2 = 0 then FigTurn := 2;
        var winner := GameLoop();
        // Победа - 3, Поражение - 0, Нчиья - 1
        if winner = -1 then
        begin
          Writeln('Ошибка. Завершение работы...');
          Exit;
        end;
        if winner = 0 then
        begin
          Players[i].Draws += 1;
          Players[j].Draws += 1;
          Players[i].Points += 1;
          Players[j].Points += 1;
          Draws += 1;
        end
        else
        begin
          var winnerId := ActivePlayers[winner];
          var loserId := ActivePlayers[3 - winner];
          Players[winnerId].Wins += 1;
          Players[winnerId].Points += 3;
          Players[loserId].Looses += 1;
          if winner = 1 then
            Wins1 += 1
          else
            Wins2 += 1;
        end;
        Writeln(Players[i].Name, ' vs ', Players[j].Name);
        Writeln('Победы: ', Wins1, ' : ', Wins2);
        Writeln('Ничьих: ', Draws);
      end;
      
    end;
    //===============================================
  var order := Range(1, BotCount) //возвращает последовательность с 1 по botcount вклбчительно все
  .OrderByDescending(i -> Players[i].Points) // сортирует по убыванию (в скобках указывается лямбда-выражение(->), это скоращенная функция, то есть она по сути говорит что сравнивай по points
  .ThenByDescending(i -> Players[i].Wins).ToArray; //если одинаково по первой сортировке, то сорттируем по wins  и toarray делает из последовательности массивчик
  for var i := 0 to order.Length-1 do
  begin
    var p := Players[order[i]];
    Writeln(i+1, ' место: ', p.name);
    Writeln('Очки: ', p.Points);
    Writeln('Победы: ', p.Wins);
    Writeln('Ничьи: ', p.Draws);
    Writeln('Поражения: ', p.Looses);
    Writeln();
  end;
  //==================================
  for var i := 1 to BotCount do SendState(i, 'tournament_over');

  Writeln();
end.