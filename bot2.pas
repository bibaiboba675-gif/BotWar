uses client;

procedure ChooseMove(var row, col: integer);
begin
  for var i := 0 to size-1 do
    for var j := 0 to size-1 do
      if board[i,j] = 0 then
      begin
        row := i;
        col := j;
      end;
end;

begin
  Init('127.0.0.1',6767);
  Play(ChooseMove);
end.