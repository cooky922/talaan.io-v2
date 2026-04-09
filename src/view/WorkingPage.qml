import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "components" as Components
import "ui/working" as WorkingUI

Rectangle {
    id: workingPage
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        z: -1
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: appTheme.mainBgColor }
            GradientStop { position: 1.0; color: appTheme.mainBgColorLast } 
        }
    }
    
    // > states 
    property bool isEditMode: false
    property string pendingAction: ""
    property var pendingOldData: null
    property var pendingNewData: null
    // options: "dashboard", "directory", "history", "settings"
    property string currentSection: "dashboard"
    
    // > sidebar state
    property bool isSidebarCollapsed: false

    function handleEntryDialogResponse(response) {
        toast.showToast(response.message, !response.success) 
        recordDialog.hide()
        // reset values
        pendingAction = ""
        pendingOldData = null
        pendingNewData = null
    }

    // > main layout
    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // > top area is split into 2 zones:
        //   - fixed logo area
        //   - dynamic content area
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: "transparent"

            RowLayout {
                anchors.fill: parent
                spacing: 0

                // Logo
                Item {
                    Layout.preferredWidth: 80
                    Layout.fillHeight: true
                    
                    // > background that collapses with the sidebar
                    Rectangle {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: workingPage.isSidebarCollapsed ? 0 : 80
                        color: Qt.rgba(246, 246, 246, 0.25)
                        clip: true
                        
                        Behavior on width {
                            NumberAnimation { duration: 300; easing.type: Easing.InOutQuad }
                        }

                        Rectangle {
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            width: 2.5
                            color: Qt.rgba(0, 0, 0, 0.10)
                        }
                    }

                    // > clickable app logo (always visible)
                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        width: 60
                        height: 40
                        radius: 20
                        
                        color: logoMouse.containsMouse ? Qt.rgba(0, 0, 0, 0.25) : Qt.rgba(0, 0, 0, 0.15) 
                        border.color: Qt.rgba(0, 0, 0, 0.3)
                        border.width: 2
                        
                        Image {
                            source: "../../assets/images/icons/app-logo.svg" 
                            sourceSize.width: 35
                            sourceSize.height: 35
                            anchors.centerIn: parent
                        }

                        MouseArea {
                            id: logoMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: workingPage.isSidebarCollapsed = !workingPage.isSidebarCollapsed
                        }
                    }
                }

                // > top content area (search / title + account)
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 20
                        anchors.rightMargin: 20
                        spacing: 15

                        // Show SearchBar in Directory
                        WorkingUI.SearchBar {
                            id: searchBar
                            visible: workingPage.currentSection === "directory"
                            Layout.preferredWidth: 440 
                            Layout.preferredHeight: 40
                            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                        }

                        // Show Dashboard Title
                        Components.TitleText { 
                            visible: workingPage.currentSection === "dashboard"
                            text: "Dashboard"
                            textSize: 28 
                            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                        }

                        // Show History Title
                        Components.TitleText { 
                            visible: workingPage.currentSection === "history"
                            text: "History"
                            textSize: 28 
                            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                        }

                        // Show Settings Title
                        Components.TitleText { 
                            visible: workingPage.currentSection === "settings"
                            text: "Settings"
                            textSize: 28 
                            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                        }

                        Item { Layout.fillWidth: true }

                        WorkingUI.AccountArea {
                            Layout.preferredHeight: 40
                            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                            roleText: app.activeRole === 0 ? "Admin" : "Viewer"

                            onSettingsRequested: {}
                            onAboutRequested: {}
                            onLogoutRequested: {
                                workingPage.isEditMode = false
                                appDirectoryController.resetStates()
                                stackView.pop(StackView.Immediate)
                            }
                        }
                    }
                }
            }
        }

        // > main body is split into 2 zones:
        //   - collapsible sidebar for navigation between sections
        //   - content area that changes based on the selected section
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            // > sidebar panel
            Rectangle {
                Layout.fillHeight: true
                Layout.preferredWidth: workingPage.isSidebarCollapsed ? 0 : 80 
                color: Qt.rgba(246, 246, 246, 0.25)
                clip: true 
                
                // > smooth collapse animation matches the logo area
                Behavior on Layout.preferredWidth {
                    NumberAnimation { duration: 300; easing.type: Easing.InOutQuad }
                }
                
                // > right border
                Rectangle {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: 2.5
                    color: Qt.rgba(0, 0, 0, 0.10)
                }

                ColumnLayout {
                    width: 80
                    height: parent.height
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.topMargin: 10
                    anchors.bottomMargin: 25
                    spacing: 4

                    component Separator : Rectangle {
                        height: 2.5
                        width: 50
                        color: Qt.rgba(0, 0, 0, 0.10)
                        radius: 2.5
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

                    Separator { Layout.alignment: Qt.AlignHCenter }
                    
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

                    Separator { Layout.alignment: Qt.AlignHCenter }

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

                    // > settings toggle
                    Components.ToggleButton {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Settings"
                        iconSource: "../../../assets/images/icons/settings-dark.svg"
                        isActive: workingPage.currentSection === "settings"
                        onClicked: {
                            searchBar.clearSearchText()
                            appDirectoryController.resetStates() 
                            workingPage.currentSection = "settings"
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

                // => directory section (default)
                ColumnLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 20
                    anchors.rightMargin: 20
                    anchors.topMargin: 0
                    anchors.bottomMargin: 20
                    spacing: 10
                    visible: workingPage.currentSection === "directory"

                    // > control zone
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Item { Layout.fillWidth: true } 

                        Components.ActionButton {
                            text: "Add " + appDirectoryController.currentDirectoryName
                            textSize: 12
                            buttonColor: appTheme.activeButtonBgColor
                            iconSource: "../../../assets/images/icons/add-light.svg"
                            visible: workingPage.isEditMode
                            onClicked: recordDialog.openForAdd()
                            topPadding: 7.5
                            bottomPadding: 7.5
                        }

                        Components.ActionButton {
                            text: workingPage.isEditMode ? "Done" : "Edit"
                            textSize: 12
                            iconSource: workingPage.isEditMode ? "../../../assets/images/icons/done-dark.svg" : "../../../assets/images/icons/edit-light.svg"
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
                    anchors.leftMargin: 20
                    anchors.rightMargin: 20
                    anchors.topMargin: 0
                    anchors.bottomMargin: 20
                    spacing: 10
                    visible: workingPage.currentSection === "dashboard"

                    WorkingUI.DashboardSection { 
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }              
                }

                // => history section
                ColumnLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 20
                    anchors.rightMargin: 20
                    anchors.topMargin: 0
                    anchors.bottomMargin: 20
                    spacing: 10
                    visible: workingPage.currentSection === "history"

                    Components.InfoText { 
                        text: "History content goes here..."
                        textColor: "black"
                    }

                    Item { Layout.fillHeight: true; Layout.fillWidth: true }                
                }

                // => settings section
                ColumnLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 20
                    anchors.rightMargin: 20
                    anchors.topMargin: 0
                    anchors.bottomMargin: 20
                    spacing: 10
                    visible: workingPage.currentSection === "settings"

                    Components.Card {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 100
                        
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
                                                    if (appTheme.themeColorIndex !== index) {
                                                        appTheme.setThemeColor(index)
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
                                    text: "Number of entries displayed per page"
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

                                    text: appDirectoryController.pageSize.toString()
                                    
                                    font.pixelSize: 12
                                    color: appTheme.darkTextColor
                                    horizontalAlignment: TextInput.AlignHCenter
                                    
                                    background: Rectangle {
                                        radius: 6
                                        color: "white"
                                        border.width: 1
                                        border.color: pageSizeInput.isInputValid ? "#D1D5DB" : "#ff4c4c"
                                    }

                                    onEditingFinished: {
                                        if (pageSizeInput.isInputValid) {
                                            let n = parseInt(text)
                                            if (n !== appDirectoryController.pageSize) {
                                                appDirectoryController.setPageSize(parseInt(text, 10))
                                                toast.showToast("Pagination set to " + text + " rows per page.", false)
                                            }
                                            focus = false
                                        } else {
                                            text = appDirectoryController.pageSize.toString()
                                            focus = false
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Item { Layout.fillHeight: true }             
                }
            }
        }
    }

    // > global UI components
    WorkingUI.Toast { id: toast }

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