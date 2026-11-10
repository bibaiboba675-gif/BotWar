
uses client;

procedure ChooseMove(var row, col: integer);
begin
  repeat
    row := Random(size);
    col := Random(size);
  until board[row,col] = 0;
end;

begin
  Randomize();
  Init('127.0.0.1', 6767,'skebob');
  Play(ChooseMove);
end.