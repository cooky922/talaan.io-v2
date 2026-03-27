import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import "../../components" as Components 

Window {
    id: root
    modality: Qt.ApplicationModal
    flags: Qt.Dialog | Qt.CustomizeWindowHint | Qt.WindowTitleHint | Qt.WindowCloseButtonHint

    // > external properties
    property string titleText: "Confirm"
    property string messageText: "Are you sure you want to proceed?"
    property string confirmButtonText: "Yes"
    property string cancelButtonText: "Cancel"
    property bool isWarning: false

    signal accepted()
    signal rejected()

    title: titleText
    
    property int computedHeight: mainLayout.implicitHeight + 32

    width: 350
    height: computedHeight
    minimumWidth: width; maximumWidth: width
    minimumHeight: computedHeight; maximumHeight: computedHeight
    
    color: "white"

    // main layout
    ColumnLayout {
        id: mainLayout
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        // message
        Components.InfoText {
            text: root.messageText
            textSize: 12
            textColor: "#4B5563"
            wrapMode: Text.Wrap
            Layout.fillWidth: true
        }

        // buttons
        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 8
            spacing: 12

            // > pushes buttons to the right
            Item { Layout.fillWidth: true }

            // cancel button 
            Components.ActionButton {
                text: root.cancelButtonText
                textSize: 12
                textColor: "#333333"
                buttonColor: "#f0f0f0"
                bordered: true
                
                Layout.preferredHeight: 30
                Layout.preferredWidth: 80

                onClicked: {
                    root.rejected()
                    root.close()
                }
            }

            // confirm button
            Components.ActionButton {
                text: root.confirmButtonText
                textSize: 12
                textColor: "white"
                buttonColor: root.isWarning ? appTheme.logoutButtonBgColor : appTheme.activeButtonBgColor
                
                Layout.preferredHeight: 30
                Layout.preferredWidth: 80

                onClicked: {
                    root.accepted()
                    root.close()
                }
            }
        }
    }
}