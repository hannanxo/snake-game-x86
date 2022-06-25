# snake-game-x86
  Structure of the snake:
  - Snake is an array of 240 indices.
  - Each index consists of 2 bytes.
  - MSB represents the background colour and the LSB prints the value (null / space).
  - Head is the first index which will have a background colour of red while the rest of the body will be blue.

  Variables:
  - snake, an array of 240.
  - maxlen, is the maximum length of the snake which is 240.
  - len, the current length of the snake.
  - flag, used for movement of the snake.
  - oldkb and oldtimer, used to store the original interrupts.
  - lives, stores the number of lives the player has.
  - tickcount, used to increase the speed of the snake.
  - maincount, used to calculate the time and fruit location.
  - speed, is the speed of the snake, maximum being 15.
  - minutes & seconds are used to display the time.
  - level, is the current level or stage of the game.
  - score, is the score of the player.
  - bigFood, checks if the game should display a big or small fruit.
  - finishGame, a boolean variable to check if the game has ended.
  - finishMessage, the display message after you beat the game.

  Interrupts:
  - Initialize interrupts for the timer and key presses in the main function of the code.

  Clrscr:
  - The subroutine clears the screen.

  Printsnake:
  - The subroutine is responsible for printing the snake.
  - It styles the MSB of every index to have a background colour and LSB to have an ASCII value of space / null.
  - It gives a background colour of red to the first index / head.
  - It loops through the remaining indices to the current length of the snake to give them a background colour of blue.
  - It is also responsible for displaying the lives on the screen.

  Movesnake:
  - This subroutine is responsible for moving the snake.
  - It checks the value of the flag that ranges from 0 to 3.
  - If the flag is 0, 1, 2 or 3, it subtracts 2, adds 2, subtracts 160, adds 160 to the snake respectively.
  - In case the next location of the snake is not empty, call the collider to check if it’s a fruit or a dead end.

  PrintNum:
  - This subroutine is responsible for converting an integer into separate characters and printing them to the screen at their destined location.
  - It takes two values as parameters, the location at which the number (score, lives etc) is to be printed and its value.

  PrintBorder:
  - Each row of the screen consists of 80 pixels, where every pixel is 2 bytes.
  - This subroutine is responsible for printing purple coloured border on the screen.
  - Having 3 loops, the first is to print the top, second prints the bottom, while the third prints the left and right border.
  - In case of level 2, it also prints the borders placed at the center of the screen.
  
  GenerateRandom:
  - The console consists of 2000 pixels which is 4000 bytes.
  - This subroutine divides the maincount by 2000 to get a random value and prints the fruit at that random location on the screen.
  - In case the random location is not empty, it loops through all the adjacent locations until it finds an empty location.
  - If the value of bigFood is less than two, it prints the small fruit, else it prints the big fruit.
  
  ResetGame:
  - This subroutine resets everything to default.
  - It prints the snake of length 20 in the center of the screen by giving it the location “1980”, which represents the center of the screen in bytes.
 
  Timer:
  - This subroutine is responsible for calculating the main time and increasing the speed of the snake.
  - In assembly 8086 there are 18.2 clock ticks in one second.
  - It calculates the main time by dividing the maincount by 91 (5 seconds) and when the remainder becomes zero, it re-displays the time.
  - If the speed is not equal to maximum speed, it reduces the delay time and checks if the tickcount is equal to the delay time. If it’s then move the snake.
  
  Playsound:
  - This subroutine is responsible for playing different kinds of sounds during the game.
  
  Kbisr:
  - This subroutine checks for the interrupts that are passed due to a key press.
  - It compares the key press with up, down, left and right and sets
  the movement flag accordingly.
  
  Collider:
  - This subroutine checks if the next location of the snake is small fruit, big fruit or a collider.
  - In case of fruit, it increases the score accordingly.
  - If it’s not a fruit and is a border / snake body it resets the game and decrements a life.

