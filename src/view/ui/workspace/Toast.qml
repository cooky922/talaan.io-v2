import QtQuick

Rectangle {
    id: root

    property alias message: toastText.text
    property bool isError: false

    z: 100
    
    width: Math.min(toastText.implicitWidth + 40, parent ? parent.width - 40 : 400)
    height: toastText.implicitHeight + 24
    
    color: isError ? "#ff4c4c" : "#333333"
    radius: 6
    opacity: 0.0 // Starts invisible
    
    anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined
    anchors.bottom: parent ? parent.bottom : undefined
    anchors.bottomMargin: 20

    function showToast(msg, errorFlag = false) {
        root.message = msg
        root.isError = errorFlag
        toastAnim.restart()
    }

    // > handles the sliding offset
    transform: Translate {
        id: yOffset
        y: 20 // > starts 20px pushed down
    }

    // main content
    Text {
        id: toastText
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -2 
        color: "white"
        font.bold: true
        font.pixelSize: 12
        text: ""
        horizontalAlignment: Text.AlignHCenter
    }

    // decreasing timer progress bar
    Rectangle {
        id: toastProgress
        height: 3
        color: "white"
        opacity: 0.4
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        width: root.width 
        
        bottomLeftRadius: 6
        bottomRightRadius: 6 
    }

    // animation sequence
    SequentialAnimation {
        id: toastAnim
        
        // > reset state instantly
        PropertyAction { target: yOffset; property: "y"; value: 20 }
        PropertyAction { target: root; property: "opacity"; value: 0.0 }
        PropertyAction { target: toastProgress; property: "width"; value: root.width }

        // > slide up and fade in (400ms OutCubic)
        ParallelAnimation {
            NumberAnimation { target: root; property: "opacity"; to: 0.99; duration: 400; easing.type: Easing.OutCubic }
            NumberAnimation { target: yOffset; property: "y"; to: 0; duration: 400; easing.type: Easing.OutCubic }
        }

        // > shrink progress (2500ms Timer)
        NumberAnimation { target: toastProgress; property: "width"; to: 0; duration: 2500 }

        // > slide down and fade out (400ms InCubic)
        ParallelAnimation {
            NumberAnimation { target: root; property: "opacity"; to: 0.0; duration: 400; easing.type: Easing.InCubic }
            NumberAnimation { target: yOffset; property: "y"; to: 20; duration: 400; easing.type: Easing.InCubic }
        }
    }
}