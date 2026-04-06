import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: userRoleToggleArea
    color: "transparent"

    RowLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 2
        spacing: 20

        RoleToggleButton {
            roleName: "Admin"
            Layout.preferredWidth: 90
            Layout.preferredHeight: 90
            Layout.topMargin: 20
            Layout.bottomMargin: 20
        }

        RoleToggleButton {
            roleName: "Viewer"
            Layout.preferredWidth: 90
            Layout.preferredHeight: 90
            Layout.topMargin: 20
            Layout.bottomMargin: 20
        }

        component RoleToggleButton : Button {
            id: toggleButton
            property string roleName
            readonly property int role: roleName === "Admin" ? 0 : 1

            function getIconSource(kind) {
                var path = "../../../../assets/images/icons/%1-%2.svg"
                return path.arg(roleName.toLowerCase()).arg(kind)
            }

            background: Rectangle {
                color: {
                    if (app.activeRole === role)
                        return Qt.rgba(0, 0, 0, 0.60)
                    else {
                        return toggleButton.hovered ? Qt.rgba(0, 0, 0, 0.20) : Qt.rgba(0, 0, 0, 0.10)
                    }
                }
                border.color: Qt.rgba(0, 0, 0, 0.60)
                border.width: app.activeRole === role ? 2 : 0
                radius: 20
            }

            contentItem: Column {
                anchors.centerIn: parent
                spacing: 8

                Image {
                    source: app.activeRole === role ? getIconSource("light") : getIconSource("dark")
                    sourceSize.width: 45
                    sourceSize.height: 45
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    text: roleName
                    font.bold: app.activeRole === role
                    color: app.activeRole === role ? "white" : "black"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: app.activeRole = role
            }
        }
    }
}