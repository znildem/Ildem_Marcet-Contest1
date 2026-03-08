; Dino game data

INCLUDE Irvine32.inc

.data
PUBLIC dinoY
PUBLIC dinoVy
PUBLIC cactusX
PUBLIC dinoScore
PUBLIC dinoGameOver

; Dino vertical position
; 0 = on ground
; positive value = above ground
dinoY SDWORD 0

; Dino vertical velocity
dinoVy SDWORD 0

; Cactus horizontal position inside the left panel
cactusX SDWORD 30

; Score for number of obstacles passed
dinoScore DWORD 0

; 0 = still playing
; 1 = collision / game over
dinoGameOver BYTE 0

END