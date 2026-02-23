# Rise of the Dead - Alpha Release

A top-down 2D pixel art game built in Godot 4.5.

## 🎮 Features Implemented
* **Player Controller:** Smooth movement using `CharacterBody2D` with normalization for diagonal speed.
* **Animation System:** * State machine for **Idle** vs **Run**.
    * Automatic sprite flipping (horizontally) based on input direction.
    * Separate animations for Up, Down, and Side.
* **Level Design:** * Implemented `TileMapLayer` for ground rendering.
    * Added collision obstacles (walls/holes).
* **Camera:** `Camera2D` with zoom enabled for pixel-art focus.

## 📺 Gameplay Demo
**[CLICK HERE TO WATCH THE GAMEPLAY VIDEO]([https://youtu.be/IHB8OdM91bM](https://youtu.be/0anqL4f9uRs))**

## 📸 Screenshots
*(Drag and drop your gameplay screenshots here on GitHub, or link them)*
![Gameplay Screenshot]
<img width="1159" height="657" alt="image" src="https://github.com/user-attachments/assets/a87b861c-57d0-4280-8fab-6334f1522833" />

## 🤖 AI Usage Declaration
In compliance with assignment requirements, the following AI tools were used to assist in development:

* **AI Assistant:** Google Gemini
* **Usage:** * **Debugging:** Assisted in resolving "null instance" crash errors related to node naming (`Sprite2D` vs `AnimatedSprite2D`).
* **Example Prompts Used:**
    * *"How to fix blurry pixel art in Godot 4?"*
    * *"Why does my character freeze when I press keys?"*
