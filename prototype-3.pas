// prototype-3
uses GraphABC, System, System.IO, System.Net, System.Net.Sockets;

const 
  fieldsize = 600; // размер поля в пкс
  ncells = 10; //размер поля в клетках поле ncells*ncells  *не больше 100*
  wincount = 5; //сколько в ряд для победы

var 
  cellsize: integer;
  board: array[0..ncells-1] of array[0..ncells-1] of integer; //0 - пусто 1 - ноль, игрок 2 - крест, бот
  gameover: boolean := false;

function CheckWin(col, row, fig, win: integer): boolean; //функция проверки победы. вход - столбец, строчка, фигура(1,2) и сколько клеток для победы
var 
  count: integer; 
begin
  Result := false;
  
  count := 0;
  //смотрим на каждое направление и если есть 5 подряд выходим и возращаем true
  for var i := 0 to ncells - 1 do 
  begin
    if board[i][col] = fig then
    begin
      count += 1;
      if count >= win then begin Result := true; exit; end;
    end
    else
      count := 0;
  end;

  count := 0;
  for var i := 0 to ncells - 1 do
  begin
    if board[row, i] = fig then
    begin
      count += 1;
      if count >= win then begin Result := true; exit; end;
    end
    else
      count := 0;
  end;

  count := 0;
  for var i := -ncells to ncells do
  begin
    var r := row + i;
    var c := col + i;
    if (r >= 0) and (r < ncells) and (c >= 0) and (c < ncells) then
    begin
      if board[r, c] = fig then
      begin
        count += 1;
        if count >= win then begin Result := true; exit; end;
      end
      else
        count := 0;
    end;
  end;

  count := 0;
  for var i := -ncells to ncells do
  begin
    var r := row + i;
    var c := col - i;
    if (r >= 0) and (r < ncells) and (c >= 0) and (c < ncells) then
    begin
      if board[r, c] = fig then
      begin
        count += 1;
        if count >= win then begin Result := true; exit; end;
      end
      else
        count := 0;
    end;
  end;
end;

procedure DrawZero(cx, cy: integer);
begin
  pen.Width := 5;
  pen.Color := color.Blue;
  DrawCircle(cx, cy, round(cellsize * 0.8 / 2));
end;

procedure DrawCross(cx, cy: integer);
begin
  pen.Width := 5;
  pen.Color := color.Red;
  var l := round(cellsize * 0.8 / 2);
  Line(cx - l, cy - l, cx + l, cy + l);
  Line(cx + l, cy - l, cx - l, cy + l);
end;

//обмен данными с ботиком
procedure ExchangeWithBot();
begin
  // создаём tcp сервер на порте 5000
  var listener := new TcpListener(IPAddress.Loopback, 5000);
  listener.Start;
  try
    Exec('bot3-2.exe');
    // ждём подключения бота
    var client := listener.AcceptTcpClient;
    try
      // получаем поток данных
      var net := client.GetStream;
      // обёртки для удобной работы с текстом
      var writer := new StreamWriter(net);
      var reader := new StreamReader(net);
      // отправляем параметры игры
      writer.WriteLine(ncells);
      writer.WriteLine(wincount);
      // отправляем поле
      for var i := 0 to ncells - 1 do
        for var j := 0 to ncells - 1 do
          writer.WriteLine(board[i, j]);
      //сбрасываем буфер
      writer.Flush;
      // получаем ответ
      var botR := StrToInt(reader.ReadLine());
      var botC := StrToInt(reader.ReadLine());
      // применяем ход
      board[botR, botC] := 2;
      DrawCross(botC * cellsize + cellsize div 2, botR * cellsize + cellsize div 2);
      if CheckWin(botC, BotR, 2, wincount) then 
        begin
          gameover := true;
          Window.Title := 'Игра окончена: Победили Крестики';
          exit;
        end;
      gameover := true;
      for var i:= 0 to ncells-1 do
        if board[i].contains(0) then 
          begin
            gameover := false;
            break;
          end;
      if gameover then 
        begin
          Window.Title := 'Игра окончена: Ничья';
          exit;
        end;
    finally
      client.Close;
    end;
  finally
    listener.Stop;
  end;
end;

procedure Click(x, y, btn: integer); //обработка нажатия
begin
  if gameover or (btn <> 1) then exit;

  var col := x div cellsize;
  var row := y div cellsize;

  if (col < 0) or (col >= ncells) or (row < 0) or (row >= ncells) then exit; //проверка выхода клика за границы
  if board[row, col] <> 0 then exit; //проверка на пустую клетку
  
  var cx := col * cellsize + cellsize div 2;
  var cy := row * cellsize + cellsize div 2;
  
  board[row, col] := 1;
  DrawZero(cx, cy);
  
  if CheckWin(col, row, 1, wincount) then 
    begin
      gameover := true;
      Window.Title := 'Игра окончена: Победили Нолики';
      exit;
    end;
  gameover := true;
  for var i:= 0 to ncells-1 do
    if board[i].contains(0) then 
      begin
        gameover := false;
        break;
      end;
  if gameover then 
    begin
      Window.Title := 'Игра окончена: Ничья';
      exit;
    end;
  ExchangeWithBot;
end;

procedure DrawField();
begin
  pen.Width := 2;
  pen.Color := color.Black;
  for var i := 1 to ncells - 1 do
  begin
    Line(0, cellsize * i, fieldsize, cellsize * i);
    Line(cellsize * i, 0, cellsize * i, fieldsize);
  end;
end;

procedure InitGame();
begin
  cellsize := fieldsize div ncells;
  Window.Title := 'Prototype-3';
  Window.SetSize(fieldsize, fieldsize);
  Window.IsFixedSize := true;
  ClearWindow;
  
  for var i := 0 to ncells - 1 do
    for var j := 0 to ncells - 1 do
      board[i, j] := 0;
  
  DrawField();
end;

begin
  InitGame;
  OnMouseDown := Click;
end.