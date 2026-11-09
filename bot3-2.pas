{$apptype windows}
uses System, System.IO, System.Net.Sockets, System.Net;

var
  ncells, wincount: integer;
  board: array[0..99, 0..99] of integer;
  
function CountLine(r, c, dr, dc, fig: integer): integer; //подсчет фигур в ряд начиная с клетки r c  сторону заданную dr dc 
begin
  r += dr;
  c += dc;
  while (r >= 0) and (r < ncells) and (c >= 0) and (c < ncells) and (board[r, c] = fig) do
    begin
      Result += 1;
      r += dr;
      c += dc;
    end;
end;

function MaxLine(r, c, fig: integer): integer; //ищем максимум клеток в ряд по любому направлению в клетке r c 
begin
  Result := 1;
  Result := Max(Result,1 + CountLine(r, c, 0, 1, fig) + CountLine(r, c, 0, -1, fig)); //ищем в каком направлении больше всего в ряд и возращаем абсолютный максимум
  Result := Max(Result,1 + CountLine(r, c, 1, 0, fig) + CountLine(r, c, -1, 0, fig));
  Result := Max(Result,1 + CountLine(r, c, 1, 1, fig) + CountLine(r, c, -1, -1, fig));
  Result := Max(Result,1 + CountLine(r, c, 1, -1, fig) + CountLine(r, c, -1, 1, fig));
end;

begin
  // Подключаемся к серверу игры, уже ожидающему на порту 5000.
  var client := new TcpClient();
  client.Connect(IPAddress.Loopback, 5000);
  try
    var net := client.GetStream();
    var reader := new StreamReader(net);
    var writer := new StreamWriter(net);

    ncells := StrToInt(reader.ReadLine());
    wincount := StrToInt(reader.ReadLine());
    for var i := 0 to ncells - 1 do
      for var j := 0 to ncells - 1 do
        board[i, j] := StrToInt(reader.ReadLine());

  // ищем лучший ход
  var bestR := -1; //лучший ход
  var bestC := -1;
  var bestScore := -1;
  for var i := 0 to ncells - 1 do
    for var j := 0 to ncells - 1 do
      if board[i, j] = 0 then
        begin
          board[i, j] := 2; // условно ставим на каждую клетку крестик(бот) и смотрим насколько хорошо
    
          var score := MaxLine(i, j, 2);
          board[i, j] := 0;

          if score > bestScore then //ищем самое лучший ( дополнение самой большой последовательности)
            begin
              bestScore := score;
              bestR := i;
              bestC := j;
            end;
        end;
  //делаем тоже самое для ноликов, только теперь смотрим насколько большую можем перекрыть
  for var i := 0 to ncells - 1 do
    for var j := 0 to ncells - 1 do
      if board[i, j] = 0 then
        begin
          board[i, j] := 1;
          var score := MaxLine(i, j, 1);
          board[i, j] := 0;

          if score > bestScore then //ищем самое лучшее перекрытие(самой большой последовательности)
            begin
              bestScore := score;
              bestR := i;
              bestC := j;
            end;
        end;

    // Возвращаем координаты через то же TCP-соединение.
    writer.WriteLine(bestR);
    writer.WriteLine(bestC);
    writer.Flush();
  finally
    client.Close();
  end;
end.