/**
 * Code originally created by the awesome members of Ubersicht community.
 * I stole from so many I can't remember who you are, thank you so much everyone!
 * Haphazardly adjusted and mangled by Pe8er (https://github.com/Pe8er)
 * Forked by melchor629 (https://github.com/melchor629)
 */
// ~ Version: 2.0 ~
import { css } from "uebersicht";

const options = {
  // Choose where the widget should sit on your screen.
  verticalPosition: "bottom",           // top | bottom | center
  horizontalPosition: "left",           // left | right | center
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
};


export const initialState = { status: 'stopped' };

export const command = (dispatch) => {
  let url = 'http://127.0.0.1:45987';
  if(options.playerApp) {
    url = `${url}/player/${options.playerApp}`
  }

  const ok = (data) => {
    dispatch({ type: 'UPDATED_PLAYER_INFO', data });
  };

  fetch(`http://127.0.0.1:41417/${url}`)
    .then((res) => {
      if(!res.ok) {
        throw res;
      } else {
        return res.json();
      }
    })
    .then((data) => ok(data))
    .catch((error) => dispatch({ type:'UPDATED_PLAYER_INFO_ERROR', error }));
};


export const refreshFrequency = 1000;


export const styles = (() => {
  let fColor, bgColor, bgBrightness;

  if(options.widgetTheme === 'dark') {
    fColor = '255,255,255';
    bgColor = '0,0,0';
    bgBrightness = '80%';
  } else {
    fColor = '0,0,0';
    bgColor = '255,255,255';
    bgBrightness = '120%';
  }

  const fColor1 = `rgba(${fColor}, 1.0)`;
  const fColor08 = `rgba(${fColor},0.8)`;
  const fColor05 = `rgba(${fColor},0.5)`;
  const fColor02 = `rgba(${fColor},0.2)`;
  const bgColor1 = `rgba(${bgColor},1.0)`;
  const bgColor08 = `rgba(${bgColor},0.7)`;
  const bgColor05 = `rgba(${bgColor},0.5)`;
  const bgColor02 = `rgba(${bgColor},0.2)`;
  const blurProperties = `blur(10px) brightness(${bgBrightness}) contrast(100%) saturate(140%)`;
  let margin = 0;

  let root = {
    cursor: 'default !important',
  };

  if(!options.stickInCorner) {
    margin = 20;
    root.boxShadow = '0 20px 40px 0px rgba(0,0,0,.6)';
    root.borderRadius = '6px';
    root['.text'] = {
      borderRadius: '0 0 6px 6px',
    };

    if(options.widgetVariant !== 'small') {
      root['.art'] = {
        borderRadius: '6px',
      };
    }
  } else {
    root.margin = 0;
  }

  if(options.verticalPosition === 'center') {
    root.top = '50%';
    root.transform = 'translateY(-50%)';
  } else {
    root[options.verticalPosition] = options.margin + margin;
  }

  if(options.horizontalPosition === 'center') {
    root.left = '50%';
    root.transform = 'translateX(-50%)';
  } else {
    root[options.horizontalPosition] = margin;
  }

  root['+, +:before, *:after'] = {
    boxSizing: 'border-box',
  };

  const mainDimension = 270; //176 original
  root = {
    ...root,
    position: 'absolute',
    transformStyle: 'preserve-3d',
    transform: 'translate3d(0px, 0px, 0px)',
    width: 'auto',
    minWidth: '200px',
    maxWidth: mainDimension,
    overflow: 'hidden',
    whiteSpace: 'nowrap',
    backgroundColor: bgColor02,
    fontFamily: 'system, -apple-system, "Helvetica Neue"',
    border: 'none',
    '-webkit-backdrop-filter': blurProperties,
    zIndex: 10,
    transition: 'opacity .3s ease',

    '&.hide': {
      opacity: 0,
    },

    '.wrapper': {
      ...(root['.wrapper'] || {}),
      fontSize: '8pt',
      lineHeight: '11pt',
      color: fColor1,
      display: 'flex',
      flexDirection: 'row',
      justifyContent: 'flex-start',
      flexWrap: 'nowrap',
      alignItems: 'center',
      overflow: 'hidden',
      zIndex: '1',
      transition: 'opacity .3s ease',
    },

    '.art': {
      ...root['.art'],
      width: '64px',
      height: '64px', //'@width',
      backgroundColor: fColor05,
      backgroundImage: 'url(/Playbox.widget/lib/default.png)',
      backgroundSize: 'cover',
      zIndex: 2,
    },

    '.text': {
      ...root['.text'],
      left: '64px',
      margin: '0 32px 0 8px',
      maxWidth: mainDimension,
      zIndex: 3,
    },

    '.progress': {
      width: 'auto', //'@width',
      height: '2px',
      background: fColor1,
      position: 'absolute',
      bottom: 0,
      left: 0,
      zIndex: 4,
      transition: 'width .3s ease',
    },

    '.wrapper, .album, .artist, .song': {
      overflow: 'hidden',
      textOverflow: 'ellipsis',
    },

    '.album, .artist, .song': {
      maxWidth: mainDimension,
    },

    '.song': {
      fontWeight: 700,
    },

    '.album': {
      color: fColor05,
    },

    '.heart': {
      position: 'absolute',
      color: 'white',
      top: '4px',
      [options.horizontalPosition]: '4px', //@top,
      fontSize: '16px',
      transition: 'opacity .3s ease',
    },

    '.heart.hide': {
      opacity: 0,
    },
  };


  //Different styles for different widget sizes.
  let scale = NaN;
  if(options.widgetVariant === 'medium') {
    scale = 0.75;
    root['.wrapper'].fontSize = '8pt !important';
    root['.wrapper'].lineHeight = '10pt !important';

    root['.album'].display = none;

    root['.heart'].fontSize = '12px !important';
  } else {
    scale = 1;
  }

  if(options.widgetVariant === 'large' || options.widgetVariant === 'medium') {
    root.minWidth = 0;

    root['.wrapper'] = {
      ...root['.wrapper'],
      flexDirection: 'column',
      justifyContent: 'flex-start',
      flexWrap: 'nowrap',
      alignItems: 'center'
    };

    root['.art'] = {
      ...root['.art'],
      width: mainDimension * scale,
      height: mainDimension * scale, //@width,
      margin: 0,
    };

    root['.text'] = {
      ...root['.text'],
      margin: '8px',
      float: 'none',
      textAlign: 'center',
      maxWidth: (mainDimension * scale) - 20,
      opacity: 0,
      transition: 'opacity .5s .5s ease',
    };

    root['.wrapper:hover .text, .text.show'] = {
      opacity: 1,
      transition: 'opacity .25s ease',
    };

    if(options.metaPosition === 'outside') {
      root['.progress'].top = mainDimension * scale;
      root['.art'].borderRadius = '6px 6px 0 0';
    } else if(options.metaPosition === 'inside') {
      root.backgroundColor = 'black';
      root['-webkit-backdrop-filter'] = 'none';

      root['.wrapper'].overflow = 'hidden';

      root['.text'] = {
        ...root['.text'],
        '-webkit-backdrop-filter': blurProperties,
        position: 'absolute',
        bottom: 0,
        left: 0,
        margin: 0,
        padding: '8px',
        color: fColor1,
        backgroundColor: bgColor08,
        width: mainDimension * scale,
        maxWidth: mainDimension * scale, //@width,
      }
    }
  }

  return css(root);
})();


export const updateState = (event, previousState) => {
  switch(event.type) {
    case 'UPDATED_PLAYER_INFO_ERROR': {
      return {
        ...previousState,
        status: 'playing',
        metadata: {
          name: "Daemon is not running",
          artist: "Check README.md for more info",
          album: null,
          duration: 1,
          position: 1,
        },
        coverUrl: "/Playbox.widget/lib/default.png",
        player: "Nothing",
        songChanged: true,
        showMetadata: true,
        previousState: undefined,
      };
    }

    case 'UPDATED_PLAYER_INFO': {
      if(event.data.status !== 'playing') {
        return {
          ...previousState,
          ...event.data,
          previousState: previousState.previousState ? previousState.previousState : previousState,
        };
      } else {
        const shouldShowMetadata = event.data.songChanged && options.metaPosition === 'inside' && options.widgetVariant !== 'small';
        return {
          ...previousState,
          ...event.data,
          showMetadata: shouldShowMetadata ? 2 : Math.max(0, previousState.showMetadata - 1),
          previousState: undefined,
        };
      }
    }

    case 'SHOW_METADATA': {
      return {
        ...previousState,
        showMetadata: true,
      };
    }

    case 'HIDE_METADATA': {
      return {
        ...previousState,
        showMetadata: false,
      };
    }
  }

  return previousState;
}


const Art = ({ coverUrl, loved }) => (
  <div className="art" style={{ backgroundImage: `url("${coverUrl}")` }}>
    <span className={ `heart ${loved ? '' : 'hide'}` }>&#9829;</span>
  </div>
);

const Metadata = ({ metadata, show }) => (
  <div className={ `${show ? 'show' : ''} text` }>
    <div className="song">{ metadata.name }</div>
    <div className="artist">{ metadata.albumArtist || metadata.artist }</div>
    <div className="album">{ metadata.album }</div>
  </div>
);

const ProgressBar = ({ progress }) => (
  <div className="progress" style={{ width: `${progress}%` }} />
);

export const render = ({ status, metadata, coverUrl, showMetadata, previousState }) => {
  let meta = metadata;
  let cover = coverUrl;
  let hide = false;

  if(status !== 'playing') {
    meta = previousState.metadata;
    cover = previousState.coverUrl;
    hide = true;
  }

  if(meta === undefined) {
    meta = {
      position: 0,
      duration: 1,
      loved: false,
    };
  }

  const progress = (meta.position / meta.duration) * 100;
  cover = cover || `http://${location.host}/Playbox.widget/lib/default.png`;

  return (
    <div className={ `${styles} ${hide ? 'hide' : ''}` }>
      <div className="wrapper">
        <ProgressBar progress={ progress } />
        <Art coverUrl={ cover } loved= { metadata.loved } />
        <Metadata show={ showMetadata } metadata={ meta } />
      </div>
    </div>
  );
};