import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    property string text: "Label"
    property string iconSource: ""
    property bool isActive: false

    property color defaultTextColor: "#6B7280" // Gray
    property color activeTextColor: "#111827"  // Very Dark Gray/Black
    
    property color hoverBgColor: "#F3F4F6" // Light gray
    property color activeBgColor: "#E5E7EB" // Darker gray

    implicitWidth: 64
    implicitHeight: 64

    signal clicked()

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 2

        // > icon with dynamic background based on state
        Rectangle {
            id: iconBg
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 45
            Layout.preferredHeight: 30
            radius: 16

            color: {
                if (root.isActive) return Qt.rgba(0, 0, 0, 0.1)
                if (mouseArea.containsMouse) return Qt.rgba(0, 0, 0, 0.05)
                return "transparent"
            }

            Image {
                anchors.centerIn: parent
                source: root.iconSource
                sourceSize.width: 25
                sourceSize.height: 25
                opacity: root.isActive ? 1.0 : 0.75
            }
        }

        // > label
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: root.text
            font.pixelSize: 11
            font.bold: root.isActive
            font.family: appTheme.rethinkSansFontName
            color: "#333333"
            opacity: root.isActive ? 1.0 : 0.75
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}