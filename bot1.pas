uses client;

const
fig = 1;
fig1 = 2;

function CountLine(r, c, dr, dc, fig: integer): integer; //подсчет фигур в ряд начиная с клетки r c  сторону заданную dr dc 
begin
  r += dr;
  c += dc;
  while (r >= 0) and (r < size) and (c >= 0) and (c < size) and (board[r, c] = fig) do
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
procedure ChooseMove(var row, col: integer);
begin
  var board1 := board;
  var bestR := -1; //лучший ход
  var bestC := -1;
  var bestScore := -1;
  for var i := 0 to size - 1 do
    for var j := 0 to size - 1 do
      if board1[i, j] = 0 then
        begin
          board1[i, j] := fig; // условно ставим на каждую клетку крестик(бот) и смотрим насколько хорошо
    
          var score := MaxLine(i, j, fig);
          board1[i, j] := 0;

          if score > bestScore then //ищем самое лучший ( дополнение самой большой последовательности)
            begin
              bestScore := score;
              bestR := i;
              bestC := j;
            end;
        end;
  //делаем тоже самое для ноликов, только теперь смотрим насколько большую можем перекрыть
  for var i := 0 to size - 1 do
    for var j := 0 to size - 1 do
      if board1[i, j] = 0 then
        begin
          board1[i, j] := fig1;
          var score := MaxLine(i, j, fig1);
          board1[i, j] := 0;

          if score > bestScore then //ищем самое лучшее перекрытие(самой большой последовательности)
            begin
              bestScore := score;
              bestR := i;
              bestC := j;
            end;
        end;
  row := BestR;
  col := BestC;
end;

begin
  Init('127.0.0.1',6767);
  Play(ChooseMove);
  
end.