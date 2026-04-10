import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "components" as Components

Rectangle {
    id: root
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

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 24

        // > App Logo
        Image {
            Layout.alignment: Qt.AlignHCenter
            source: "../../assets/images/icons/app-logo.svg" 
            sourceSize.width: 80
            sourceSize.height: 80
            fillMode: Image.PreserveAspectFit
            
            SequentialAnimation on opacity {
                loops: Animation.Infinite
                NumberAnimation { from: 1.0; to: 0.6; duration: 1000; easing.type: Easing.InOutQuad }
                NumberAnimation { from: 0.6; to: 1.0; duration: 1000; easing.type: Easing.InOutQuad }
            }
        }

        // > App Title and Subtitle
        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 4
            
            Components.TitleText {
                Layout.alignment: Qt.AlignHCenter
                text: "talaan.io"
            }
            
            Components.InfoText {
                Layout.alignment: Qt.AlignHCenter
                text: "Simple Student Information System"
            }
        }

        BusyIndicator {
            id: indicatorControl
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 16
            width: 40
            height: 40
            running: true
            
            contentItem: Item {
                implicitWidth: 40
                implicitHeight: 40

                Item {
                    id: item
                    x: parent.width / 2 - 20
                    y: parent.height / 2 - 20
                    width: 40
                    height: 40
                    opacity: 0.8

                    RotationAnimator {
                        target: item
                        running: indicatorControl.visible && indicatorControl.running
                        from: 0
                        to: 360
                        loops: Animation.Infinite
                        duration: 1250
                    }

                    Repeater {
                        id: repeater
                        model: 6

                        Rectangle {
                            x: item.width / 2 - width / 2
                            y: item.height / 2 - height / 2
                            implicitWidth: 8
                            implicitHeight: 8
                            radius: 4
                            color: "black"
                            transform: [
                                Translate { y: -14 },
                                Rotation { angle: index / repeater.count * 360; origin.x: 4; origin.y: 14 }
                            ]
                        }
                    }
                }
            }
        }
    }

    // = 4. ROUTING LOGIC =
    Timer {
        id: loadTimer
        interval: 2000 
        running: true
        repeat: false
        onTriggered: {
            root.StackView.view.replace("LoginPage.qml")
        }
    }
}