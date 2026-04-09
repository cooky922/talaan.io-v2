import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../components" as Components

Components.Card {    
    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        anchors.topMargin: 10
        anchors.bottomMargin: 10
        spacing: 10

        // > option: theme selection
        RowLayout {
            Layout.fillWidth: true
            
            Components.InfoText { 
                text: "Theme color"
                textSize: 12
                textColor: appTheme.darkTextColor
                font.bold: true
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            }

            Item { Layout.fillWidth: true } // > spacer pushes colors to the right

            RowLayout {
                spacing: 10
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

                Repeater {
                    model: appTheme.allThemeColors
                    
                    Rectangle {
                        width: 20
                        height: 20
                        radius: 18
                        
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: modelData.color1 }
                            GradientStop { position: 1.0; color: modelData.color2 }
                        }
                        
                        // > highlight border if selected
                        border.width: 1
                        border.color: appTheme.themeColorIndex === index ? "#333333" : "#D1D5DB"
                        
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (appSettingsController.themeColorIndex !== index) {
                                    appSettingsController.setThemeColorIndex(index)
                                    toast.showToast(modelData.name + " theme applied successfully.", false)
                                }
                            }
                        }
                    }
                }
            }
        }

        // > separator
        Rectangle { Layout.fillWidth: true; height: 1; color: "#E5E7EB" }

        // > option: rows per page
        RowLayout {
            Layout.fillWidth: true
            
            Components.InfoText {
                text: "Number of items displayed per page"
                textSize: 12
                textColor: appTheme.darkTextColor
                font.bold: true
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            }

            Components.InfoText { 
                text: "[Valid Range: 10-100]"
                textSize: 10
                textColor: "#888888"
                font.bold: true
                Layout.alignment: Qt.AlignLeft | Qt.AlignBottom
                Layout.bottomMargin: 5
            }

            Item { Layout.fillWidth: true } // > spacer pushes text field to the right
            
            TextField {
                id: pageSizeInput
                Layout.preferredWidth: 40
                Layout.preferredHeight: 25
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                Layout.topMargin: 0
                Layout.bottomMargin: 0
                
                validator: RegularExpressionValidator { regularExpression: /^[1-9][0-9]{0,3}$/ }
                property bool isInputValid: {
                    let num = parseInt(text)
                    return pageSizeInput.acceptableInput && num >= 10 && num <= 100
                }

                text: appRecordsController.pageSize.toString()
                
                font.pixelSize: 12
                color: appTheme.darkTextColor
                horizontalAlignment: TextInput.AlignHCenter
                
                background: Rectangle {
                    radius: 6
                    color: "white"
                    border.width: 1
                    border.color: pageSizeInput.isInputValid ? "#D1D5DB" : appTheme.errorColor
                }

                onEditingFinished: {
                    if (pageSizeInput.isInputValid) {
                        let n = parseInt(text)
                        if (n !== appSettingsController.pageSize) {
                            appSettingsController.setPageSize(parseInt(text, 10))
                            toast.showToast("Pagination set to " + text + " rows per page.", false)
                        }
                        focus = false
                    } else {
                        text = appSettingsController.pageSize.toString()
                        focus = false
                    }
                }
            }
        }
    }
}
