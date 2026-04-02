Project Title: Dino Game (Assembly)

Authors:
- Neva Ildem
- Pedro Marcet

Description:
This project implements a simple side-scrolling game in x86 assembly using the Irvine32 library. The player controls a dinosaur that must jump over obstacles (cactus) to survive and score points.

Features:
- Keyboard input using GetAsyncKeyState
- Gravity and jump physics
- Moving obstacles
- Score tracking
- Collision detection

How to Compile:
1. Open the project in Visual Studio (MASM setup required)
2. Ensure Irvine32 is properly linked
3. Build the solution

OR (if using command line):
ml /c /coff main.asm
link /SUBSYSTEM:CONSOLE main.obj Irvine32.lib

How to Run:
- Run the generated .exe file
- Press SPACE to jump

Notes:
- This project uses GetAsyncKeyState which was not fully covered in class.
- We learned it from Microsoft documentation:
  https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getasynckeystate
