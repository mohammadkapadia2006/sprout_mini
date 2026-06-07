# 🫧 Sprout Mini — Pop the Bubbles!

A fun, interactive single-screen Flutter app built for children aged 3–5 years old.  
Created as part of the **Sprout Early Stage Startup** mobile developer evaluation (Task 2).

---

## 📱 About the App

**Pop the Bubbles!** is a child-friendly tap interaction game where colorful bubbles float across a sky-blue screen. The child taps each bubble to pop it — every tap plays a satisfying pop sound and animation. When all bubbles are popped, confetti explodes and Milo the character celebrates with a full-volume cheer!

The app is designed around one core principle: **every tap must do something fun, instantly.**

---

## ✨ Features

- 🫧 10 colorful bubbles spawned randomly every round
- 👆 Tap any bubble → scale-up animation + pop sound
- 🎵 Background cheer music plays softly during gameplay
- 🏆 All bubbles popped → confetti explosion + volume goes full
- 🎉 Milo celebration card with "Play Again" button
- 🔄 Replay instantly — fresh bubbles every round
- ☁️ Animated cloud decorations in background
- 📊 Live counter showing bubbles popped (e.g. 3 / 10)

---

## 🛠️ Built With

| Technology | Purpose |
|---|---|
| Flutter | UI framework |
| Dart | Programming language |
| audioplayers ^6.0.0 | Pop sound + background cheer music |
| confetti ^0.7.0 | Celebration confetti animation |

---



## 🎮 How to Play

1. Open the app — colorful bubbles appear on screen
2. Tap any bubble to pop it — hear the pop sound!
3. Keep popping until all 10 bubbles are gone
4. 🎉 Confetti explodes and Milo celebrates!
5. Tap **Play Again** for a fresh round

---

## 🎨 Design Decisions

**Why bubble popping?**  
Children aged 3–5 are drawn to immediate cause-and-effect interactions. Tapping a bubble and seeing it pop with a sound is deeply satisfying and requires zero instruction — the child understands instantly.

**Why No Instructions Screen?**
Any text-based instruction screen is invisible to a 3-year-old. If the first thing a child sees is "Tap the bubbles to pop them!" — they have already lost interest. Instead, the app opens directly into the game. The interaction is self-explanatory through visuals alone. This follows the golden rule of children's UX: show, don't tell.

**Why Background Music at Low Volume During Gameplay?**
Silence during gameplay feels empty and cold for young children. A soft background track creates a warm, playful atmosphere that signals "this is a fun place." The volume is kept at 0.15 (15%) so it never competes with the pop sounds. This is the same technique used in most successful children's apps — ambient audio makes the experience feel alive.

**Why Raise Volume on Win Instead of Playing a New Sound?**
When the child wins, the background music volume jumps from 0.15 to 1.0 (full). The same song that was playing softly in the background suddenly becomes a celebration. This creates a powerful emotional contrast — the child feels the moment of victory through sound without any delay or gap. No new file to load, no risk of audio lag, just an instant emotional punch.

---

## 📸 Demo

> 🎥 [Watch Demo Video](https://drive.google.com/drive/folders/1ts_C2jEUhWeiYRKFZXBkQPmaCat1lhoc?usp=drive_link)

---

## 👨‍💻 Author

**Mohammad Kapadia** 
mohammadkapadia174@gmail.com

---
