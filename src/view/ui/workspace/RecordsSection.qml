import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../components" as Components
import "../workspace" as WorkspaceUI

ColumnLayout {
    id: recordsSection

    property string pendingAction: ""
    property var pendingOldData: null
    property var pendingNewData: null
    property var selectedKeys: []

    spacing: 10

    // > functions
    function handleDialogResponse(response, isBulk = false) {
        toast.showToast(response.message, !response.success) 
        if (isBulk) {
            recordsSection.selectedKeys = []
            bulkActionsDialog.hide()
        } else {
            recordDialog.hide()
        }
        // reset values
        pendingAction = ""
        pendingOldData = null
        pendingNewData = null
    }

    function toggleSelection(key) {
        let temp = selectedKeys.slice()
        let idx = temp.indexOf(key)
        if (idx === -1)
            temp.push(key)
        else
            temp.splice(idx, 1)
        selectedKeys = temp
    }

    // > control zone
    RowLayout {
        Layout.fillWidth: true
        spacing: 10

        Components.ActionButton {
            visible: recordsSection.selectedKeys.length > 0
            text: "Unselect All"
            textSize: 12
            iconSource: "../../../assets/images/icons/unselect-dark.svg"
            buttonColor: appTheme.mainBgColor
            textColor: appTheme.darkTextColor
            bordered: true
            onClicked: {
                recordsSection.selectedKeys = []
            }
            topPadding: 7.5
            bottomPadding: 7.5
        }

        Components.ActionButton {
            visible: recordsSection.selectedKeys.length > 0

            property bool singleItem: recordsSection.selectedKeys.length === 1
            enabled: appRecordsController.selectedEntityName !== "College" || singleItem

            text: singleItem ? "Edit Item" : "Edit Items"
            textSize: 12
            iconSource: "../../../assets/images/icons/edit-dark.svg"
            buttonColor: appTheme.mainBgColor
            textColor: appTheme.darkTextColor
            bordered: true
            onClicked: {
                if (singleItem)
                    recordDialog.openForEdit(appRecordsController.getRecordByKey(recordsSection.selectedKeys[0]))
                else
                    bulkActionsDialog.openForBulk(recordsSection.selectedKeys)
            }
            topPadding: 7.5
            bottomPadding: 7.5
        }

        Components.ActionButton {
            visible: recordsSection.selectedKeys.length > 0
            property bool singleItem: recordsSection.selectedKeys.length === 1

            text: singleItem ? "Delete Item" : "Delete Items"
            textSize: 12
            iconSource: "../../../assets/images/icons/delete-dark.svg"
            buttonColor: appTheme.mainBgColor
            textColor: appTheme.darkTextColor
            bordered: true
            onClicked: {
                if (singleItem) {
                    recordsSection.pendingAction = "delete"
                    recordsSection.pendingOldData = appRecordsController.getRecordByKey(recordsSection.selectedKeys[0])

                    confirmBox.titleText = "Confirm Delete"
                    if (appRecordsController.selectedEntityName === "Student")
                        confirmBox.messageText = "Are you sure you want to delete this record?\n\nThis action cannot be undone.\n\nAre you sure?"
                    else 
                        confirmBox.messageText = "Are you sure you want to delete this record?\n\nThis action cannot be undone.\n\nThis might also trigger setting null across the database.\n\nAre you sure?"
                    confirmBox.confirmButtonText = "Delete"
                    confirmBox.isWarning = true
                    confirmBox.show()
                } else {
                    recordsSection.pendingAction = "bulkDelete"
                    recordsSection.pendingOldData = recordsSection.selectedKeys

                    confirmBox.titleText = "Confirm Delete"
                    if (appRecordsController.selectedEntityName === "Student")
                        confirmBox.messageText = "Are you sure you want to delete these records?\n\nThis action cannot be undone.\n\nAre you sure?"
                    else 
                        confirmBox.messageText = "Are you sure you want to delete these records?\n\nThis action cannot be undone.\n\nThis might also trigger setting null across the database.\n\nAre you sure?"
                    confirmBox.confirmButtonText = "Delete"
                    confirmBox.isWarning = true
                    confirmBox.show()
                }
            }
            topPadding: 7.5
            bottomPadding: 7.5
        }

        Item { Layout.fillWidth: true } 

        Components.ActionButton {
            visible: workspacePage.isEditMode
            text: "Add " + appRecordsController.selectedEntityName
            textSize: 12
            buttonColor: appTheme.activeButtonBgColor
            iconSource: "../../../assets/images/icons/add-light.svg"
            onClicked: recordDialog.openForAdd()
            topPadding: 7.5
            bottomPadding: 7.5
        }

        Components.ActionButton {
            visible: app.activeRole === 0
            text: workspacePage.isEditMode ? "Done" : "Edit"
            textSize: 12
            iconSource: workspacePage.isEditMode ? "../../../assets/images/icons/done-dark.svg" : "../../../assets/images/icons/edit-light.svg"
            buttonColor: workspacePage.isEditMode ? appTheme.mainBgColor : appTheme.activeButtonBgColor
            textColor: workspacePage.isEditMode ? appTheme.darkTextColor : "#FFFFFF"
            bordered: workspacePage.isEditMode
            onClicked: workspacePage.isEditMode = !workspacePage.isEditMode
            topPadding: 7.5
            bottomPadding: 7.5
        }
    }

    // > data zone
    Components.Card {
        Layout.fillWidth: true
        Layout.fillHeight: true

        ColumnLayout {
            anchors.fill: parent
            anchors.leftMargin: 20
            anchors.rightMargin: 20
            anchors.topMargin: 10
            anchors.bottomMargin: 10
            spacing: 15

            WorkspaceUI.PaginationArea {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop
                Layout.leftMargin: 7
                Layout.rightMargin: 7
                Layout.topMargin: 5
                Layout.bottomMargin: 0
            }

            WorkspaceUI.RecordTableArea {
                id: recordTableArea
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
        }
    }

    // > global UI components
    WorkspaceUI.RecordDialog {
        id: recordDialog

        onRequestAdd: (newData) => {
            let response = appRecordsController.addRecord(newData)
            recordsSection.handleDialogResponse(response)
        }

        onRequestUpdate: (oldData, newData) => {
            let primaryKey = appRecordsController.getPrimaryKey()
            if (oldData[primaryKey] != newData[primaryKey]) {
                recordsSection.pendingAction = "update"
                recordsSection.pendingOldData = oldData
                recordsSection.pendingNewData = newData

                confirmBox.titleText = "Confirm Key Change"
                confirmBox.messageText = "You are changing the primary key.\n\nThis will trigger cascade renames across the database.\n\nAre you sure?"
                confirmBox.confirmButtonText = "Update"
                confirmBox.isWarning = true
                confirmBox.show()
            } else {
                let response = appRecordsController.updateRecord(oldData, newData)
                recordsSection.handleDialogResponse(response)
            }
        }

        onRequestDelete: (oldData) => {
            recordsSection.pendingAction = "delete"
            recordsSection.pendingOldData = oldData

            confirmBox.titleText = "Confirm Delete"
            if (appRecordsController.selectedEntityName === "Student")
                confirmBox.messageText = "Are you sure you want to delete this record?\n\nThis action cannot be undone.\n\nAre you sure?"
            else 
                confirmBox.messageText = "Are you sure you want to delete this record?\n\nThis action cannot be undone.\n\nThis might also trigger setting null across the database.\n\nAre you sure?"
            confirmBox.confirmButtonText = "Delete"
            confirmBox.isWarning = true
            confirmBox.show()
        }
    }

    WorkspaceUI.BulkActionsDialog {
        id: bulkActionsDialog

        onRequestBulkUpdate: (selectedKeys, updates) => {
            let response = appRecordsController.updateRecords(selectedKeys, updates)
            recordsSection.handleDialogResponse(response, true)
        }
    }

    WorkspaceUI.MessageBox {
        id: confirmBox

        onAccepted: {
            if (recordsSection.pendingAction === "delete") {
                let response = appRecordsController.deleteRecord(recordsSection.pendingOldData)
                recordsSection.handleDialogResponse(response)
            } else if (recordsSection.pendingAction === "bulkDelete") {
                let response = appRecordsController.deleteRecords(recordsSection.pendingOldData)
                recordsSection.handleDialogResponse(response, true)
            } else if (recordsSection.pendingAction === "update") {
                let response = appRecordsController.updateRecord(recordsSection.pendingOldData, recordsSection.pendingNewData)
                recordsSection.handleDialogResponse(response)
            }
        }
    }
}