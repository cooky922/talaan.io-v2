import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "components" as Components
import "ui/working" as WorkingUI

Rectangle {
    id: workingPage
    color: "transparent"
    
    // > states 
    property bool isEditMode: false
    property string pendingAction: ""
    property var pendingOldData: null
    property var pendingNewData: null
    property string currentSection: "directory" // options: "dashboard", "directory", "history"
    
    function showToast(message, isError) {
        toast.show(message, isError)
    }

    function handleEntryDialogResponse(response) {
        toast.showToast(response.message, !response.success)
        recordDialog.hide()
        // reset values
        pendingAction = ""
        pendingOldData = null
        pendingNewData = null
    }

    // > main layout
    RowLayout {
        anchors.fill: parent
        spacing: 0

        // > sidebar panel
        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: 80
            color: Qt.rgba(246, 246, 246, 0.25)
            
            // > right border
            Rectangle {
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: 2.5
                color: Qt.rgba(0, 0, 0, 0.10)
            }

            ColumnLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.leftMargin: 6
                anchors.rightMargin: 6
                anchors.topMargin: 10
                anchors.bottomMargin: 25
                spacing: 4

                component Separator : Rectangle {
                    height: 2.5
                    width: 50
                    color: Qt.rgba(0, 0, 0, 0.10)
                    radius: 2.5
                }

                // > app logo at the top
                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.margins: 10
                    width: 50
                    height: 50
                    radius: 13

                    color: Qt.rgba(0, 0, 0, 0.15)
                    border.color: Qt.rgba(0, 0, 0, 0.3)
                    border.width: 2
                    
                    Image {
                        source: "../../assets/images/icons/app-logo.svg" // Replace with your logo icon
                        sourceSize.width: 40
                        sourceSize.height: 40
                        anchors.centerIn: parent
                    }
                }

                // > dashboard toggle
                Components.ToggleButton {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Dashboard"
                    iconSource: "../../../assets/images/icons/dashboard-dark.svg"
                    isActive: workingPage.currentSection === "dashboard"
                    onClicked: {
                        searchBar.clearSearchText()
                        appDirectoryController.resetStates()
                        workingPage.currentSection = "dashboard"
                        workingPage.isEditMode = false
                    }
                }

                Separator {
                    Layout.alignment: Qt.AlignHCenter
                }
                
                // > students toggle
                Components.ToggleButton {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Students"
                    iconSource: "../../../assets/images/icons/students-dark.svg"
                    isActive: workingPage.currentSection === "directory" && appDirectoryController.currentDirectoryName === "Student"
                    onClicked: { 
                        appDirectoryController.changeDirectory("Student")
                        workingPage.currentSection = "directory"
                        workingPage.isEditMode = false 
                    }
                }

                // > programs toggle
                Components.ToggleButton {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Programs"
                    iconSource: "../../../assets/images/icons/programs-dark.svg"
                    isActive: workingPage.currentSection === "directory" && appDirectoryController.currentDirectoryName === "Program"
                    onClicked: { 
                        appDirectoryController.changeDirectory("Program")
                        workingPage.currentSection = "directory"
                        workingPage.isEditMode = false 
                    }
                }

                // > colleges toggle
                Components.ToggleButton {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Colleges"
                    iconSource: "../../../assets/images/icons/colleges-dark.svg"
                    isActive: workingPage.currentSection === "directory" && appDirectoryController.currentDirectoryName === "College"
                    onClicked: { 
                        appDirectoryController.changeDirectory("College")
                        workingPage.currentSection = "directory"
                        workingPage.isEditMode = false 
                    }
                }

                Separator {
                    Layout.alignment: Qt.AlignHCenter
                }

                // > history toggle
                Components.ToggleButton {
                    Layout.alignment: Qt.AlignHCenter
                    text: "History"
                    iconSource: "../../../assets/images/icons/history-dark.svg"
                    isActive: workingPage.currentSection === "history"
                    onClicked: {
                        searchBar.clearSearchText()
                        appDirectoryController.resetStates() 
                        workingPage.currentSection = "history"
                        workingPage.isEditMode = false
                    }
                }

                Item { Layout.fillHeight: true }
            }
        }

        // > content panel
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            component AccountArea: WorkingUI.AccountArea {
                roleText: app.activeRole === 0 ? "Admin" : "Viewer"

                onSettingsRequested: {}
                onAboutRequested: {}
                onLogoutRequested: {
                    workingPage.isEditMode = false
                    appDirectoryController.resetStates()
                    stackView.pop(StackView.Immediate)
                }
            }

            // => directory section (default)
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 10
                visible: workingPage.currentSection === "directory"

                // === header zone
                RowLayout {
                    Layout.fillWidth: true
                    
                    WorkingUI.SearchBar {
                        id: searchBar
                        Layout.preferredWidth: 440 
                        Layout.preferredHeight: 40
                        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                    }

                    Item { Layout.fillWidth: true } // Spacer pushes account to the right

                    AccountArea {
                        Layout.preferredHeight: 40
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    }
                }

                // --- Control Zone ---
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Item { Layout.fillWidth: true } // Spacer pushes buttons to the right

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

                        // Pagination is now properly sitting above the table
                        WorkingUI.PaginationArea {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignTop
                            Layout.leftMargin: 7
                            Layout.rightMargin: 7
                            Layout.topMargin: 5
                            Layout.bottomMargin: 0
                        }

                        WorkingUI.DirectoryArea {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                        }
                    }
                }
            }

            // => dashboard section
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 10
                visible: workingPage.currentSection === "dashboard"

                RowLayout {
                    Layout.fillWidth: true
                    
                    Components.TitleText { 
                        text: "Dashboard"
                        textSize: 28 
                        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                    }

                    Item { Layout.fillWidth: true } // Spacer pushes account to the right

                    AccountArea {
                        Layout.preferredHeight: 40
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    }
                }

                Components.InfoText { 
                    text: "Dashboard content goes here..."
                    textColor: "black"
                }

                Item { 
                    Layout.fillHeight: true
                    Layout.fillWidth: true 
                }                
            }

            // => history section
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 10
                visible: workingPage.currentSection === "history"

                RowLayout {
                    Layout.fillWidth: true
                    
                    Components.TitleText { 
                        text: "History"
                        textSize: 28 
                        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                    }

                    Item { Layout.fillWidth: true }

                    AccountArea {
                        Layout.preferredHeight: 40
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    }
                }

                Components.InfoText { 
                    text: "History content goes here..."
                    textColor: "black"
                }

                Item { 
                    Layout.fillHeight: true
                    Layout.fillWidth: true 
                }                
            }
        }
    }

    // > global UI components
    WorkingUI.Toast {
        id: toast
    }

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
}