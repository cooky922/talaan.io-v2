import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../components" as Components

Rectangle {
    id: directoryToggleArea

    implicitWidth: toggleRow.implicitWidth + 10
    implicitHeight: toggleRow.implicitHeight + 10
    color: appTheme.headerButtonBgColor

    border.color: Qt.darker(appTheme.headerButtonBgColor, 1.2)
    border.width: 1
    radius: 25

    Row {
        id: toggleRow
        anchors.centerIn: parent
        spacing: 5

        ButtonGroup {
            id: navGroup
        }

        Components.ToggleButton {
            text: "Students"
            iconSource: "../../../assets/images/icons/students-dark.svg"
            ButtonGroup.group: navGroup
            checked: appDirectoryController.currentDirectoryName === "Student"
            onClicked: appDirectoryController.changeDirectory("Student")
        }

        Rectangle {
            width: 2
            height: 20
            radius: 8
            anchors.verticalCenter: parent.verticalCenter
            color: Qt.darker(appTheme.headerButtonBgColor, 1.2)
        }

        Components.ToggleButton {
            text: "Programs"
            iconSource: "../../../assets/images/icons/programs-dark.svg"
            ButtonGroup.group: navGroup
            checked: appDirectoryController.currentDirectoryName === "Program"
            onClicked: appDirectoryController.changeDirectory("Program")
        }

        Rectangle {
            width: 2
            height: 20
            radius: 8
            anchors.verticalCenter: parent.verticalCenter
            color: Qt.darker(appTheme.headerButtonBgColor, 1.2)
        }

        Components.ToggleButton {
            text: "Colleges"
            iconSource: "../../../assets/images/icons/colleges-dark.svg"
            ButtonGroup.group: navGroup
            checked: appDirectoryController.currentDirectoryName === "College"
            onClicked: appDirectoryController.changeDirectory("College")
        }
    }
}