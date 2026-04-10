import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "components" as Components
import "ui/workspace" as WorkspaceUI

Rectangle {
    id: workspacePage
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
    // options: "dashboard", "records", "history", "settings"
    property string currentSection: "dashboard"
    
    // > sidebar state
    property bool isSidebarCollapsed: false

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
                        width: workspacePage.isSidebarCollapsed ? 0 : 80
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
                            onClicked: workspacePage.isSidebarCollapsed = !workspacePage.isSidebarCollapsed
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

                        // Show SearchBar in Records Section
                        WorkspaceUI.SearchBar {
                            id: searchBar
                            visible: workspacePage.currentSection === "records"
                            Layout.preferredWidth: 440 
                            Layout.preferredHeight: 40
                            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                        }

                        // Show Dashboard Title
                        Components.TitleText { 
                            visible: workspacePage.currentSection === "dashboard"
                            text: "Dashboard"
                            textSize: 28 
                            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                        }

                        // Show History Title
                        Components.TitleText { 
                            visible: workspacePage.currentSection === "history"
                            text: "History"
                            textSize: 28 
                            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                        }

                        // Show Settings Title
                        Components.TitleText { 
                            visible: workspacePage.currentSection === "settings"
                            text: "Settings"
                            textSize: 28 
                            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                        }

                        Item { Layout.fillWidth: true }

                        WorkspaceUI.AccountArea {
                            Layout.preferredHeight: 40
                            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                            roleText: app.activeRole === 0 ? "Admin" : "Viewer"

                            onAboutRequested: {}
                            onLogoutRequested: {
                                workspacePage.isEditMode = false
                                appRecordsController.resetStates()
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
                Layout.preferredWidth: workspacePage.isSidebarCollapsed ? 0 : 80 
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
                        isActive: workspacePage.currentSection === "dashboard"
                        onClicked: {
                            searchBar.clearSearchText()
                            appRecordsController.resetStates()
                            workspacePage.currentSection = "dashboard"
                            workspacePage.isEditMode = false
                        }
                    }

                    Separator { Layout.alignment: Qt.AlignHCenter }
                    
                    // > students toggle
                    Components.ToggleButton {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Students"
                        iconSource: "../../../assets/images/icons/students-dark.svg"
                        isActive: workspacePage.currentSection === "records" && appRecordsController.selectedEntityName === "Student"
                        onClicked: { 
                            appRecordsController.reselectEntity("Student")
                            workspacePage.currentSection = "records"
                            workspacePage.isEditMode = false 
                        }
                    }

                    // > programs toggle
                    Components.ToggleButton {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Programs"
                        iconSource: "../../../assets/images/icons/programs-dark.svg"
                        isActive: workspacePage.currentSection === "records" && appRecordsController.selectedEntityName === "Program"
                        onClicked: { 
                            appRecordsController.reselectEntity("Program")
                            workspacePage.currentSection = "records"
                            workspacePage.isEditMode = false 
                        }
                    }

                    // > colleges toggle
                    Components.ToggleButton {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Colleges"
                        iconSource: "../../../assets/images/icons/colleges-dark.svg"
                        isActive: workspacePage.currentSection === "records" && appRecordsController.selectedEntityName === "College"
                        onClicked: { 
                            appRecordsController.reselectEntity("College")
                            workspacePage.currentSection = "records"
                            workspacePage.isEditMode = false 
                        }
                    }

                    Separator { Layout.alignment: Qt.AlignHCenter }

                    // > history toggle
                    Components.ToggleButton {
                        Layout.alignment: Qt.AlignHCenter
                        text: "History"
                        iconSource: "../../../assets/images/icons/history-dark.svg"
                        isActive: workspacePage.currentSection === "history"
                        onClicked: {
                            searchBar.clearSearchText()
                            appRecordsController.resetStates() 
                            workspacePage.currentSection = "history"
                            workspacePage.isEditMode = false
                        }
                    }

                    // > settings toggle
                    Components.ToggleButton {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Settings"
                        iconSource: "../../../assets/images/icons/settings-dark.svg"
                        isActive: workspacePage.currentSection === "settings"
                        onClicked: {
                            searchBar.clearSearchText()
                            appRecordsController.resetStates() 
                            workspacePage.currentSection = "settings"
                            workspacePage.isEditMode = false
                        }
                    }

                    Item { Layout.fillHeight: true }
                }
            }

            // > content panel
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                // => records section
                ColumnLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 20
                    anchors.rightMargin: 20
                    anchors.topMargin: 0
                    anchors.bottomMargin: 20
                    spacing: 0
                    visible: workspacePage.currentSection === "records"

                    WorkspaceUI.RecordsSection {
                        Layout.fillWidth: true
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
                    visible: workspacePage.currentSection === "dashboard"

                    WorkspaceUI.DashboardSection { 
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
                    visible: workspacePage.currentSection === "history"

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
                    visible: workspacePage.currentSection === "settings"

                    WorkspaceUI.SettingsSection {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 100
                    }

                    Item { Layout.fillHeight: true }             
                }
            }
        }
    }

    // > global UI components
    WorkspaceUI.Toast { id: toast }
}