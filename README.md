# Playbox for [Übersicht](http://tracesof.net/uebersicht/)

This widget shows currently played song in either iTunes or Spotify. It has a spiffy progress bar, shows pretty artwork (external dependency: pretty artwork) and has a ton of customization options.

## [Download Playbox][1]

# Features

<img src="https://github.com/melchor629/Playbox.widget/blob/master/screenshot.jpg" width="516" height="320">

- Supports Spotify, iTunes and VOX.
- Shows artwork (from your song metadata).
- Song progress bar.
- Three size variants.
- 🔥 Dark and light themes.
- 🔥 Position song metadata inside or outside the artwork.
- 🔥 If song meta is inside the artwork, it fades out automatically. Click the artwork to show it again. Reapears with the mouse over it!
- Easy way to toggle the widget's visibility.
- Easy way to position the widget on the screen.
- Spiffy fade animations all over the place.
- Show only one player, of your selection, or all available
- Uses less CPU than original.
- Uses a background service to detect song information. [See more](https://github.com/melchor629/Playbox.widget/blob/master/service/README.md)

 > Note for Mojave (10.14): the new permission system makes the background service to not have permission to access the play status of the players. When the service tries to fetch the status, a system popup will show asking you if you allow the service to read the player status. The app only queries the status player, but nothing more.

# How to install

 1. Download the zip from releases
 2. Extract it into the Übersicht widgets folder
 3. Open `Playbox.widget` and you'll see a `install_service.command` file
 4. Open this file, it will open a _Terminal_ and install a _Launch Agent_ (aka daemon) that will serve as the backend for the widget
 5. You should now enjoy the widget now :)

# Options

Here's how you can set all the widget's options. Open `index.jsx` and look at the very top of the document:

```js
  // Choose where the widget should sit on your screen.
  verticalPosition: "bottom",           // top | bottom
  horizontalPosition: "left",           // left | right
  margin: 80,                           // Sets a margin at the `verticalPosition' (in pixels)

  // Choose widget size.
  widgetVariant: "large",               // large | medium | small

  // Choose color theme.
  widgetTheme: "dark",                  // dark | light

  // Song metadata inside or outside? Applies to large and medium variants only.
  metaPosition: "inside",               // inside | outside

  // Stick the widget in the corner? Set to *true* if you're using it with Sidebar widget, set to *false* if you'd like to give it some breathing room and a drop shadow.
  stickInCorner: false,                 // true | false

  // Only show current song from that app (ignore others). A value different from false will apply only for that player.
  playerApp: false,                     // false | "spotify" | "itunes" | "vox"
```

## [Download Playbox][1]

Fork of [Pe8er/Playbox.widget][2]


  [1]: https://github.com/melchor629/Playbox.widget/releases/download/latest/Playbox.widget.zip
  [2]: https://github.com/Pe8er/Playbox.widget
