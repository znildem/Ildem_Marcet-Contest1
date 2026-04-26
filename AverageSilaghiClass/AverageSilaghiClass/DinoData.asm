; Dino game data

INCLUDE Irvine32.inc

.data
PUBLIC dinoY
PUBLIC dinoVy
PUBLIC cactusX
PUBLIC dinoScore
PUBLIC dinoGameOver
PUBLIC cactusType 
PUBLIC cactusHeight
PUBLIC cactusSpeed
PUBLIC birdFrame
PUBLIC dinoDuck

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

; 0 = small cactus, 1 = large cactus, 2 = flying enemy
cactusType BYTE 0

; vertical offset (0 = ground, 1-2 = higher)
cactusHeight BYTE 0

; cactus movement speed
cactusSpeed SDWORD 1

birdFrame BYTE 0

; 0 = normal, 1 = ducking
dinoDuck BYTE 0

END