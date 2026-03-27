import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

ComboBox {
    id: control
    
    implicitWidth: 140
    implicitHeight: 36
    hoverEnabled: true

    model: appDirectoryController.filterOptions
    currentIndex: appDirectoryController.searchFilterIndex
    onActivated: (index) => {
        appDirectoryController.setSearchFilterIndex(index)
    }

    background: Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: appUtils.calculateColor("white", control.hovered, false)
        border.color: "#D1D5DB"
        border.width: 1
    }

    HoverHandler {
        cursorShape: Qt.PointingHandCursor
    }

    indicator: Item {}

    // main content
    contentItem: RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        spacing: 8

        // filter icon at the left
        Image {
            source: "../../../../assets/images/icons/filter-dark.svg" 
            sourceSize.width: 16
            sourceSize.height: 16
            opacity: 0.8
            Layout.alignment: Qt.AlignVCenter
        }

        // the currently selected text
        Text {
            text: control.displayText
            font.pixelSize: 12
            color: "#374151" // Dark gray
            verticalAlignment: Text.AlignVCenter
            Layout.fillWidth: true
            elide: Text.ElideRight
        }
    }

    // dropdown popup
    popup: Popup {
        y: control.height + 4 
        width: control.width
        implicitHeight: Math.min(250, contentItem.implicitHeight + (padding * 2))
        padding: 4

        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: control.popup.visible ? control.delegateModel : null
            currentIndex: control.highlightedIndex
            ScrollIndicator.vertical: ScrollIndicator {}
        }

        background: Rectangle {
            color: "white"
            border.color: "#D1D5DB"
            border.width: 1
            radius: 12
            
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowBlur: 15
                shadowOpacity: 0.1
                shadowVerticalOffset: 4
            }
        }
    }

    // individual filter options
    delegate: ItemDelegate {
        width: control.popup.width - (control.popup.padding * 2)
        height: 25
        leftPadding: 12
        rightPadding: 12
        topPadding: 0
        bottomPadding: 0

        hoverEnabled: true

        HoverHandler {
            cursorShape: Qt.PointingHandCursor
        }

        contentItem: Text {
            text: modelData
            color: "#374151"
            font.pixelSize: 12
            verticalAlignment: Text.AlignVCenter
        }

        background: Rectangle {
            radius: 9
            color: appUtils.calculateColor("white", parent.hovered, false)
        }
    }
}