import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../components" as Components

Rectangle {
    id: root
    
    color: "transparent"

    // main card layout
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 0
        spacing: 5

        // table area
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "transparent"
            clip: true

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // table header
                HorizontalHeaderView {
                    id: header
                    syncView: tableView
                    boundsBehavior: Flickable.StopAtBounds
                    resizableColumns: false

                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop
                    
                    delegate: Rectangle {
                        implicitHeight: 30
                        color: "transparent"
                        
                        Row {
                            spacing: 10
                            topPadding: 5
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom

                            Text {
                                leftPadding: 10

                                text: model.display.toUpperCase() || ""
                                font.bold: true
                                font.pixelSize: 11
                                color: "#4B5563"
                                verticalAlignment: Text.AlignLeft
                            }

                            Text {
                                text: appDirectoryController.sortAscending ? "▲" : "▼"
                                color: "#6B7280"
                                font.pixelSize: 8

                                rightPadding: 10
                                visible: appDirectoryController.sortFieldIndex === index
                            }
                        }

                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 1
                            color: "#D1D5DB"
                        }

                        Rectangle {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            height: 15
                            width: 2
                            color: "#D1D5DB"
                            visible: index < (tableView.columns - 1)
                        }

                        MouseArea {
                            id: headerMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            
                            onClicked: {
                                appDirectoryController.toggleSort(index)
                            }
                        }


                    }
                }

                // empty state
                Components.InfoText {
                    visible: appDirectoryController.totalEntries === 0
                    Layout.alignment: Qt.AlignCenter

                    text: appDirectoryController.searchText.length === 0 ? "Empty directory (╥﹏╥)" : "No results found (╥﹏╥)"
                    textSize: 42
                    textColor: "#888888"
                    font.bold: true
                    bottomPadding: 40
                }

                Item {
                    Layout.fillWidth: true
                    visible: appDirectoryController.totalEntries === 0
                }

                // table body
                TableView {
                    id: tableView
                    visible: appDirectoryController.totalEntries > 0
                    model: appDirectoryModel
                    clip: true
                    columnSpacing: 0
                    rowSpacing: 0
                    boundsBehavior: Flickable.StopAtBounds
                    ScrollIndicator.vertical: ScrollIndicator { }
                    ScrollIndicator.horizontal: ScrollIndicator { }

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    property int hoveredRow: -1

                    columnWidthProvider: function(column) {
                        let contentWidth = appDirectoryModel.getColumnWidth(column)
                        if (column === tableView.columns - 1) {
                            let usedSpace = 0
                            for (let i = 0; i < tableView.columns - 1; i++) {
                                usedSpace += appDirectoryModel.getColumnWidth(i)
                            }
                            let remainingSpace = tableView.width - usedSpace
                            return Math.max(contentWidth, remainingSpace)
                        }
                        return contentWidth
                    }

                    // > force the table to recalculate the leftover space if the window resizes
                    onWidthChanged: forceLayout()

                    // > force the table to recalculate if the database data changes
                    Connections {
                        target: appDirectoryModel
                        function onModelReset() {
                            tableView.contentX = 0
                            tableView.contentY = 0
                            Qt.callLater(tableView.forceLayout)
                        }
                    }

                    HoverHandler {
                        onHoveredChanged: {
                            if (!hovered)
                                tableView.hoveredRow = -1
                        }
                    }

                    delegate: Rectangle {
                        implicitHeight: 30
                        color: tableView.hoveredRow == row ? "#E5E7EB" : "white"
                        
                        HoverHandler {
                            cursorShape: Qt.PointingHandCursor
                            onHoveredChanged: {
                                if (hovered)
                                    tableView.hoveredRow = row
                            }
                        }

                        TapHandler {
                            onTapped: {
                                let rowData = appDirectoryModel.getRowData(row)
                                if (workingPage.isEditMode)
                                    recordDialog.openForEdit(rowData)
                                else
                                    recordDialog.openForInfo(rowData)
                            }
                        }

                        Text {
                            anchors.fill: parent
                            anchors.margins: 10
                            verticalAlignment: Text.AlignVCenter
                            text: {
                                if (model.display === undefined ||
                                    model.display === null ||
                                    model.display.length === 0)
                                    return "None"
                                return model.display
                            }

                            font.pixelSize: 12
                            color: {
                                if (model.display === undefined || 
                                    model.display === null || 
                                    model.display.length === 0)
                                    return "#808080"
                                return "#1F2937"
                            }
                            elide: Text.ElideRight
                        }
                    }
                }
            }
        }

        // bottom border
        Rectangle {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignBottom
            height: 1
            color: "#D1D5DB"
        }
    }
}