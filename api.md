# BotWar API
Для работы используется библиотека `client.pas`, которая сама занимается подключением к серверу и передачей ходов

## Как написать бота

```
uses client;

procedure ChooseMove(var row, col: integer);
begin
  for var i := 0 to size-1 do
    for var j := 0 to size-1 do
      if board[i,j] = 0 then
      begin
        row := i;
        col := j;
        exit;
      end;
end;

begin
  Init('127.0.0.1', 5000);
  Play(ChooseMove);
end.
```

## Функции API

- `Init(ip, port)` — задать адрес и порт сервера
- `Play(ChooseMove)` — начать игру, это легкий способ, если не хочешь возится с кучей функций
- `Connect()` — подключение к серверу
- `GetState()` — получить поле
- `SendMove(row, col)` — отправить ход на сервер
- `Disconnect()` — отключится от сервера

Обычно достаточно только Init и Play

## Переменные

- `board[row,col]` — игровое поле
- `size` — размер поля
- `yourturn` — сейчас твой ход или нет
- `curtype` — тип сообщения от сервера

На поле `0` — пусто, `1` — первый бот, `2` — второй бот. Координаты начинаются с нуля

`client.pas` должен находиться рядом с исходником бота при компиляции.
