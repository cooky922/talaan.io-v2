import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import "../../components" as Components

Button {
    id: accountArea

    implicitWidth: 100
    implicitHeight: 35
    hoverEnabled: true
    
    property string roleText: "Viewer"

    signal logoutRequested()
    signal aboutRequested()
    signal settingsRequested()

    HoverHandler {
        cursorShape: Qt.PointingHandCursor
    }

    background: Rectangle {
        color: appUtils.calculateColor(appTheme.headerButtonBgColor, accountArea.hovered, accountMenu.opened)
        border.color: Qt.darker(appTheme.headerButtonBgColor, 1.2)
        border.width: 1
        radius: 16
    }

    // main button content
    contentItem: RowLayout {
        anchors.centerIn: parent
        height: parent.height
        spacing: 10

        Item { Layout.fillWidth: true }

        Components.InfoText {
            text: accountArea.roleText
            textColor: appTheme.darkTextColor
            font.bold: true
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
        }

        Image {
            source: "../../../../assets/images/icons/account-dark.svg"
            sourceSize.width: 24
            sourceSize.height: 24
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
        }

        Item { Layout.fillWidth: true }
    }

    component CustomMenuItem: MenuItem {
        id: menuItem
        property string iconSrc: ""
        property color itemBgColor: "white"
        property color itemTextColor: "black"

        implicitWidth: 120
        implicitHeight: 35
        
        HoverHandler { cursorShape: Qt.PointingHandCursor }

        background: Rectangle {
            anchors.fill: parent
            anchors.margins: 4
            radius: 16
            color: appUtils.calculateColor(menuItem.itemBgColor, menuItem.hovered, menuItem.down)
        }

        contentItem: Row {
            spacing: 10
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 15

            Item {
                width: 16; height: 16
                anchors.verticalCenter: parent.verticalCenter
                Image {
                    id: menuIcon
                    source: menuItem.iconSrc
                    sourceSize.width: 16; sourceSize.height: 16
                    anchors.fill: parent
                    visible: false 
                }
                MultiEffect {
                    source: menuIcon
                    anchors.fill: menuIcon
                    colorizationColor: menuItem.itemTextColor
                    colorization: 1.0
                    brightness: 1.0 
                }
            }

            Text {
                text: menuItem.text
                color: menuItem.itemTextColor
                font.pixelSize: 12
                font.bold: true
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    onClicked: {
        if (accountMenu.opened) {
            accountMenu.close()
        } else {
            accountMenu.open()
        }
    }

    // dropdown menu
    Menu {
        id: accountMenu
        
        x: accountArea.width - width
        y: accountArea.height + 5
        padding: 5

        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
        
        background: Rectangle {
            implicitWidth: 120
            color: "white"
            border.color: "#CCCCCC"
            border.width: 1
            radius: 10
        }

        // --- THE MENU ITEMS ---
        CustomMenuItem {
            text: "Settings"
            iconSrc: "../../../../assets/images/icons/settings-dark.svg"
            onTriggered: accountArea.settingsRequested()
        }

        CustomMenuItem {
            text: "About"
            iconSrc: "../../../../assets/images/icons/info-dark.svg"
            onTriggered: accountArea.aboutRequested()
        }

        MenuSeparator {
            contentItem: Rectangle {
                implicitWidth: 100
                implicitHeight: 2
                color: "#CCCCCC"
                radius: 2
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        CustomMenuItem {
            text: "Logout"
            iconSrc: "../../../../assets/images/icons/logout-light.svg"
            itemBgColor: appTheme.logoutButtonBgColor
            itemTextColor: "#ffffff"
            onTriggered: accountArea.logoutRequested()
        }
    }
}