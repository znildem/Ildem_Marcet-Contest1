Project Title: Average Silaghi Class (Assembly)

Authors:
Neva Ildem
Pedro Marcet

Description:
This project implements a side-scrolling dinosaur game in x86 assembly using the Irvine32 library. The player controls a dinosaur that must avoid obstacles such as cacti and birds while the game increases in difficulty over time.

Features:
- Keyboard input using GetAsyncKeyState
- Jumping and ducking mechanics
- Gravity-based movement physics
- Animated dinosaur (running and ducking)
- Multiple obstacle types (small cactus, large cactus, flying birds)
- Increasing difficulty (speed, spawn distance, bird frequency)
- Score tracking
- Collision detection (with tuned hitboxes)
- Animated countdown (3, 2, 1, GO)
- Timer-controlled gameplay sections

Controls:
- SPACE / UP ARROW → Jump
- DOWN ARROW → Duck

How to Compile:
Option 1 (Visual Studio):
- Open the project in Visual Studio (MASM configured)
- Ensure Irvine32 is properly linked
- Build the solution (Ctrl + Shift + B)

Option 2 (Command Line):
ml /c /coff main.asm
link /SUBSYSTEM:CONSOLE main.obj Irvine32.lib

How to Run:
- Run the generated executable
- Follow on-screen instructions

Notes:
- GetAsyncKeyState was used for real-time keyboard input (not covered in class)
  Documentation: https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getasynckeystate

- Timer-based logic was implemented to maintain consistent gameplay speed and control timed sections of the game.

- All additional features were developed by referencing external documentation and adapting concepts to assembly.
