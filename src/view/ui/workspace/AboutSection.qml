import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import "../../components" as Components

Components.Card {
    ColumnLayout {
        id: mainLayout
        anchors.fill: parent
        anchors.margins: 24
        spacing: 16

        // > header section
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            ColumnLayout {
                spacing: 2
                Components.TitleText {
                    text: "talaan.io"
                    textColor: appTheme.darkTextColor
                    textSize: 20
                }
                Components.InfoText {
                    text: "Version 2.0.0"
                    textColor: "#6B7280"
                    textSize: 12
                }
            }
            
            Item { Layout.fillWidth: true }
        }

        // > divider
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#EEEEEE"
            Layout.topMargin: 4
            Layout.bottomMargin: 4
        }

        // > project description
        Components.InfoText {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            lineHeight: 1.4
            text: "It is a streamlined, offline simple student information system designed for efficient academic record management. This application was developed as an individual project for the CCC151 (Information Management) course at Mindanao State University - Iligan Institute of Technology (MSU-IIT), focusing on robust data handling, seamless user interaction, and modern desktop UI principles."
            textColor: "#4B5563"
            textSize: 13
        }

        // > technology stack
        ColumnLayout {
            Layout.fillWidth: true
            Layout.topMargin: 8
            spacing: 12

            Components.InfoText {
                text: "Technology Stack"
                textColor: appTheme.darkTextColor
                font.bold: true
                textSize: 14
            }

            // >> tech stack badges
            Flow {
                Layout.fillWidth: true
                spacing: 8

                Repeater {
                    model: ["Python 3", "PyQt6", "QML", "MySQL", "Material Design"]
                    
                    Rectangle {
                        implicitWidth: chipText.implicitWidth + 24
                        implicitHeight: 28
                        radius: 14
                        color: "#F3F4F6"
                        border.color: "#E5E7EB"
                        
                        Components.InfoText {
                            id: chipText
                            anchors.centerIn: parent
                            text: modelData
                            textColor: "#374151"
                            textSize: 11
                            font.bold: true
                        }
                    }
                }
            }
        }
        
        // > developer credits
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 20
            Layout.topMargin: 8
            
            Components.InfoText {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: "Developed by Desmond Gold Bongcawel"
                textColor: "#888888"
                textSize: 11
                font.italic: true
            }
        }
    }
}