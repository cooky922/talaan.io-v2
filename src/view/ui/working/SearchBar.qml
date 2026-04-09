import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import "../../components" as Components

Rectangle {
    id: root
    
    color: Qt.rgba(255, 255, 255, 0.15)
    radius: root.height / 2
    border.width: 1
    border.color: Qt.rgba(0, 0, 0, 0.25)
    clip: true

    function clearSearchText(removeFocus = true) {
        searchInput.clear()
        searchDebounce.stop()
        appDirectoryController.updateSearch("")
        if (removeFocus)
            searchInput.focus = false
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // > search icon at the left edge
        Item {
            Layout.preferredWidth: 35
            Layout.fillHeight: true

            Image {
                source: "../../../../assets/images/icons/search-dark.svg"
                sourceSize.width: 16
                sourceSize.height: 16
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: 5
                opacity: 0.5
            }
        }

        // > search input field
        TextField {
            id: searchInput
            Layout.fillWidth: true
            Layout.fillHeight: true

            color: "#333333"
            font.pixelSize: 12
            placeholderText: {
                let directoryName = appDirectoryController.currentDirectoryName.toLowerCase()
                return `Search ${directoryName}s...`
            }
            placeholderTextColor: color
            
            verticalAlignment: Text.AlignVCenter
            leftPadding: 5
            rightPadding: 10
            clip: true
            
            background: Item {}

            // > wait for 10ms after user stops typing
            Timer {
                id: searchDebounce
                interval: 10
                repeat: false
                onTriggered: {
                    appDirectoryController.updateSearch(searchInput.text)
                }
            }

            onTextEdited: searchDebounce.restart()
            onAccepted: {
                searchDebounce.stop()
                appDirectoryController.updateSearch(searchInput.text)
            }

            Connections {
                target: appDirectoryController
                function onSearchChanged() {
                    if (!searchInput.activeFocus) {
                        searchInput.text = appDirectoryController.searchText
                    }
                }
            }
        }

        // > clear button (only visible when there's text)
        Item {
            Layout.preferredWidth: 26
            Layout.fillHeight: true
            visible: searchInput.text.length > 0

            Image {
                source: "../../../../assets/images/icons/close-dark.svg"
                sourceSize.width: 16
                sourceSize.height: 16
                anchors.centerIn: parent
                opacity: clearMouseArea.containsMouse ? 0.8 : 0.5

                MouseArea {
                    id: clearMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    
                    onClicked: {
                        root.clearSearchText(false)
                        searchInput.forceActiveFocus() 
                    }
                }
            }
        }

        // > vertical separator line between search and filter
        Rectangle {
            Layout.preferredWidth: 1
            Layout.preferredHeight: root.height - 20
            Layout.alignment: Qt.AlignVCenter
            color: Qt.rgba(0, 0, 0, 0.3)
        }

        // > filter combobox
        ComboBox {
            id: filterBox
            Layout.preferredWidth: 140
            Layout.fillHeight: true
            hoverEnabled: true

            model: appDirectoryController.filterOptions
            currentIndex: appDirectoryController.searchFilterIndex
            onActivated: (index) => {
                appDirectoryController.setSearchFilterIndex(index)
            }

            HoverHandler { cursorShape: Qt.PointingHandCursor }
            indicator: Item {}

            Connections {
                target: appDirectoryController
                function onSearchChanged() {
                    if (!filterBox.popup.visible) {
                        filterBox.currentIndex = appDirectoryController.searchFilterIndex
                    }
                }
            }

            contentItem: RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 16
                spacing: 8

                Image {
                    source: "../../../../assets/images/icons/filter-dark.svg" 
                    sourceSize.width: 16
                    sourceSize.height: 16
                    opacity: 0.8
                    Layout.alignment: Qt.AlignVCenter
                }

                Text {
                    text: filterBox.displayText
                    font.pixelSize: 12
                    color: "#333333"
                    verticalAlignment: Text.AlignVCenter
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
            }

            background: Item {
                anchors.fill: parent
                clip: true

                Rectangle {
                    x: -root.radius 
                    y: 0
                    width: parent.width + root.radius 
                    height: parent.height
                    
                    radius: root.radius 
                    color: filterBox.hovered ? "#0D000000" : "transparent"
                }
            }

            popup: Popup {
                y: filterBox.height + 4 
                width: filterBox.width
                implicitHeight: Math.min(250, contentItem.implicitHeight + (padding * 2))
                padding: 4

                contentItem: ListView {
                    clip: true
                    implicitHeight: contentHeight
                    model: filterBox.popup.visible ? filterBox.delegateModel : null
                    currentIndex: filterBox.highlightedIndex
                    ScrollIndicator.vertical: ScrollIndicator {}
                }

                background: Rectangle {
                    color: "white"
                    border.color: "#D1D5DB"
                    border.width: 1
                    radius: 12
                    
                    layer.enabled: true
                    layer.effect: MultiEffect {
                        shadowEnabled: true; shadowBlur: 15; shadowOpacity: 0.1; shadowVerticalOffset: 4
                    }
                }
            }

            delegate: ItemDelegate {
                width: filterBox.popup.width - (filterBox.popup.padding * 2)
                height: 25
                leftPadding: 12; rightPadding: 12; topPadding: 0; bottomPadding: 0
                hoverEnabled: true

                HoverHandler { cursorShape: Qt.PointingHandCursor }

                contentItem: Text {
                    text: modelData
                    color: index == filterBox.highlightedIndex ? appTheme.activeButtonBgColor : "#333333"
                    font.bold: index === filterBox.currentIndex
                    font.pixelSize: 12
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    radius: 12
                    color: appUtils.calculateColor("white", parent.hovered, false)
                }
            }
        }
    }
}