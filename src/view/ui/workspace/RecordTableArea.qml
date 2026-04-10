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
                                leftPadding: (index === 0 && workspacePage.isEditMode) ? 40 : 10

                                text: model.display.toUpperCase() || ""
                                font.bold: true
                                font.pixelSize: 11
                                font.family: appTheme.rethinkSansFontName
                                color: "#59634b"
                                verticalAlignment: Text.AlignLeft
                            }

                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: -7
                                rightPadding: 10

                                Text {
                                    text: "▲"
                                    color: "#59634b"
                                    font.pixelSize: 9

                                    visible: appRecordsController.sortFieldIndex === index
                                    opacity: appRecordsController.sortAscending ? 1 : 0
                                }

                                Text {
                                    text: "▼"
                                    color: "#59634b"
                                    font.pixelSize: 9

                                    visible: appRecordsController.sortFieldIndex === index
                                    opacity: appRecordsController.sortAscending ? 0 : 1
                                }
                            }
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
                                appRecordsController.toggleSort(index)
                            }
                        }


                    }
                }

                // bottom border for header
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                    color: "#D1D5DB"
                }

                // empty state
                Components.InfoText {
                    visible: appRecordsController.totalItemCount === 0
                    Layout.alignment: Qt.AlignCenter

                    text: appRecordsController.searchText.length === 0 ? "Empty repository (╥﹏╥)" : "No results found (╥﹏╥)"
                    textSize: 42
                    textColor: "#888888"
                    font.bold: true
                    topPadding: 40
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: appRecordsController.totalItemCount === 0
                }

                // table body
                TableView {
                    id: tableView
                    visible: appRecordsController.totalItemCount > 0
                    model: appRecordTableModel
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
                        let contentWidth = appRecordTableModel.getColumnWidth(column)
                        if (column === 0 && workspacePage.isEditMode) {
                            contentWidth += 35
                        }
                        if (column === tableView.columns - 1) {
                            let usedSpace = 0
                            for (let i = 0; i < tableView.columns - 1; i++) {
                                usedSpace += appRecordTableModel.getColumnWidth(i)
                            }
                            let remainingSpace = tableView.width - usedSpace
                            return Math.max(contentWidth, remainingSpace)
                        }
                        return contentWidth
                    }

                    Connections {
                        target: workspacePage
                        function onIsEditModeChanged() {
                            // > clear selections if we exit edit mode
                            if (!workspacePage.isEditMode) {
                                recordsSection.selectedKeys = []
                            }
                            let currentProvider = tableView.columnWidthProvider
                            tableView.columnWidthProvider = null
                            tableView.columnWidthProvider = currentProvider
                            Qt.callLater(tableView.forceLayout)
                        }
                    }

                    // > force the table to recalculate the leftover space if the window resizes
                    onWidthChanged: forceLayout()

                    // > force the table to recalculate if the database data changes
                    Connections {
                        target: appRecordTableModel
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

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            preventStealing: false 
                            
                            onClicked: (mouse) => {
                                let rowData = appRecordTableModel.getRowData(row) 
                                let rowKey = rowData ? (rowData.id || rowData.program_code || rowData.college_code) : ""
                                
                                if (workspacePage.isEditMode && (mouse.modifiers & Qt.ShiftModifier)) {
                                    recordsSection.toggleSelection(rowKey)
                                } else {
                                    if (workspacePage.isEditMode)
                                        recordDialog.openForEdit(rowData)
                                    else
                                        recordDialog.openForInfo(rowData)
                                }
                            }
                        }

                        Rectangle {
                            visible: column === 0 && workspacePage.isEditMode
                            x: 0
                            y: 0
                            width: 40
                            height: parent.height
                            color: "transparent"
                            z: 2
                            opacity: 1.0
                            property var rowData: appRecordTableModel.getRowData(row)
                            property string rowKey: rowData ? (rowData.id || rowData.program_code || rowData.college_code) : ""
                            property bool isSelected: recordsSection.selectedKeys.includes(rowKey)

                            Components.ItemCheckBox {
                                anchors.centerIn: parent
                                checked: parent.isSelected
                                onClicked: { recordsSection.toggleSelection(parent.rowKey) }
                            }
                        }

                        Text {
                            anchors.fill: parent
                            anchors.margins: 10
                            leftPadding: (column === 0 && workspacePage.isEditMode) ? 30 : 0
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
    }
}