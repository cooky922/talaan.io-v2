import QtQuick
import QtQuick.Controls
import QtQuick.Effects

Button {
    id: root
    
    // Custom properties
    property string iconSource: ""
    
    // Translating your PyQt colors
    property color activeBgColor: appTheme.activeButtonBgColor
    property color hoverBgColor: Qt.rgba(143/255, 174/255, 68/255, 0.15)
    property color activeTextColor: "#ffffff"
    property color inactiveTextColor: appTheme.darkTextColor
    
    checkable: true
    hoverEnabled: true

    HoverHandler {
        cursorShape: Qt.PointingHandCursor
    }
    
    leftPadding: 10
    rightPadding: 10
    topPadding: 6
    bottomPadding: 6

    // 1. The Pill Background
    background: Rectangle {
        radius: 16
        color: root.checked ? root.activeBgColor : 
               root.hovered ? root.hoverBgColor : "transparent"
    }

    // the content
    contentItem: Row {
        spacing: 8
        anchors.centerIn: parent

        // The Icon (Recolors based on checked state)
        Item {
            width: 16
            height: 16
            anchors.verticalCenter: parent.verticalCenter
            visible: root.iconSource !== ""

            Image {
                id: iconImg
                source: root.iconSource
                sourceSize.width: 16
                sourceSize.height: 16
                anchors.fill: parent
                visible: false // Let MultiEffect draw it
            }

            MultiEffect {
                source: iconImg
                anchors.fill: iconImg
                // If checked -> White, If inactive -> Dark Gray
                colorizationColor: root.checked ? root.activeTextColor : root.inactiveTextColor
                colorization: 1.0
                brightness: 1.0
            }
        }

        // The Label
        Text {
            text: root.text
            font.pixelSize: 12
            // Bold when checked, normal when inactive
            font.bold: root.checked 
            color: root.checked ? root.activeTextColor : root.inactiveTextColor
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}