import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Window
import "../../components" as Components

Window {
    id: root
    modality: Qt.ApplicationModal
    flags: Qt.Dialog | Qt.CustomizeWindowHint | Qt.WindowTitleHint | Qt.WindowCloseButtonHint

    width: 400
    minimumWidth: width
    maximumWidth: width

    property int computedHeight: mainLayout.implicitHeight + 48

    height: computedHeight
    minimumHeight: computedHeight
    maximumHeight: computedHeight

    color: "white"

    title: {
        if (root.mode === "info") return `${appDirectoryController.currentDirectoryName} Information`
        if (root.mode === "add") return `Add New ${appDirectoryController.currentDirectoryName}`
        return `Edit ${appDirectoryController.currentDirectoryName}`
    }

    signal requestAdd(var newData)
    signal requestUpdate(var oldData, var newData)
    signal requestDelete(var oldData)

    // > state variables
    property string mode: "info" 
    property var initialData: ({}) // only used when mode == "edit"
    property var currentData: ({})
    property bool isFormValid: false
    property var formErrors: ({})
    property var touchedFields: ({})

    // > external functions
    function openForInfo(rowData) {
        mode = "info"
        currentData = rowData
        root.show() 
    }

    function openForAdd() {
        mode = "add"
        currentData = appDirectoryController.currentDirectoryName === "Student" ? ({'year' : 1}) : ({})
        initialData = ({})
        formErrors = ({})
        touchedFields = ({})
        triggerValidation() 
        root.show() 
    }

    function openForEdit(rowData) {
        mode = "edit"
        currentData = rowData
        initialData = Object.assign({}, rowData)
        formErrors = ({})
        touchedFields = ({})
        triggerValidation()
        root.show() 
    }

    // > internal functions
    function markAsTouched(key) {
        if (!root.touchedFields[key]) {
            let temp = Object.assign({}, root.touchedFields)
            temp[key] = true
            root.touchedFields = temp
            triggerValidation()
        }
    }

    function triggerValidation() {
        if (mode === "info") return;
        let result = appDirectoryController.validateForm(root.initialData, root.currentData, root.mode)
        root.isFormValid = result.isValid
        root.formErrors = result.errors
    }
    
    function updateField(key, value) {
        let directoryName = appDirectoryController.currentDirectoryName
        if (value === "None" && ((directoryName === "Student" && key === "program_code") ||
                                 (directoryName === "Program" && key === "college_code")))
            value = ""
        let temp = Object.assign({}, root.currentData)
        temp[key] = value
        root.currentData = temp
        if (!root.touchedFields[key]) {
            let temp = Object.assign({}, root.touchedFields)
            temp[key] = true
            root.touchedFields = temp
        }

        triggerValidation() 
    }

    // main layout
    ColumnLayout {
        id: mainLayout
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 24
        spacing: 12

        // = Basic Information (text header)
        Components.InfoText {
            visible: mode === "info"
            text: "Basic Information"
            textSize: 14
            textColor: "#111827"

            font.bold: true
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.preferredHeight: contentFlow.implicitHeight

            clip: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ScrollBar.vertical.policy: ScrollBar.AlwaysOff

            Flow {
                id: contentFlow
                width: parent.width
                spacing: 8
                property int rowSpacing: 10

                Repeater {
                    model: appDirectoryController.currentDirectorySchema

                    // = Individual Information Fields 
                    delegate: Column {
                        property string fieldKey: modelData.internal_name
                        property bool isTouched: root.mode === "edit" || root.touchedFields[fieldKey] === true
                        property bool hasError: fieldKey !== "year" && isTouched && root.formErrors[fieldKey] !== undefined
                        property bool isLockedEdit: root.mode === "edit" && fieldKey === "id"
                        property bool isComboField: {
                            let directoryName = appDirectoryController.currentDirectoryName
                            if (directoryName === "Student")
                                return fieldKey === "gender" || fieldKey === "program_code"
                            else if (directoryName === "Program")
                                return fieldKey === "college_code"
                            else 
                                return false
                        }
                        width: {
                            let halfWidthFields = ["first_name", "last_name", "year", "gender"]
                            return halfWidthFields.includes(fieldKey) ? (parent.width - parent.spacing) / 2 : parent.width
                        }
                        bottomPadding: parent.rowSpacing
                        spacing: 2 // > reduced gap between label and field

                        // == Field Label
                        Components.InfoText {
                            text: modelData.display_name
                            textSize: 11
                            textColor: "#555555" 
                            font.bold: true
                        }

                        // = @ Information Widget
                        Rectangle {
                            visible: root.mode === "info"
                            id: infoWidget
                            width: parent.width
                            height: Math.max(32, infoTextContent.implicitHeight + 16)
                            radius: 8
                            border.color: "#D1D5DB"
                            color: mouseArea.containsMouse ? "#EEEEEE" : "transparent"

                            Components.InfoText {
                                id: infoTextContent
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.margins: 8
                                leftPadding: 5

                                text: root.currentData[fieldKey] || "None"
                                font.pixelSize: 12 
                                color: {
                                    let textValue = root.currentData[fieldKey]
                                    if (textValue === undefined ||
                                        textValue === null || 
                                        textValue === "")
                                        return "#808080"
                                    return "#333333"
                                }

                                wrapMode: Text.Wrap
                            }

                            MouseArea {
                                id: mouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                            }
                        }

                        // = @ Editable combobox
                        ComboBox {
                            visible: root.mode !== "info" && isComboField
                            id: comboControl
                            model: modelData.options
                            width: parent.width
                            height: 32 
                            
                            editable: true
                            
                            onActivated: {
                                updateField(fieldKey, currentValue)
                            }
                            
                            contentItem: TextField {
                                text: root.currentData[fieldKey] || ""
                                font.pixelSize: 12
                                color: "#333333"
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 10
                                rightPadding: 20

                                // placeholder text
                                Text {
                                    text: "Select " + modelData.display_name.toLowerCase()
                                    color: "#bbbbbb"
                                    font.pixelSize: 12
                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.leftMargin: 10
                                    
                                    visible: parent.text === "" 
                                }
                                
                                background: Item {}

                                selectByMouse: true

                                onReleased: (event) => {
                                    if (!comboControl.popup.visible)
                                        comboControl.popup.open()
                                }

                                onTextEdited: {
                                    updateField(fieldKey, text)
                                    if (!comboControl.popup.visible)
                                        comboControl.popup.open()
                                }

                                onActiveFocusChanged: {
                                    if (!activeFocus)
                                        root.markAsTouched(fieldKey)
                                }
                            }
                            
                            indicator: Components.InfoText {
                                text: "..."
                                textSize: 16
                                textColor: appTheme.darkTextColor
                                font.bold: true
                                anchors.right: parent.right
                                anchors.rightMargin: 10
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.verticalCenterOffset: -4 
                            }
                            
                            background: Rectangle {
                                radius: 8 
                                border.color: hasError ? "#ff4c4c" : (comboControl.activeFocus ? appTheme.activeButtonBgColor : "#CCCCCC")
                                color: comboControl.hovered ? "#EEEEEE" : "transparent"
                            }
                            
                            popup: Popup {
                                y: {
                                    if (!comboControl || !comboControl.parent) 
                                        return comboControl.height + 4;
                                    let absoluteY = comboControl.mapToItem(null, 0, 0).y
                                    let spaceBelow = root.height - (absoluteY + comboControl.height)
                                    if (spaceBelow < implicitHeight)
                                        return -implicitHeight - 4
                                    return comboControl.height + 4
                                }
                                width: comboControl.width
                                implicitHeight: Math.min(180, contentItem.implicitHeight + (padding * 2))
                                padding: 4

                                contentItem: ListView {
                                    clip: true
                                    implicitHeight: contentHeight
                                    model: comboControl.popup.visible ? comboControl.delegateModel : null
                                    currentIndex: comboControl.highlightedIndex
                                    ScrollIndicator.vertical: ScrollIndicator { }
                                }

                                background: Rectangle {
                                    color: "white"
                                    border.color: "#D1D5DB"
                                    border.width: 1
                                    radius: 12
                                    layer.enabled: true
                                    layer.effect: MultiEffect {
                                        shadowEnabled: true; shadowBlur: 15
                                        shadowOpacity: 0.1; shadowVerticalOffset: 4
                                    }
                                }
                            }

                            delegate: ItemDelegate {
                                width: comboControl.popup.width - (comboControl.popup.padding * 2)
                                height: 28
                                leftPadding: 12; rightPadding: 12
                                
                                hoverEnabled: true
                                HoverHandler { cursorShape: Qt.PointingHandCursor }

                                contentItem: Text {
                                    text: modelData
                                    color: "#374151"
                                    font.pixelSize: 12
                                    verticalAlignment: Text.AlignVCenter
                                }

                                background: Rectangle {
                                    radius: 9
                                    color: parent.hovered ? "#f0f4e6" : "white" 
                                }
                            }
                        }

                        // = @ Spinbox Widget (for Year)
                        SpinBox {
                            visible: root.mode !== "info" && fieldKey === "year"
                            id: yearControl
                            width: parent.width
                            height: 32
                            from: 1
                            to: 4
                            value: root.currentData[fieldKey] ? parseInt(root.currentData[fieldKey]) : 1
                            editable: false
                            
                            onValueModified: { updateField(fieldKey, value) }

                            onActiveFocusChanged: {
                                if (!activeFocus) 
                                    root.markAsTouched(fieldKey)
                            }

                            background: Rectangle {
                                radius: 8
                                border.color: hasError ? "#ff4c4c" : (yearControl.activeFocus ? appTheme.activeButtonBgColor : "#CCCCCC")
                                color: yearControl.hovered ? "#EEEEEE" : "transparent"
                            }

                            leftPadding: 10
                            rightPadding: 26

                            contentItem: TextInput {
                                z: 2
                                text: yearControl.value
                                font.pixelSize: 12
                                color: "#333333"
                                selectionColor: appTheme.activeButtonBgColor
                                selectedTextColor: "#ffffff"
                                horizontalAlignment: Qt.AlignLeft
                                verticalAlignment: Qt.AlignVCenter
                                readOnly: true
                            }

                            up.indicator: Rectangle {
                                visible: yearControl.value < yearControl.to
                                x: yearControl.width - width - 4
                                y: (yearControl.height - 26) / 2
                                width: 20
                                height: 13
                                radius: 2
                                
                                color: yearControl.up.pressed ? appTheme.mainBgColor : (yearControl.up.hovered ? "#EEEEEE" : "transparent")

                                Text {
                                    text: "+"
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: yearControl.up.hovered ? appTheme.activeButtonBgColor : "#888888"
                                    anchors.centerIn: parent
                                    anchors.verticalCenterOffset: -1
                                }

                                HoverHandler { cursorShape: Qt.PointingHandCursor }
                            }

                            down.indicator: Rectangle {
                                visible: yearControl.value > yearControl.from
                                x: yearControl.width - width - 4
                                y: ((yearControl.height - 26) / 2) + 13
                                width: 20
                                height: 13
                                radius: 2
                                
                                color: yearControl.down.pressed ? appTheme.mainBgColor : (yearControl.down.hovered ? "#EEEEEE" : "transparent")

                                Text {
                                    text: "-"
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: yearControl.down.hovered ? appTheme.activeButtonBgColor : "#888888"
                                    anchors.centerIn: parent
                                    anchors.verticalCenterOffset: -1
                                }

                                HoverHandler { cursorShape: Qt.PointingHandCursor }
                            }
                        }

                        // = @ Text Input Widget
                        TextField {
                            visible: root.mode !== "info" && !isComboField && fieldKey !== "year"
                            width: parent.width
                            height: 32
                            text: root.currentData[fieldKey] || ""
                            
                            enabled: !isLockedEdit

                            // placeholder text
                            Text {
                                visible: parent.text === "" && !isLockedEdit
                                text: "Enter " + modelData.display_name.toLowerCase()
                                color: "#bbbbbb"
                                font.pixelSize: 12
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.leftMargin: 10
                            }
                            
                            background: Rectangle {
                                color: isLockedEdit || parent.hovered ? "#EEEEEE" : "transparent"
                                radius: 8
                                border.color: isLockedEdit ? "#CCCCCC" : (hasError ? "#ff4c4c" : (parent.activeFocus ? appTheme.activeButtonBgColor : "#CCCCCC"))
                            }
                            
                            color: isLockedEdit ? "#aaaaaa" : "#333333"
                            font.pixelSize: 12

                            onActiveFocusChanged: {
                                if (!activeFocus) root.markAsTouched(fieldKey)
                            }
                            
                            onTextEdited: { updateField(fieldKey, text) }
                        }

                        // == Field Error Label
                        Text {
                            text: root.formErrors[fieldKey] || ""
                            visible: hasError
                            color: "#ff4c4c"
                            font.pixelSize: 10
                            font.bold: true
                            leftPadding: 2
                        }
                    }
                }
            }
        }

        // = Action Buttons
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Components.ActionButton {
                visible: root.mode === "edit"
                text: "Delete"
                textColor: "white"
                textSize: 12
                buttonColor: appTheme.logoutButtonBgColor
                iconSource: "../../../assets/images/icons/delete-light.svg"
                onClicked: {
                    root.requestDelete(root.initialData)
                }

                Layout.preferredHeight: 30
            }

            Item { Layout.fillWidth: true }

            Components.ActionButton {
                visible: root.mode !== "info"
                text: "Cancel"
                textColor: "#333333"
                textSize: 12
                buttonColor: "#f0f0f0"
                onClicked: root.hide() 
                bordered: true

                Layout.preferredHeight: 30
            }
            
            Components.ActionButton {
                visible: root.mode !== "info"
                enabled: {
                    if (root.mode === "edit")
                        return root.isFormValid && !appDirectoryController.areRecordsEqual(root.initialData, root.currentData)
                    else
                        return root.isFormValid
                }
                text: root.mode === "edit" ? "Save Changes" : "Add Record"
                textColor: enabled ? "white" : "#aaaaaa"
                textSize: 12
                buttonColor: enabled ? appTheme.activeButtonBgColor : "#f0f0f0" 

                Layout.preferredHeight: 30
                
                onClicked: {
                    if (root.mode === "edit")
                        root.requestUpdate(root.initialData, root.currentData)
                    else
                        root.requestAdd(root.currentData)
                }
            }
        }
    }
}