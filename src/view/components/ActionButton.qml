import QtQuick
import QtQuick.Controls
import QtQuick.Effects

Button {
    id: root
    property color buttonColor: "black"
    property int textSize: 14
    property color textColor: "white"
    property bool bordered: false

    property string iconSource: ""
    property string iconPosition: "left"

    default property alias buttonContent: root.data

    padding: 10

    background: Rectangle {
        color: root.enabled ? appUtils.calculateColor(buttonColor, parent.hovered, parent.down) : buttonColor
        radius: 16

        border.color: appUtils.calculateColor(buttonColor, true, false)
        border.width: bordered ? 1 : 0
    }

    contentItem: Item {
        implicitWidth: contentRow.implicitWidth
        implicitHeight: contentRow.implicitHeight

        Row {
            id: contentRow
            anchors.centerIn: parent
            spacing: root.iconSource !== "" ? 8 : 0
            layoutDirection: root.iconPosition === "right" ? Qt.RightToLeft : Qt.LeftToRight

            Item {
                width: root.iconSource !== "" ? textSize * 1.1 : 0
                height: root.iconSource !== "" ? textSize * 1.1 : 0
                anchors.verticalCenter: parent.verticalCenter
                visible: root.iconSource !== ""

                Image {
                    id: buttonIcon
                    source: root.iconSource
                    sourceSize.width: textSize * 1.1
                    sourceSize.height: textSize * 1.1
                    anchors.fill: parent
                    visible: false
                }

                MultiEffect {
                    source: buttonIcon
                    anchors.fill: buttonIcon
                    colorizationColor: root.textColor
                    colorization: 1.0
                    brightness: 1.0
                }
            }

            Text {
                text: root.text
                color: root.textColor
                font.pixelSize: textSize
                font.bold: true
                font.family: appTheme.rethinkSansFontName
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
    }
}