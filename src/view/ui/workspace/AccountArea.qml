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
    
    // > User Data Properties
    property string userName: "Smart User"
    property string roleText: "Admin"

    signal logoutRequested()

    HoverHandler { cursorShape: Qt.PointingHandCursor }

    background: Rectangle {
        color: {
            if (accountArea.down) return Qt.rgba(0, 0, 0, 0.25)
            if (accountArea.hovered) return Qt.rgba(0, 0, 0, 0.2)
            return Qt.rgba(255, 255, 255, 0.15)
        }
        border.color: Qt.rgba(0, 0, 0, 0.25)
        border.width: 1
        radius: accountArea.height / 2
    }

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

    onClicked: {
        if (accountPopup.opened) {
            accountPopup.close()
        } else {
            accountPopup.open()
        }
    }

    Popup {
        id: accountPopup
        
        x: accountArea.width - width
        y: accountArea.height + 5
        
        width: 140
        padding: 10
        margins: 0
        
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        // > Popup Background & Shadow
        background: Rectangle {
            color: "white"
            radius: 12
            border.color: "#CCCCCC"
            border.width: 1

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowBlur: 15
                shadowOpacity: 0.1
                shadowVerticalOffset: 4
            }
        }

        // > Popup Content Layout
        ColumnLayout {
            anchors.fill: parent
            spacing: 4

            // >> User Identity
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 40

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 0
                    spacing: 5

                    // >> avatar circle
                    Rectangle {
                        width: 30
                        height: 30
                        radius: 15
                        color: appTheme.activeButtonBgColor 
                        
                        Components.InfoText {
                            anchors.centerIn: parent
                            text: accountArea.userName.charAt(0).toUpperCase()
                            textColor: "white"
                            font.bold: true
                            textSize: 16
                        }
                    }

                    // >> name and role text
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Components.InfoText {
                            text: accountArea.userName
                            textColor: appTheme.darkTextColor
                            font.bold: true
                            textSize: 14
                        }

                        Components.InfoText {
                            text: accountArea.roleText
                            textColor: "#888888" 
                            textSize: 11
                        }
                    }
                }
            }

            // > actions
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 28

                Components.ActionButton {
                    anchors.centerIn: parent
                    width: 120
                    
                    text: "Log Out"
                    textSize: 12
                    textColor: "white"
                    buttonColor: appTheme.logoutButtonBgColor 
                    iconSource: "../../../assets/images/icons/logout-light.svg" 
                    
                    onClicked: {
                        accountPopup.close()
                        accountArea.logoutRequested()
                    }

                    topPadding: 5
                    bottomPadding: 5
                }
            }
        }
    }
}