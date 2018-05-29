import QtQuick 2.0
import SddmComponents 2.0
import QtMultimedia 5.8

Item {
  id: page
  width: 1920
  height: 1080


  // Background Fill: Just in case video/background image fails to load.
  Rectangle {
    anchors.fill: parent
    color: "black"
  }

  //Set Background Image: Just in case video fails to load.
  Image {
    anchors.fill: parent
    source: config.background
    fillMode: Image.PreserveAspectCrop
  }

  // Background Music 
  MediaPlayer {
      id: media_player_music
      autoPlay: true
      playlist: Playlist {
        id: playlist_music
        playbackMode: Playlist.Random
        onLoaded: { media_player_music.play() }
      } 
  }

// Background Video
// Two Media players are used to help with transitioning between videos.

// Background video: Media Player 1
  MediaPlayer {
    id: mediaplayer1
    autoPlay: true
    muted: true
    playlist: Playlist {
      id: playlist1
      playbackMode: Playlist.Random
      onLoaded: { mediaplayer1.play() }
    }
  }

  VideoOutput {
      id: video1
      fillMode: VideoOutput.PreserveAspectCrop
      anchors.fill: parent
      source: mediaplayer1
      MouseArea {
          id: mouseArea1
          anchors.fill: parent;
          onPressed: {playlist1.shuffle(); playlist1.next();}
      }
  }

  // Background video: Media Player 2
  MediaPlayer {
      id: mediaplayer2
      autoPlay: true
      muted: true
      playlist: Playlist {
          id: playlist2
           playbackMode: Playlist.Random
          //onLoaded: { mediaplayer2.play() }
      }
  }

  VideoOutput {
    id: video2
    fillMode: VideoOutput.PreserveAspectCrop
    anchors.fill: parent
    source: mediaplayer2
    opacity: 0
    MouseArea {
      id: mouseArea2
      enabled: false
      anchors.fill: parent;
      onPressed: {playlist2.shuffle(); playlist2.next();}
    }
    Behavior on opacity {
      enabled: true
      NumberAnimation { easing.type: Easing.InOutQuad; duration: 3000 }
    }
  }

  property MediaPlayer currentPlayer: mediaplayer1

// Timer event to handle fade between videos
  Timer {
    interval: 1000;
    running: true
    repeat: true
    onTriggered: {
        if (currentPlayer.duration != -1 && currentPlayer.position > currentPlayer.duration - 10000) { // pre load the 2nd player
          if (video2.opacity == 0) { // toogle opacity
            mediaplayer2.play()
          } else
            mediaplayer1.play()
        }
        if (currentPlayer.duration != -1 && currentPlayer.position > currentPlayer.duration - 3000) { // initiate transition
          if (video2.opacity == 0) { // toogle opacity
            mouseArea1.enabled = false
            currentPlayer = mediaplayer2
            video2.opacity = 1
            triggerTimer.start()
            mouseArea2.enabled = true
            } else {
              mouseArea2.enabled = false
              currentPlayer = mediaplayer1
              video2.opacity = 0
              triggerTimer.start()
              mouseArea1.enabled = true
            }
        }
    }
  }

  Timer { // this timer waits for fade to stop and stops the video
    id: triggerTimer
    interval: 4000
    running: false
    repeat: false
    onTriggered: {
      if (video2.opacity == 1)
          mediaplayer1.stop()
      else
          mediaplayer2.stop()
    }
  }
  //Time and Date
  Clock {
    id: clock
    y: parent.height * config.relativePositionY - clock.height / 2
    x: parent.width * config.relativePositionX - clock.width / 2
    color: "white"
    timeFont.pointSize: 110
    dateFont.pointSize: 30
    timeFont.family: "Fira sans"
    dateFont.family: "Fira Sans"
}


  // // Weather Not implemented.
  // Image {
  //   source: "Assets/weather.png"
  //     y: parent.height * config.w_relativePositionY - clock.height /2
  //     x: parent.height * 0.12 - clock.height /2
  //   width: 50
  //   height: 50
  // }
  
  Text {
    text: "16 °C - NSCD\nPressure: 1022 Mb"
    y: parent.height * config.w_relativePositionY - clock.height /2
    x: parent.height * config.w_relativePositionX - clock.height /2
    font.family: "Fira Sans"
    font.pointSize: 15
    color: "#7e7e7e"
  }


  Login {
      id: loginFrame
      visible: false
      opacity: 1
  }

  PowerFrame {
      id: powerFrame
  }


//Session / DE selector (cog button)
  ListView {
    id: sessionSelect
    width: currentItem.width
    height: count * currentItem.height
    model: sessionModel
    currentIndex: sessionModel.lastIndex
    visible: false
    opacity: 1
    flickableDirection: Flickable.AutoFlickIfNeeded
    anchors {
      bottom: powerFrame.top
      right: page.right
      rightMargin: 35
    }
    delegate: Item {
      width: 100
      height: 50
      Text {
        width: parent.width
        height: parent.height
        text: name
        color: "white"
        opacity: (delegateArea.containsMouse || sessionSelect.currentIndex == index) ? 1 : 0.3
        font {
          pointSize: (config.enableHDPI == "true") ? 6 : 12
          family: "FiraMono"
        }
        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        Behavior on opacity {
          NumberAnimation { duration: 250; easing.type: Easing.InOutQuad}
        }
      }

      MouseArea {
        id: delegateArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
          sessionSelect.currentIndex = index
          sessionSelect.state = ""
        }
      }
    }

// Weather

    states: State {
      name: "show"
      PropertyChanges {
        target: sessionSelect
        visible: true
        opacity: 1
      }
    }

    transitions: [
    Transition {
      from: ""
      to: "show"
      SequentialAnimation {
        PropertyAnimation {
          target: sessionSelect
          properties: "visible"
          duration: 0
        }
        PropertyAnimation {
          target: sessionSelect
          properties: "opacity"
          duration: 500
        }
      }
    },
    Transition {
      from: "show"
      to: ""
      SequentialAnimation {
        PropertyAnimation {
          target: sessionSelect
          properties: "opacity"
          duration: 500
        }
        PropertyAnimation {
          target: sessionSelect
          properties: "visible"
          duration: 0
        }
      }
    }
    ]

  }

// User selection Element
  ChooseUser {
    id: listView
    visible: false
    opacity: 1
  }

  states: State {
    name: "login"
    PropertyChanges {
      target: listView
      visible: false
      opacity: 1 
    }

    PropertyChanges {
      target: loginFrame
      visible: true
      opacity: 1
    }
  }

  transitions: [
  Transition {
    from: ""
    to: "login"
    reversible: false

    SequentialAnimation {
      PropertyAnimation {
        target: listView
        properties: "opacity"
        duration: 500
      }
      PropertyAnimation {
        target: listView
        properties: "visible"
        duration: 0
      }
      PropertyAnimation {
        target: loginFrame
        properties: "visible"
        duration: 0
      }
      PropertyAnimation {
        target: loginFrame
        properties: "opacity"
        duration: 500
      }
    }
  },
  Transition {
    from: "login"
    to: ""
    reversible: false

    SequentialAnimation {
      PropertyAnimation {
        target: loginFrame
        properties: "opacity"
        duration: 500
      }
      PropertyAnimation {
        target: loginFrame
        properties: "visible"
        duration: 0
      }
      PropertyAnimation {
        target: listView
        properties: "visible"
        duration: 0
      }
      PropertyAnimation {
        target: listView
        properties: "opacity"
        duration: 500
      }
    }
  }]

  Component.onCompleted: {
    var time = parseInt(new Date().toLocaleTimeString(Qt.locale(),'h'))
        if ( time >= 5 && time <= 17 ) {
          playlist1.load(Qt.resolvedUrl(config.background_day), 'm3u')
          playlist2.load(Qt.resolvedUrl(config.background_day), 'm3u')
          playlist_music.load(Qt.resolvedUrl(config.Music), 'm3u')
        } else {
          playlist1.load(Qt.resolvedUrl(config.background_night), 'm3u')
          playlist2.load(Qt.resolvedUrl(config.background_night), 'm3u')
          playlist_music.load(Qt.resolvedUrl(config.Music), 'm3u')
        }

    for (var k = 0; k < Math.ceil(Math.random() * 10) ; k++) {
      playlist1.shuffle()
      playlist2.shuffle()
      playlist_music.shuffle()
}
  }

}
