# Rise of the Dead - Final Release (v1.0.0)

A top-down 2D pixel art post-apocalyptic survival game built in Godot 4.5.1. 

## 📥 Installation & Run Instructions
1. Navigate to the **Releases** section on the right side of this repository.
2. Download the `ProjectZero_v1.zip` file from the Latest Release.
3. Extract/Unzip the folder to your computer.
4. Double-click the `Rise_Of_The_Dead.exe` file to launch the game!
**Controls:**
* **W, A, S, D** - Move Varaman
* **Spacebar / Left Mouse Click** - Punch / Attack
* **E** - Interact with doors and text prompts

## 🎮 Features Implemented
* **Dynamic Kill Quota System:** A global tracker that monitors player kills (Normal and Big zombies) to unlock final areas, ensuring active combat engagement.
* **Smart UI Interactions:** Doors feature dynamic proximity text that updates in real-time to show progression (e.g., "Kills needed: 15 Normal / 5 Big").
* **Two-Phase Boss Encounter:** A climactic final battle on the Helipad featuring a phase-1 Axe Zombie, a phase-2 mutant transformation, and a dynamic backup-wave spawner.
* **Player Controller & Animation:** State machine handling Idle/Run, automated sprite flipping based on input direction, and 4-way movement animations.
* **Level Design & Safe Rooms:** Implemented `TileMapLayer` for ground and collisions, featuring a connected world map and safe-room interiors packed with medical supplies.

## 🛠️ Beta-Testing Bug Fixes & Optimization
* **Optimization & File Size:** Achieved a highly optimized **41MB** zipped build size. This was done by completely overhauling the combat system, stripping out heavy unused firearm animations/assets, excluding unnecessary editor files from the export template, and converting all audio tracks to lightweight `.mp3` format.
* **Level Transition Fix:** Resolved a critical beta-testing bug where exiting the interior shop scene incorrectly spawned the player at the original apartment start point. Engineered a Global coordinate tracker to seamlessly warp the player to the exact exterior storefront entrance.

## 📺 Final Gameplay Demo
**[CLICK HERE TO WATCH THE FINAL GAMEPLAY & BOSS FIGHT VIDEO]((https://youtu.be/H7iFcaxUiCQ))**

## 📸 Screenshots
*(Drag and drop your gameplay screenshots here on GitHub, or link them)*
![Gameplay Screenshot]
<img width="1159" height="657" alt="image" src="https://github.com/user-attachments/assets/a87b861c-57d0-4280-8fab-6334f1522833" />

## 🎨 Asset Credits
* **Art & Sprites:** "PostApocalypse Asset Pack v1.1.2" (downloaded via Itch.io)
* **Ambient Music:** "The Fog of War" by Tim Kulig (downloaded via Pixabay)
* **Boss Music:** "Dark Cinematic Electro Trailer (Dark Engine)" by Alex Kizenkov (downloaded via Pixabay)
* **Game Engine:** Built using Godot Engine 4.5.1

## 🤖 AI Usage Declaration
In compliance with assignment requirements, the following AI tools were used to assist in development:

* **AI Assistant:** Google Gemini
* **What was generated/assisted with:** * **Debugging:** Assisted in resolving "null instance" crash errors related to node naming (`Sprite2D` vs `AnimatedSprite2D`).
    * **Logic Structuring:** Assisted in building the `Global.gd` autoload script for tracking cross-scene variables (kill quotas and spawn coordinates).
    * **Systems:** Helped write the wave spawner logic and phase-transition triggers for the final Helipad boss fight.
* **Example Prompts Used:**
    * *"How to fix blurry pixel art in Godot 4?"*
    * *"Why does my character freeze when I press keys?"*
    * *"How do I make a global tracker in Godot to remember how many zombies I killed after changing scenes?"*
    * *"How to make text appear above a door only when the player walks close to it?"*
