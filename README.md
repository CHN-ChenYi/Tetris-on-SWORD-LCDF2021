# Tetris-on-SWORD
Tetris in Verilog -- a course project for Logic and Computer Design Fundamentals Course at ZJU.

## Interface

### scoreCount

```verilog
scoreCount sC1(.clk(clk),.rst(rst),hit(hit),.lineCount(lineCount),.SEGCLK(SEGCLK),.(SEGCLR),.SEGDT(SEGDT),.SEGEN(SEGEN));
```

+ `rst` reset button, 1 for reset
+ `clk` clock
+ **`hit`  1 for user have at least 1 line cleared**
+ **`lineCount`** 
  + **00 for clear 1 line**
  + **01 for clear 2 lines**
  + **10 for clear 3 lines**
  + **11 for clear 4 lines**
+ `SEGCLK` `SEGCLR` `SEGDT` `SEGEN` for display

## keyboard

