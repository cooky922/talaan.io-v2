import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../components" as Components

TextField {
    id: searchBar

    color: appTheme.darkTextColor
    font.pixelSize: 12
    placeholderText: "Search"
    placeholderTextColor: Qt.lighter(searchBar.color, 1.5)
    leftPadding: 35
    rightPadding: 40
    clip: true
    
    background: Rectangle {
        color: "transparent"
        border.color: searchBar.activeFocus ? appTheme.activeButtonBgColor : "#D1D5DB"
        border.width: 1
        radius: 16
    }

    // > search icon at the left
    Image {
        source: "../../../../assets/images/icons/search-dark.svg"
        sourceSize.width: 16
        sourceSize.height: 16
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        opacity: 0.5
    }

    // > close icon at the right
    Image {
        source: "../../../../assets/images/icons/close-dark.svg"
        sourceSize.width: 16
        sourceSize.height: 16
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        opacity: clearMouseArea.containsMouse ? 0.8 : 0.5
        visible: searchBar.text.length > 0 

        MouseArea {
            id: clearMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            
            onClicked: {
                searchBar.clear()
                searchDebounce.stop()
                appDirectoryController.updateSearch("")
                searchBar.forceActiveFocus() 
            }
        }
    }

    // > wait for 10ms after user stops typing
    Timer {
        id: searchDebounce
        interval: 10
        repeat: false
        onTriggered: {
            appDirectoryController.updateSearch(searchBar.text)
        }
    }

    onTextEdited: {
        searchDebounce.restart()
    }

    onAccepted: {
        searchDebounce.stop()
        appDirectoryController.updateSearch(searchBar.text)
    }
}