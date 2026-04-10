import QtQuick
import QtQuick.Controls

CheckBox {
    id: control
    
    // > parameters
    property color checkedColor: appTheme.activeButtonBgColor
    property color uncheckedBorderColor: "#BBBBBB"
    property color hoveredBorderColor: "#888888"
    
    spacing: 8
    font.pixelSize: 11

    // > checkbox box
    indicator: Rectangle {
        implicitWidth: 16
        implicitHeight: 16
        x: control.leftPadding
        y: parent.height / 2 - height / 2
        
        radius: 4
        
        border.width: control.checked ? 0 : 2
        border.color: {
            if (control.checked)
                return control.checkedColor
            else if (control.hovered)
                return control.hoveredBorderColor
            else 
                return control.uncheckedBorderColor
        }
     
        // > fill color
        color: control.checked ? control.checkedColor : "transparent"
        
        Behavior on color { ColorAnimation { duration: 100 } }

        // > checkmark icon
        Image {
            anchors.centerIn: parent
            sourceSize.width: 12
            sourceSize.height: 12
            source: "../../../assets/images/icons/check-light.svg" 
            visible: control.checked
            
            scale: control.checked ? 1.0 : 0.0
            Behavior on scale { 
                NumberAnimation { 
                    duration: 150
                    easing.type: Easing.OutBack
                } 
            }
        }
    }

    // > label
    contentItem: Text {
        visible: control.text.length > 0
        text: control.text
        font: control.font
        color: appTheme.darkTextColor
        verticalAlignment: Text.AlignVCenter
        leftPadding: control.indicator.width + control.spacing
    }
}