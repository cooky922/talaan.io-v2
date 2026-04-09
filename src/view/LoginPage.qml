import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "components" as Components
import "ui/login" as LoginUI

Rectangle {
    id: loginPage
    color: "transparent"

    Rectangle {
        id: animatedBg
        anchors.fill: parent
        z: -1

        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { id: stop1; position: 0.0; color: appTheme.mainBgColor }
            GradientStop { id: stop2; position: 1.0; color: appTheme.mainBgColorLast }
        }

        // > animation loop
        SequentialAnimation {
            running: true
            loops: Animation.Infinite

            // > transition to pink
            ParallelAnimation {
                ColorAnimation { target: stop1; property: "color"; to: "#ffbbf4"; duration: 4000; easing.type: Easing.InOutSine }
                ColorAnimation { target: stop2; property: "color"; to: "#ff81c8"; duration: 4000; easing.type: Easing.InOutSine }
            }
            
            // > transition to purple
            ParallelAnimation {
                ColorAnimation { target: stop1; property: "color"; to: "#e1b2f5"; duration: 4000; easing.type: Easing.InOutSine }
                ColorAnimation { target: stop2; property: "color"; to: "#ce5cff"; duration: 4000; easing.type: Easing.InOutSine }
            }
            
            // > transition to blue
            ParallelAnimation {
                ColorAnimation { target: stop1; property: "color"; to: "#75aaff"; duration: 4000; easing.type: Easing.InOutSine }
                ColorAnimation { target: stop2; property: "color"; to: "#4887c3"; duration: 4000; easing.type: Easing.InOutSine }
            }
            
            // > transition to yellow
            ParallelAnimation {
                ColorAnimation { target: stop1; property: "color"; to: "#fff596"; duration: 4000; easing.type: Easing.InOutSine }
                ColorAnimation { target: stop2; property: "color"; to: "#edde4e"; duration: 4000; easing.type: Easing.InOutSine }
            }

            // > transition to orange
            ParallelAnimation {
                ColorAnimation { target: stop1; property: "color"; to: "#f2bc6f"; duration: 4000; easing.type: Easing.InOutSine }
                ColorAnimation { target: stop2; property: "color"; to: "#ffa45e"; duration: 4000; easing.type: Easing.InOutSine }
            }

            // > transition back to green
            ParallelAnimation {
                ColorAnimation { target: stop1; property: "color"; to: appTheme.mainBgColor; duration: 4000; easing.type: Easing.InOutSine }
                ColorAnimation { target: stop2; property: "color"; to: appTheme.mainBgColorLast; duration: 4000; easing.type: Easing.InOutSine }
            }
        }
    }

    property var preloadedWorkingPage: null

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

        // = Login Card (below Description)
        Components.Card {
            id: loginCard
            bordered: true
            cardColor: Qt.rgba(246, 246, 246, 0.25)
            width: 250
            height: 200

            Layout.alignment: Qt.AlignHCenter

            ColumnLayout {
                id: cardLayout
                anchors.fill: parent
                anchors.leftMargin: 20
                anchors.rightMargin: 20
                anchors.topMargin: 10
                anchors.bottomMargin: 20
                spacing: 5
 
                // == User Role Toggle Area
                LoginUI.UserRoleToggleArea {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
                }

                // == Login Button
                Components.ActionButton {
                    text: {
                        if (app.activeRole === 0)
                            return "Enter as Admin"
                        else 
                            return "Enter as Viewer"
                    }
                    buttonColor: Qt.rgba(0, 0, 0, 0.50)
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignBottom | Qt.AlignHCenter

                    onClicked: stackView.push(preloadedWorkingPage, StackView.Immediate)
                }
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }

    Component.onCompleted: {
        let comp = Qt.createComponent("WorkingPage.qml")
        if (comp.status === Component.Error) {
            appUtils.printLog(`QML Error: ${comp.errorString()}`)
        }
        preloadedWorkingPage = comp.createObject(null)
    }
}