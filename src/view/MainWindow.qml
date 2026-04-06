import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "components" as Components

ApplicationWindow {
    id: app
    width: 800
    minimumWidth: 800
    height: 450
    minimumHeight: 450

    visible: true
    title: "talaan.io - Simple Student Information System"

    // > state to track the active role (Admin = 0, Viewer = 1)
    property int activeRole : 0

    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: "LoginPage.qml"
    }
}