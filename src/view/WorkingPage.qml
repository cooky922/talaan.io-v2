import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "components" as Components
import "ui/working" as WorkingUI

Rectangle {
    id: workingPage
    color: "transparent"

    property bool isEditMode: false

    // used in dialogs
    property string pendingAction: ""
    property var pendingOldData: null
    property var pendingNewData: null

    function handleEntryDialogResponse(response) {
        toast.showToast(response.message, !response.success)
        recordDialog.hide()
        // reset values
        pendingAction = ""
        pendingOldData = null
        pendingNewData = null
    }

    // main content
    ColumnLayout {
        anchors.fill: parent 
        spacing: 0

        // = Header Area
        Rectangle {
            id: workingheader
            Layout.fillWidth: true
            Layout.preferredHeight: 50 // Give the header a fixed height
            color: appTheme.headerBgColor

            // == Title (left)
            Components.TitleText {
                text: "talaan.io"
                textSize: 24

                anchors.left: parent.left
                anchors.leftMargin: 25
                anchors.verticalCenter: parent.verticalCenter
            }

            // == Directory Toggle Area (center)
            WorkingUI.DirectoryToggleArea {
                anchors.centerIn: parent
            }

            // == Account Area (right)
            WorkingUI.AccountArea {
                anchors.right: parent.right
                anchors.rightMargin: 25
                anchors.verticalCenter: parent.verticalCenter

                roleText: app.activeRole === 0 ? "Admin" : "Viewer"

                onSettingsRequested: {}
                onAboutRequested: {}
                onLogoutRequested: {
                    workingPage.isEditMode = false
                    appDirectoryController.resetOnLogout()
                    stackView.pop(StackView.Immediate)
                }
            }

            // bottom border
            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: 1
                color: "#AEBB76"
            }
        }

        // = Body Area
        Item {
            id: workingBody
            Layout.fillWidth: true
            Layout.fillHeight: true

            Components.Card {
                id: tableCard
                anchors.fill: parent
                anchors.margins: 20

                ColumnLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 20
                    anchors.rightMargin: 20
                    anchors.topMargin: 10
                    anchors.bottomMargin: 10

                    spacing: 10

                    // == Tool Area
                    RowLayout {
                        Layout.alignment: Qt.AlignTop
                        Layout.fillWidth: true
                        anchors.margins: 10
                        spacing: 10

                        // === Search Bar (search field + filter combobox)
                        WorkingUI.SearchBar {
                            Layout.preferredWidth: 440
                            Layout.preferredHeight: 30
                        }

                        // > stretch space to push buttons to the right
                        Item { Layout.fillWidth: true }

                        // === Add Button (shown only in edit mode)
                        Components.ActionButton {
                            text: "Add " + appDirectoryController.currentDirectoryName
                            textSize: 12
                            buttonColor: appTheme.activeButtonBgColor
                            iconSource: "../../../assets/images/icons/add-light.svg"
                            visible: workingPage.isEditMode
                            onClicked: {
                                recordDialog.openForAdd()
                            }

                            topPadding: 7.5
                            bottomPadding: 7.5
                        }

                        // === Edit / Done Toggle Button
                        Components.ActionButton {
                            text: workingPage.isEditMode ? "Done" : "Edit"
                            textSize: 12
                            iconSource: workingPage.isEditMode ? "../../../assets/images/icons/done-dark.svg" : "../../../assets/images/icons/edit-light.svg"
                            
                            // Change colors depending on mode
                            buttonColor: workingPage.isEditMode ? "#F3F4F6" : appTheme.activeButtonBgColor
                            textColor: workingPage.isEditMode ? appTheme.darkTextColor : "#FFFFFF"
                            bordered: workingPage.isEditMode
                            
                            onClicked: workingPage.isEditMode = !workingPage.isEditMode

                            topPadding: 7.5
                            bottomPadding: 7.5

                            visible: app.activeRole === 0
                        }
                    }

                    // == Directory Area Table                    
                    WorkingUI.DirectoryArea {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }                    

                    // == Pagination Area
                    WorkingUI.PaginationArea {
                        Layout.fillWidth: true
                    }
                }

                // = Toast Notification (unattached)
                WorkingUI.Toast {
                    id: toast
                }

                // = Confirmation Box (unattached)
                WorkingUI.MessageBox {
                    id: confirmBox

                    onAccepted: {
                        if (workingPage.pendingAction === "delete") {
                            let response = appDirectoryController.deleteRecord(workingPage.pendingOldData)
                            workingPage.handleEntryDialogResponse(response)
                        } else if (workingPage.pendingAction === "update") {
                            let response = appDirectoryController.updateRecord(workingPage.pendingOldData, workingPage.pendingNewData)
                            workingPage.handleEntryDialogResponse(response)
                        }
                    }
                }

                // = Entry Dialog (unattached)
                WorkingUI.EntryDialog {
                    id: recordDialog

                    onRequestAdd: (newData) => {
                        let response = appDirectoryController.addRecord(newData)
                        workingPage.handleEntryDialogResponse(response)
                    }

                    onRequestUpdate: (oldData, newData) => {
                        let primaryKey = appDirectoryController.getPrimaryKey()
                        if (oldData[primaryKey] != newData[primaryKey]) {
                            workingPage.pendingAction = "update"
                            workingPage.pendingOldData = oldData
                            workingPage.pendingNewData = newData

                            confirmBox.titleText = "Confirm Key Change"
                            confirmBox.messageText = "You are changing the primary key.\n\nThis will trigger cascade renames across the database.\n\nAre you sure?"
                            confirmBox.confirmButtonText = "Update"
                            confirmBox.isWarning = true
                            confirmBox.show()
                        } else {
                            let response = appDirectoryController.updateRecord(oldData, newData)
                            workingPage.handleEntryDialogResponse(response)
                        }
                    }

                    onRequestDelete: (oldData) => {
                        workingPage.pendingAction = "delete"
                        workingPage.pendingOldData = oldData

                        confirmBox.titleText = "Confirm Delete"
                        if (appDirectoryController.currentDirectoryName === "Student")
                            confirmBox.messageText = "Are you sure you want to delete this record?\n\nThis action cannot be undone.\n\nAre you sure?"
                        else 
                            confirmBox.messageText = "Are you sure you want to delete this record?\n\nThis action cannot be undone.\n\nThis might also trigger setting null across the database.\n\nAre you sure?"
                        confirmBox.confirmButtonText = "Delete"
                        confirmBox.isWarning = true
                        confirmBox.show()
                    }
                }
            }
        }
    }
}