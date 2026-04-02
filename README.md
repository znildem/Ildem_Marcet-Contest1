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

Project Title: Dino Game (Assembly)

Authors:
- Neva Ildem
- Marcet

Description:
This project implements a side-scrolling dinosaur game in x86 assembly using the Irvine32 library. The player controls a dinosaur that must jump over obstacles (cactus) while the game tracks score and increases difficulty over time.

Features:
- Keyboard input using GetAsyncKeyState
- Gravity and jump physics
- Moving obstacles (cactus)
- Collision detection
- Score tracking
- Timer-based game loop for consistent speed

How to Compile:
1. Open the project in Visual Studio with MASM configured
2. Ensure Irvine32 library is properly linked
3. Build the solution (Ctrl + Shift + B)

How to Run:
- Run the generated executable
- Press SPACE or UP ARROW to jump

Notes:
- This project uses GetAsyncKeyState for keyboard input, which was not taught in class.
  We learned how to use it from Microsoft documentation:
  https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getasynckeystate

- This project also uses timer-based logic to control the game loop and movement speed.
  Timer usage was not taught in class.
  We learned how to implement timing through external documentation and by adapting examples.

- Timer logic is used to ensure consistent gameplay speed independent of CPU performance.

- All features were implemented by understanding and applying external documentation.
