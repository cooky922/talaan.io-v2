import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "components" as Components

ApplicationWindow {
    id: app
    width: 800
    minimumWidth: 800
    height: 500
    minimumHeight: 500

    visible: true
    title: "talaan.io - Simple Student Information System"

    // > state to track the active role (Admin = 0, Viewer = 1)
    property int activeRole : 0

    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: "LoadingPage.qml"
        replaceEnter: Transition {
            PropertyAnimation {
                property: "opacity"
                from: 0
                to: 1
                duration: 400
                easing.type: Easing.OutQuad
            }
        }
        replaceExit: Transition {
            PropertyAnimation {
                property: "opacity"
                from: 1
                to: 0
                duration: 400
                easing.type: Easing.InQuad
            }
        }
        pushEnter: Transition {
            PropertyAnimation {
                property: "opacity"
                from: 0
                to: 1
                duration: 100
                easing.type: Easing.OutQuad
            }
        }
        pushExit: Transition {
            PropertyAnimation {
                property: "opacity"
                from: 1
                to: 0
                duration: 100
                easing.type: Easing.InQuad
            }
        }
        popEnter: Transition {
            PropertyAnimation {
                property: "opacity"
                from: 0
                to: 1
                duration: 100
                easing.type: Easing.OutQuad
            }
        }
        popExit: Transition {
            PropertyAnimation {
                property: "opacity"
                from: 1
                to: 0
                duration: 100
                easing.type: Easing.InQuad
            }
        }
    }
}