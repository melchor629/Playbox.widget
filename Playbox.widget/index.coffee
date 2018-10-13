# Code originally created by the awesome members of Ubersicht community.
# I stole from so many I can't remember who you are, thank you so much everyone!
# Haphazardly adjusted and mangled by Pe8er (https://github.com/Pe8er)
# Forked by melchor629 (https://github.com/melchor629)

options =
  # Choose where the widget should sit on your screen.
  verticalPosition    : "bottom"        # top | bottom | center
  horizontalPosition    : "left"        # left | right | center
  margin: "80px"                        # Sets a margin at the `verticalPosition'

  # Choose widget size.
  widgetVariant: "large"                # large | medium | small

  # Choose color theme.
  widgetTheme: "dark"                   # dark | light

  # Song metadata inside or outside? Applies to large and medium variants only.
  metaPosition: "inside"                # inside | outside

  # Stick the widget in the corner? Set to *true* if you're using it with Sidebar widget, set to *false* if you'd like to give it some breathing room and a drop shadow.
  stickInCorner: false                  # true | false

  # Only show current song from that app (ignore others). A value different from false will apply only for that player.
  playerApp: false                      # false | "spotify" | "itunes" | "vox"

command: (callback) ->
  errorCallback = (error) ->
    obj =
      status: 'playing'
      metadata:
        name: "Daemon is not running"
        artist: "Check README.md for more info"
        album: null
        duration: 1
        position: 1
      coverUrl: "/Playbox.widget/lib/default.png"
      player: "Nothing"
      songChanged: true
    callback null, obj

  url = 'http://[::1]:45987'
  if options.playerApp
    url = "#{url}/player/#{options.playerApp}"
  fetch("http://127.0.0.1:41417/#{url}")
    .then((res) ->
      if not res.ok
        throw res
      else
        res.json()
    )
    .then((data) -> callback(null, data))
    .catch((error) -> errorCallback(error))

refreshFrequency: '1s'

style: """

  // Let's do theming first.

  if #{options.widgetTheme} == dark
    fColor = white
    bgColor = black
    bgBrightness = 80%
  else
    fColor = black
    bgColor = white
    bgBrightness = 120%
  
  cursor: default !important

  // Specify color palette and blur properties.

  fColor1 = rgba(fColor,1.0)
  fColor08 = rgba(fColor,0.8)
  fColor05 = rgba(fColor,0.5)
  fColor02 = rgba(fColor,0.2)
  bgColor1 = rgba(bgColor,1.0)
  bgColor08 = rgba(bgColor,0.7)
  bgColor05 = rgba(bgColor,0.5)
  bgColor02 = rgba(bgColor,0.2)
  blurProperties = blur(10px) brightness(bgBrightness) contrast(100%) saturate(140%)

  // Next, let's sort out positioning.

  if #{options.stickInCorner} == false
    margin = 20px
    box-shadow 0 20px 40px 0px rgba(0,0,0,.6)
    border-radius 6px
    .text
      border-radius 0 0 6px 6px
  else
    margin = 0

  if #{options.stickInCorner} == false and #{options.widgetVariant} != small
    .art
      border-radius 6px

  if #{options.verticalPosition} == center
    top 50%
    transform translateY(-50%)
  else
    #{options.verticalPosition} #{options.margin} + margin
  if #{options.horizontalPosition} == center
    left 50%
    transform translateX(-50%)
  else
    #{options.horizontalPosition} margin

  // Misc styles.

  *, *:before, *:after
    box-sizing border-box

  display none
  position absolute
  transform-style preserve-3d
  -webkit-transform translate3d(0px, 0px, 0px)
  mainDimension = 270px //176 original
  width auto
  min-width 200px
  max-width mainDimension
  overflow hidden
  white-space nowrap
  background-color bgColor02
  font-family system, -apple-system, "Helvetica Neue"
  border none
  -webkit-backdrop-filter blurProperties
  z-index 10

  .wrapper
    font-size 8pt
    line-height 11pt
    color fColor1
    display flex
    flex-direction row
    justify-content flex-start
    flex-wrap nowrap
    align-items center
    overflow hidden
    z-index 1

  .art
    width 64px
    height @width
    background-color fColor05
    background-image url(/Playbox.widget/lib/default.png)
    background-size cover
    z-index 2

  .text
    left 64px
    margin 0 32px 0 8px
    max-width mainDimension
    z-index 3

  .progress
    width @width
    height 2px
    background fColor1
    position absolute
    bottom 0
    left 0
    z-index 4
    transition: width .3s ease

  .wrapper, .album, .artist, .song
    overflow hidden
    text-overflow ellipsis

  .album, .artist, .song
    max-width mainDimension

  .song
    font-weight 700

  .album
    color fColor05

  .heart
    position absolute
    color white
    top 4px
    #{options.horizontalPosition} @top
    font-size 16px

  // Different styles for different widget sizes.

  if #{options.widgetVariant} == medium
    Scale = 0.75

    .wrapper
      font-size 8pt !important
      line-height 10pt !important

    .album
      display none

    .heart
      font-size 12px !important
  else
    Scale = 1

  if #{options.widgetVariant} == large or #{options.widgetVariant} == medium

    min-width 0

    .wrapper
      flex-direction column
      justify-content flex-start
      flex-wrap nowrap
      align-items center

    .art
      width mainDimension * Scale
      height @width
      margin 0

    .text
      margin 8px
      float none
      text-align center
      max-width (mainDimension * Scale) - 20
      opacity: 0
      transition opacity .5s .5s ease

    .wrapper:hover .text, .text.show
      opacity: 1
      transition opacity .25s ease

    if #{options.metaPosition} == outside
      .progress
        top mainDimension * Scale
      .art
        border-radius 6px 6px 0 0

    if #{options.metaPosition} == inside
      background-color black
      -webkit-backdrop-filter none

      .wrapper
        overflow hidden

      .text
        -webkit-backdrop-filter blurProperties
        position absolute
        bottom 0
        left 0
        margin 0
        padding 8px
        color fColor1
        background-color bgColor08
        width mainDimension * Scale
        max-width @width
"""

options : options

render: () -> """
  <div class="wrapper">
    <div class="progress"></div>
    <div class="art"><span class="heart">&#9829;</span></div>
    <div class="text">
      <div class="song"></div>
      <div class="artist"></div>
      <div class="album"></div>
    </div>
  </div>
  """

afterRender: (domEl) ->
  $.getScript "Playbox.widget/lib/jquery.animate-shadow-min.js"
  div = $(domEl)

  meta = div.find('.text')

  if @options.verticalPosition is 'center'
    div.css('top', (screen.height - div.height())/2)
  if @options.horizontalPosition is 'center'
    div.css('left', (screen.width - div.width())/2)

  if @options.metaPosition is 'inside' and @options.widgetVariant isnt 'small'
    @showMeta div

    div.click =>
      if @options.stickInCorner is false
        div.stop(true,true).animate({zoom: '0.99', boxShadow: '0 0 2px rgba(0,0,0,1.0)'}, 200, 'swing')
        div.stop(true,true).animate({zoom: '1.0', boxShadow: '0 20px 40px 0px rgba(0,0,0,0.6)'}, 300, 'swing')

showMeta: (div) ->
  meta = div.find('.text')
  meta.addClass('show')
  if @_metaTimeout
    clearTimeout @_metaTimeout
  @_metaTimeout = setTimeout =>
    meta.removeClass('show')
    @_metaTimeout = null
  , 3000

# Update the rendered output.
update: (output, domEl) ->

  # Get our main DIV.
  div = $(domEl)

  if !output
    div.animate({opacity: 0}, 250, 'swing').hide(1)
  else
    if typeof output is 'string'
        values = JSON.parse(output)
    else
        values = output

    if values.status isnt "playing"
      return div.animate({opacity: 0}, 250, 'swing').hide(1)

    metadata = values.metadata
    div.find('.artist').html(metadata.albumArtist || metadata.artist)
    div.find('.song').html(metadata.name)
    div.find('.album').html(metadata.album)
    tDuration = metadata.duration
    tPosition = metadata.position
    tArtwork = values.coverUrl || "http://#{location.host}/Playbox.widget/lib/default.png"
    songChanged = metadata.songChanged
    isLoved = metadata.loved
    currArt = div.find('.art').css('background-image').split('"')[1].split('?')[0]
    tWidth = div.width()
    tCurrent = (tPosition / tDuration) * tWidth
    div.find('.progress').css width: tCurrent

    div.show(1).animate({opacity: 1}, 250, 'swing')

    if currArt isnt tArtwork or songChanged
      artwork = div.find('.art')
      artwork.css('background-image', 'url("'+tArtwork+'?_no_cache='+Math.random()+'")')

    if songChanged and @options.metaPosition is 'inside' and @options.widgetVariant isnt 'small'
      @showMeta div

    if isLoved
      div.find('.heart').show()
    else
      div.find('.heart').hide()

  div.css('max-width', screen.width)
