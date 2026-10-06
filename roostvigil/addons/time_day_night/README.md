# Godot Time, Day/Night & Season System

A simple, lightweight **Time, Day/Night, and Season System for Godot** that lets you control the in-game clock, date, seasons, lighting, shadows, and color changes throughout the day.

The system is designed to be **lightweight, modular, and easy to integrate** into existing Godot projects.

This system uses the [2D Shadows Demo for Godot](https://github.com/jess-hammer/2d-shadows-demo-godot) for shadow casting.

---

## Features

* 🕐 **AM/PM Clock System**
* 📅 **Date System**
* 🌱 **Four Seasons**
* 📆 **30 Days Per Season**
* 🌅 **Day/Night Cycle**
* 🌄 **Custom Sunrise Time**
* 🌇 **Custom Sunset Time**
* ☀️ **Custom Noon Time**
* 🎨 **Time-Based Color Changes**
* 🍂 **Season-Based Color Changes**
* 💡 **Dynamic Lighting**
* 🌑 **Dynamic Shadow Casting**
* ⏸️ **Pause/Freeze Time**
* 🔌 **Plug-and-Play Integration**
* 🧩 **Modular Design**
* ⚡ **Lightweight and Easy to Use**

---

## Requirements

* **Godot 4.x**
* The included shadow system is based on:

  * [2D Shadows Demo for Godot](https://github.com/jess-hammer/2d-shadows-demo-godot)

---

# Installation

1. Download or clone this repository into your Godot project.

2. Open your project in Godot.

3. Go to:

   **Project → Project Settings → Plugins**

4. Find the **Time Day Night Season System** plugin.

5. Enable the plugin.

Once enabled, the system should automatically load and make the `DayCycle` singleton available globally.

You can access the system from anywhere in your project through:

```gdscript
DayCycle
```

---

# How to Use

The system has two main parts:

* **`DayCycle`** — controls the game's time, date, and seasons.
* **`OutdoorCam/LightControl`** — controls how the world looks based on the current time and season.

This separation allows you to change the appearance of the day/night cycle without having to modify the main time system.

---

# Changing the Day Length

You can control how quickly in-game time passes using:

```gdscript
DayCycle.day_length(
    day_length_in_second: int = 0,
    hour_length_in_second: int = 0,
    minute_length_in_second: int = 0
)
```

You only need to use **one** of the parameters. Leave the other parameters set to `0`.

## Set the Length of a Day

For example, to make one complete in-game day last **120 real-world seconds**:

```gdscript
DayCycle.day_length(120)
```

## Set the Length of an Hour

To make each in-game hour last **10 real-world seconds**:

```gdscript
DayCycle.day_length(0, 10)
```

## Set the Length of a Minute

To make each in-game minute last **1 real-world second**:

```gdscript
DayCycle.day_length(0, 0, 1)
```

> **Note:** Only use one of the three parameters at a time.

---

# Freezing Time

You can freeze the in-game clock whenever you need to stop time from progressing.

This can be useful when the player enters an interior area, opens a menu, or enters a state where you don't want the time of day to change.

To freeze time:

```gdscript
DayCycle.freez = true
```

To allow time to continue:

```gdscript
DayCycle.freez = false
```

## Example

```gdscript
func enter_building():
    DayCycle.freez = true


func leave_building():
    DayCycle.freez = false
```

---

# Lighting, Colors, Sunrise, Sunset & Noon

The visual settings for the day/night cycle are controlled through the **`LightControl`** node inside **`OutdoorCam`**.

To customize the lighting, expand your `OutdoorCam` node in the scene tree:

```text
OutdoorCam
└── LightControl
```

Select **`LightControl`** and use the Godot Inspector to configure the lighting settings.

The `LightControl` node is where you can control things such as:

* 🌅 **Sunrise**
* 🌇 **Sunset**
* ☀️ **Noon**
* 🎨 **Day/night colors**
* 🌙 **Night lighting**
* 🌱 **Season-based colors**
* 💡 **Lighting transitions**

> **Important:** If you want to change the colors, sunrise, sunset, or noon settings, go to the **`LightControl` node inside `OutdoorCam`**.

---

# Adding Day/Night Lighting

To add the lighting and shadow effects to a scene, add the **`OutdoorCam`** node.

Your scene can look something like this:

```text
Main
├── OutdoorCam
│   └── LightControl
├── World
├── Player
└── CanvasLayer
```

The `OutdoorCam` handles the outdoor lighting and shadow system.

---

# Configuring LightControl

After adding `OutdoorCam`, select its child:

```text
OutdoorCam
└── LightControl
```

The available properties can be changed directly through the Godot Inspector.

Use `LightControl` when you want to customize the visual side of the time system.

For example, you can adjust the lighting progression so that it follows a cycle similar to:

```text
Sunrise
   ↓
Morning
   ↓
Noon
   ↓
Afternoon
   ↓
Sunset
   ↓
Night
   ↓
Sunrise
```

The lighting will change as the `DayCycle` progresses through the in-game day.

---

# Sunrise

The **sunrise** setting determines when the world begins transitioning from nighttime lighting into daytime lighting.

For example:

```text
Night
  ↓
Sunrise
  ↓
Morning
  ↓
Day
```

Adjust the sunrise setting through the **`LightControl`** node.

---

# Noon

The **noon** setting determines the point in the day used for the brightest/daytime portion of the lighting cycle.

For example:

```text
Morning
   ↓
Noon
   ↓
Afternoon
```

Adjust the noon setting through the **`LightControl`** node.

---

# Sunset

The **sunset** setting determines when the world begins transitioning from daytime lighting into nighttime lighting.

For example:

```text
Day
  ↓
Sunset
  ↓
Evening
  ↓
Night
```

Adjust the sunset setting through the **`LightControl`** node.

---

# Changing Colors

The colors used throughout the day/night cycle can be customized through **`LightControl`**.

This allows you to create your own visual style for your game.

A typical lighting cycle could look like:

```text
Morning  → Warm orange/yellow
Day      → Bright daylight
Evening  → Orange/red
Night    → Dark blue
```

You can adjust these colors to create different moods or art styles.

For example, you could use:

* Warm colors for sunrise
* Bright colors during the day
* Orange/red colors during sunset
* Dark blue/purple colors at night

---

# Season Colors

The lighting system can also change colors based on the current season.

This allows each season to have its own visual atmosphere.

For example:

```text
Spring  → Fresh green / bright colors
Summer  → Bright / warm colors
Autumn  → Orange / yellow / red
Winter  → Cool blue / white
```

The exact colors are configurable through the **`LightControl`** node.

---

# Adding Shadows

The system uses `LightOccluder2D` to allow objects to cast shadows.

Add a `LightOccluder2D` to objects that should cast shadows.

For example:

```text
World
├── Trees
│   └── LightOccluder2D
├── Buildings
│   └── LightOccluder2D
└── Player
```

Make sure the required **SDF collision** settings are enabled for your shadow setup.

Once configured, objects can cast shadows based on the outdoor lighting.

---

# Adding the Clock and Date UI

To display the current time, date, and season, add the **`TimeUI`** node to a `CanvasLayer`.

For example:

```text
Main
└── CanvasLayer
    └── TimeUI
```

The `TimeUI` node displays information from the `DayCycle` system.

---

# Time and Season System

The system contains **four seasons**.

Each season contains **30 days**.

This gives the game year:

```text
4 Seasons
×
30 Days
=
120 Days
```

The system keeps track of:

* Current time
* AM/PM
* Current day
* Current season
* Seasonal progression
* Day/night progression

---

# Basic Usage

Because `DayCycle` is loaded globally, you can access it from scripts without manually finding or referencing the node.

For example:

```gdscript
func _ready():
    DayCycle.day_length(120)
```

This makes one complete in-game day last 120 seconds.

---

# Example: Freeze Time Indoors

You can use the freeze functionality when the player enters an interior.

```gdscript
func enter_indoor_area():
    DayCycle.freez = true


func exit_indoor_area():
    DayCycle.freez = false
```

This is optional and depends on how you want time to behave in your game.

---

# Example Scene Setup

A basic outdoor scene could look like:

```text
Main
├── OutdoorCam
│   └── LightControl
├── World
│   ├── Ground
│   ├── Trees
│   │   └── LightOccluder2D
│   └── Buildings
│       └── LightOccluder2D
├── Player
└── CanvasLayer
    └── TimeUI
```

### What each node does

| Node              | Purpose                                                       |
| ----------------- | ------------------------------------------------------------- |
| `OutdoorCam`      | Handles the outdoor day/night lighting system                 |
| `LightControl`    | Controls colors, sunrise, sunset, noon, and lighting behavior |
| `LightOccluder2D` | Allows objects to cast shadows                                |
| `TimeUI`          | Displays the current time/date information                    |
| `DayCycle`        | Global system controlling time and seasons                    |

---

# Recommended Setup

For a typical outdoor scene:

1. Enable the plugin.
2. Add `OutdoorCam`.
3. Make sure `LightControl` is inside `OutdoorCam`.
4. Select `LightControl` to configure:

   * Sunrise
   * Sunset
   * Noon
   * Colors
   * Seasonal lighting
5. Add `LightOccluder2D` to objects that should cast shadows.
6. Configure the required SDF collision settings.
7. Add `TimeUI` to a `CanvasLayer` if you want an on-screen clock/date.
8. Set the desired day length.
9. Start your game.

Example:

```gdscript
func _ready():
    # One in-game day lasts 120 seconds.
    DayCycle.day_length(120)
```

---

# Customization Overview

The system is separated into time and visual controls:

```text
                    DayCycle
                       │
             Controls Game Time
                       │
          ┌────────────┼────────────┐
          ↓            ↓            ↓
        Clock         Date        Season
                       │
                       ↓
                OutdoorCam
                       │
                       ↓
                 LightControl
                       │
          ┌────────────┼────────────┐
          ↓            ↓            ↓
       Sunrise        Noon        Sunset
          │            │            │
          └────────────┼────────────┘
                       ↓
                    Colors
                       ↓
                Day/Night Look
```

This makes it easy to change the appearance of your world without changing how the game's clock works.

---

# Project Structure

The exact structure may vary depending on your project, but a typical addon installation could look like:

```text
your_project/
├── addons/
│   └── time_day_night_season/
│       ├── ...
│       └── plugin.cfg
├── scenes/
├── scripts/
└── project.godot
```

---

# Credits

## Shadow System

The shadow-casting functionality is based on:

**2D Shadows Demo for Godot**
Created by **jess-hammer**

Repository:

https://github.com/jess-hammer/2d-shadows-demo-godot

Many thanks to the original creator for providing the shadow implementation and example.

---

# License

Please check the license of the original shadow project before redistributing or modifying any code derived from it.

If this project contains additional third-party code or assets, their respective licenses should also be followed.

---

# Contributing

Bug reports, improvements, suggestions, and pull requests are welcome.

If you find a problem or have an idea for improving the system, feel free to open an issue or submit a pull request.

---

# Roadmap

Possible future improvements include:

* More customizable seasons
* Custom season lengths
* Configurable sunrise and sunset behavior
* More lighting presets
* Weather integration
* Moon phases
* Time acceleration controls
* Additional UI customization
* More detailed seasonal transitions

---

# Troubleshooting

If you encounter a problem:

1. Make sure the plugin is enabled under:
   **Project → Project Settings → Plugins**

2. Make sure `OutdoorCam` has been added to your scene.

3. Make sure the `LightControl` node is present inside `OutdoorCam`.

4. Use the `LightControl` node to configure the sunrise, sunset, noon, and color settings.

5. Make sure `LightOccluder2D` is configured correctly on objects that should cast shadows.

6. Check that the required SDF collision settings are enabled.

7. Make sure `TimeUI` is added to a `CanvasLayer` if you want to display the clock/date.

8. Check the Godot debugger for errors.

9. Make sure you are using a compatible version of Godot.

---

# Quick Start

For the fastest setup:

### 1. Enable the Plugin

Go to:

**Project → Project Settings → Plugins**

Enable the **Time Day Night Season System**.

### 2. Add OutdoorCam

Add:

```text
OutdoorCam
└── LightControl
```

### 3. Configure Lighting

Select:

```text
OutdoorCam → LightControl
```

Use the Inspector to configure:

* Sunrise
* Noon
* Sunset
* Day/night colors
* Seasonal colors

### 4. Add Shadows

Add `LightOccluder2D` to objects that should cast shadows.

### 5. Add the Clock

Add:

```text
CanvasLayer
└── TimeUI
```

### 6. Set the Day Length

```gdscript
DayCycle.day_length(120)
```

### 7. Run Your Game

The system will now manage the in-game time, seasons, lighting, colors, and shadows.

---

**Enjoy building your world! 🌅 ☀️ 🌇 🌙 🍂 ❄️**
