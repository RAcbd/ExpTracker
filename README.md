# QQT ExpTracker

**Author:** Raff
**Version** v0.1 (first release - self tested)

A lightweight, real-time experience tracker script for Diablo IV, built specifically for the QQT Framework. This script provides a floating 3D overlay that tracks session progress, remaining experience for the next level, and an estimated time to level up.

## Features
- Real-Time EXP Tracking: Automatically calculates experience gained since the script was loaded.
- Next Level Requirements: Displays exactly how much experience is needed for your next level.
- ETA Calculation: Smart estimation of time remaining until level-up based on your current session pace.
- 3D World Overlay: Renders directly in the game world near your character for high visibility without UI clutter.
- Auto-Enable: Configured to start tracking immediately upon injection.
- Crash-Safe: Implements protected calls (pcall) to ensure stability during gameplay.

## Installation

1. Navigate to your Diablo IV QQT scripts folder.
2. Create a new directory named ExpTracker.
3. Save the script as main.lua inside that folder.
4. Reload your scripts in-game.