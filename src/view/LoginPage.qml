import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "components" as Components
import "ui/login" as LoginUI

Rectangle {
    id: loginPage
    color: "transparent"

    property Component preloadedWorkingPage: null

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Item {
            Layout.fillHeight: true
        }

        // = Title
        Components.TitleText {
            text: "talaan.io"
            Layout.alignment: Qt.AlignHCenter
        }

        // = Description (below Title)
        Components.InfoText {
            text: "Simple Student Information System"
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: loginPage.height * 0.075
        }

        // = Login Code (below Description)
        Components.Card {
            id: loginCard
            width: 250
            height: 275

            Layout.alignment: Qt.AlignHCenter

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 25
                spacing: 15

                // == Select a Role
                Components.TitleText {
                    text: "Select a Role"
                    textSize: 24
                    Layout.alignment: Qt.AlignHCenter
                }

                // == User Role Toggle Area
                LoginUI.UserRoleToggleArea {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                }

                // > pushes the login button to the bottom
                Item { Layout.fillHeight: true } 

                // == Login Button
                Components.ActionButton {
                    text: "Login"
                    buttonColor: appTheme.loginButtonBgColor
                    Layout.fillWidth: true

                    onClicked: stackView.push(preloadedWorkingPage, StackView.Immediate)
                }
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }

    Component.onCompleted: {
        preloadedWorkingPage = Qt.createComponent("WorkingPage.qml")
    }
}