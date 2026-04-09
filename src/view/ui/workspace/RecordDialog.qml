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
        if (root.mode === "info") return `${appRecordsController.selectedEntityName} Information`
        if (root.mode === "add") return `Add New ${appRecordsController.selectedEntityName}`
        return `Edit ${appRecordsController.selectedEntityName}`
    }

    // > signals
    signal requestAdd(var newData)
    signal requestUpdate(var oldData, var newData)
    signal requestDelete(var oldData)

    // > state variables
    property string mode: "info" 
    property var initialData: ({})
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
        currentData = appRecordsController.selectedEntityName === "Student" ? {'year' : 1} : ({})
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
        let result = appRecordsController.validateRecord(root.initialData, root.currentData, root.mode)
        root.isFormValid = result.isValid
        root.formErrors = result.errors
    }
    
    function updateField(key, value) {
        let entityName = appRecordsController.selectedEntityName
        if (value === "None" && ((entityName === "Student" && key === "program_code") || 
                                 (entityName === "Program" && key === "college_code")))
            value = ""
            
        let temp = Object.assign({}, root.currentData)
        temp[key] = value
        root.currentData = temp
        
        if (!root.touchedFields[key]) {
            let tFields = Object.assign({}, root.touchedFields)
            tFields[key] = true
            root.touchedFields = tFields
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
            textColor: appTheme.darkTextColor
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
                    model: appRecordsController.selectedEntityTransformedModel

                    // = Individual Information Fields 
                    delegate: Column {
                        property string fieldKey: modelData.internal_name
                        property bool isTouched: root.mode === "edit" || root.touchedFields[fieldKey] === true
                        property bool hasError: fieldKey !== "year" && isTouched && root.formErrors[fieldKey] !== undefined
                        property bool isLockedEdit: root.mode === "edit" && fieldKey === "id"
                        property bool isComboField: {
                            let entityName = appRecordsController.selectedEntityName
                            if (entityName === "Student") 
                                return fieldKey === "gender" || fieldKey === "program_code"
                            else if (entityName === "Program") 
                                return fieldKey === "college_code"
                            else 
                                return false
                        }
                        
                        width: {
                            let halfWidthFields = ["first_name", "last_name", "year", "gender"]
                            return halfWidthFields.includes(fieldKey) ? (parent.width - parent.spacing) / 2 : parent.width
                        }
                        bottomPadding: parent.rowSpacing
                        spacing: 2

                        // == Field Label
                        Components.InfoText {
                            text: modelData.display_name
                            textSize: 11
                            textColor: "#666666" 
                            font.bold: true
                        }

                        // = [1] Information Widget (Read-Only)
                        Rectangle {
                            visible: root.mode === "info"
                            id: infoWidget
                            width: parent.width
                            height: Math.max(32, infoTextContent.implicitHeight + 16)
                            radius: 8
                            color: mouseArea.containsMouse ? "#EEEEEE" : "transparent"
                            border.color: "#CCCCCC"
                            border.width: 1

                            Components.InfoText {
                                id: infoTextContent
                                anchors.fill: parent
                                anchors.margins: 10
                                text: root.currentData[fieldKey] || "None"
                                font.pixelSize: 12 
                                color: {
                                    let textValue = root.currentData[fieldKey]
                                    if (textValue === undefined || textValue === null || textValue === "") 
                                        return "#888888"
                                    return appTheme.darkTextColor
                                }
                                wrapMode: Text.Wrap
                            }

                            MouseArea {
                                id: mouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                            }
                        }

                        // = [2] Editable Combobox
                        ComboBox {
                            visible: root.mode !== "info" && isComboField
                            id: comboControl
                            model: modelData.options
                            width: parent.width
                            height: 32
                            editable: true
                            
                            onActivated: { updateField(fieldKey, currentValue) }
                            
                            contentItem: TextField {
                                text: root.currentData[fieldKey] || ""
                                font.pixelSize: 12
                                color: appTheme.darkTextColor
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 10
                                rightPadding: 24
                                
                                placeholderText: "Select " + modelData.display_name.toLowerCase()
                                placeholderTextColor: "#6B7280" // > Darker placeholder text
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
                                border.color: {
                                    if (hasError)
                                        return appTheme.errorColor
                                    else if (comboControl.activeFocus)
                                        return appTheme.activeButtonBgColor
                                    else
                                        return "#CCCCCC"
                                }
                                color: comboControl.hovered ? "#EEEEEE" : "transparent"
                            }
                            
                            popup: Popup {
                                y: comboControl.height + 4
                                width: comboControl.width
                                implicitHeight: Math.min(180, contentItem.implicitHeight + (padding * 2))
                                padding: 4

                                contentItem: ListView {
                                    clip: true
                                    implicitHeight: contentHeight
                                    model: comboControl.popup.visible ? comboControl.delegateModel : null
                                    currentIndex: comboControl.highlightedIndex
                                    ScrollIndicator.vertical: ScrollIndicator {}
                                }

                                background: Rectangle {
                                    color: "white"
                                    border.color: "#CCCCCC"
                                    border.width: 1
                                    radius: 8
                                    layer.enabled: true
                                    layer.effect: MultiEffect { 
                                        shadowEnabled: true
                                        shadowBlur: 10
                                        shadowOpacity: 0.1
                                        shadowVerticalOffset: 2 
                                    }
                                }
                            }

                            delegate: ItemDelegate {
                                width: comboControl.popup.width - (comboControl.popup.padding * 2)
                                height: 30
                                leftPadding: 10; rightPadding: 10
                                hoverEnabled: true
                                HoverHandler { cursorShape: Qt.PointingHandCursor }

                                contentItem: Text {
                                    text: modelData
                                    color: parent.hovered ? appTheme.activeButtonBgColor : appTheme.darkTextColor
                                    font.pixelSize: 12
                                    font.bold: index === comboControl.currentIndex
                                    verticalAlignment: Text.AlignVCenter
                                }

                                background: Rectangle {
                                    radius: 8
                                    color: parent.hovered ? "#EEEEEE" : "transparent" 
                                }
                            }
                        }

                        // = [3] Spinbox Widget (for Year)
                        SpinBox {
                            visible: root.mode !== "info" && fieldKey === "year"
                            id: yearControl
                            width: parent.width
                            height: 32
                            from: 1
                            to: 4
                            value: {
                                if (fieldKey !== "year")
                                    return 1
                                let parsed = parseInt(root.currentData[fieldKey])
                                return isNaN(parsed) ? 1 : parsed
                            }
                            editable: false
                            
                            onValueModified: { updateField(fieldKey, value) }
                            onActiveFocusChanged: { if (!activeFocus) root.markAsTouched(fieldKey) }

                            background: Rectangle {
                                radius: 8
                                border.color: {
                                    if (hasError)
                                        return appTheme.errorColor
                                    else if (yearControl.activeFocus)
                                        return appTheme.activeButtonBgColor
                                    else
                                        return "#CCCCCC"
                                }
                                color: yearControl.hovered ? "#EEEEEE" : "transparent"
                            }

                            leftPadding: 10; rightPadding: 26

                            contentItem: TextInput {
                                z: 2
                                text: yearControl.value
                                font.pixelSize: 12
                                color: appTheme.darkTextColor
                                selectionColor: appTheme.activeButtonBgColor
                                selectedTextColor: "white"
                                horizontalAlignment: Qt.AlignLeft
                                verticalAlignment: Qt.AlignVCenter
                                readOnly: true
                            }

                            up.indicator: Rectangle {
                                visible: yearControl.value < yearControl.to
                                x: yearControl.width - width - 6
                                y: (yearControl.height - 24) / 2
                                width: 20; height: 12
                                radius: 4
                                color: yearControl.up.pressed ? "#D1D5DB" : (yearControl.up.hovered ? "#E5E7EB" : "transparent")

                                Text {
                                    text: "+"
                                    font.pixelSize: 12
                                    font.bold: true
                                    color: yearControl.up.hovered ? appTheme.activeButtonBgColor : "#9CA3AF"
                                    anchors.centerIn: parent
                                    anchors.verticalCenterOffset: -1
                                }
                                HoverHandler { cursorShape: Qt.PointingHandCursor }
                            }

                            down.indicator: Rectangle {
                                visible: yearControl.value > yearControl.from
                                x: yearControl.width - width - 6
                                y: ((yearControl.height - 24) / 2) + 12
                                width: 20; height: 12
                                radius: 4
                                color: yearControl.down.pressed ? "#D1D5DB" : (yearControl.down.hovered ? "#E5E7EB" : "transparent")

                                Text {
                                    text: "-"
                                    font.pixelSize: 12
                                    font.bold: true
                                    color: yearControl.down.hovered ? appTheme.activeButtonBgColor : "#9CA3AF"
                                    anchors.centerIn: parent
                                    anchors.verticalCenterOffset: -1
                                }
                                HoverHandler { cursorShape: Qt.PointingHandCursor }
                            }
                        }

                        // = [4] Split Student ID Widget (ADD Mode Only)
                        RowLayout {
                            id: splitIdRow
                            visible: root.mode === "add" && fieldKey === "id" && appRecordsController.selectedEntityName === "Student"
                            width: parent.width
                            height: 32
                            spacing: 6

                            function updateSplitId() {
                                updateField(fieldKey, idYearInput.text + "-" + idSuffixInput.text)
                            }

                            TextField {
                                id: idYearInput
                                Layout.preferredWidth: 135
                                Layout.fillHeight: true
                                text: fieldKey === "id" ? (String(root.currentData[fieldKey] || "").split("-")[0] || "") : ""
                                placeholderText: "YYYY"
                                placeholderTextColor: "#6B7280" // > Darker placeholder
                                font.pixelSize: 12
                                color: appTheme.darkTextColor
                                leftPadding: 10
                                background: Rectangle {
                                    color: parent.hovered ? "#EEEEEE" : "transparent"
                                    radius: 8
                                    border.color: {
                                        if (hasError)
                                            return appTheme.errorColor
                                        else if (idYearInput.activeFocus)
                                            return appTheme.activeButtonBgColor
                                        else
                                            return "#CCCCCC"
                                    }
                                }
                                onTextEdited: splitIdRow.updateSplitId()
                                onActiveFocusChanged: { 
                                    if (!activeFocus) 
                                        root.markAsTouched(fieldKey) 
                                }
                            }

                            Text {
                                text: "—"
                                font.bold: true
                                font.pixelSize: 12
                                color: "#6B7280"
                            }

                            TextField {
                                id: idSuffixInput
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                text: fieldKey === "id" ? (String(root.currentData[fieldKey] || "").split("-")[1] || "") : ""
                                placeholderText: "NNNN"
                                placeholderTextColor: "#6B7280" // > Darker placeholder
                                font.pixelSize: 12
                                color: appTheme.darkTextColor
                                leftPadding: 10
                                background: Rectangle {
                                    color: parent.hovered ? "#EEEEEE" : "transparent"
                                    radius: 8
                                    border.color: {
                                        if (hasError)
                                            return appTheme.errorColor
                                        else if (parent.activeFocus)
                                            return appTheme.activeButtonBgColor
                                        else
                                            return "#CCCCCC"
                                    }
                                }
                                onTextEdited: splitIdRow.updateSplitId() // > Calls via ID to prevent errors
                                onActiveFocusChanged: { if (!activeFocus) root.markAsTouched(fieldKey) }
                            }

                            // > Generate Random ID Button
                            Rectangle {
                                Layout.preferredWidth: 46
                                Layout.fillHeight: true
                                radius: 8
                                border.color: "#D1D5DB"
                                color: autoHover.hovered ? "#E5E7EB" : "#F3F4F6"
                                
                                Components.InfoText {
                                    anchors.centerIn: parent
                                    text: "Auto"
                                    textSize: 12
                                    font.bold: true
                                    textColor: appTheme.darkTextColor
                                }
                                
                                HoverHandler { id: autoHover; cursorShape: Qt.PointingHandCursor }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        let year = new Date().getFullYear().toString()
                                        let suffix = Math.floor(1000 + Math.random() * 9000).toString()
                                        updateField(fieldKey, year + "-" + suffix)
                                    }
                                }
                            }
                        }

                        // = [5] Text Input Widget (Default)
                        TextField {
                            visible: root.mode !== "info" && !isComboField && fieldKey !== "year" && !(root.mode === "add" && fieldKey === "id" && appRecordsController.selectedEntityName === "Student")
                            width: parent.width
                            height: 32
                            text: root.currentData[fieldKey] || ""
                            enabled: !isLockedEdit
                            
                            placeholderText: "Enter " + modelData.display_name.toLowerCase()
                            placeholderTextColor: "#6B7280" // > Darker placeholder
                            
                            background: Rectangle {
                                color: isLockedEdit || parent.hovered ? "#EEEEEE" : "transparent"
                                radius: 8
                                border.color: {
                                    if (isLockedEdit) return "#CCCCCC"
                                    else if (hasError) return appTheme.errorColor
                                    else if (parent.activeFocus) return appTheme.activeButtonBgColor
                                    else return "#CCCCCC"
                                }
                            }
                            
                            color: isLockedEdit ? "#9CA3AF" : appTheme.darkTextColor
                            font.pixelSize: 12
                            leftPadding: 10

                            onActiveFocusChanged: { 
                                if (!activeFocus) 
                                    root.markAsTouched(fieldKey) 
                            }
                            onTextEdited: { updateField(fieldKey, text) }
                        }

                        Text {
                            text: root.formErrors[fieldKey] || ""
                            visible: hasError
                            color: appTheme.errorColor
                            font.pixelSize: 11
                            font.bold: true
                            leftPadding: 4
                        }
                    }
                }
            }
        }

        // = Action Buttons
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            Layout.topMargin: 8

            Components.ActionButton {
                visible: root.mode === "edit"
                text: "Delete"
                textColor: "white"
                textSize: 12
                buttonColor: appTheme.logoutButtonBgColor
                iconSource: "../../../assets/images/icons/delete-light.svg"
                onClicked: { root.requestDelete(root.initialData) }
                Layout.preferredHeight: 32
            }

            // > Reset Button
            Components.ActionButton {
                visible: root.mode !== "info"
                text: "Reset"
                textSize: 12
                buttonColor: enabled ? "#F3F4F6" : "#E5E7EB" 
                textColor: enabled ? "#333333" : "#9CA3AF"
                bordered: true
                enabled: {
                    if (root.mode === "edit")
                        return !appRecordsController.areRecordsEqual(root.initialData, root.currentData)
                    else if (appRecordsController.selectedEntityName === "Student" && root.mode === "add")
                        return root.currentData && (Object.keys(root.currentData).length > 1 || parseInt(root.currentData.year) !== 1)
                    else
                        return root.currentData && Object.keys(root.currentData).length > 0  
                }
                onClicked: {
                    if (root.mode === "add") {
                        root.currentData = appRecordsController.selectedEntityName === "Student" ? {"year" : 1} : ({})
                    } else if (root.mode === "edit") {
                        root.currentData = Object.assign({}, root.initialData)
                    }
                    root.formErrors = ({})
                    root.touchedFields = ({})
                    root.triggerValidation()
                }
                Layout.preferredHeight: 32
            }

            Item { Layout.fillWidth: true }

            Components.ActionButton {
                visible: root.mode !== "info"
                text: "Cancel"
                textColor: "#333333"
                textSize: 12
                buttonColor: "#F3F4F6"
                onClicked: root.hide() 
                bordered: true
                Layout.preferredHeight: 32
            }
            
            Components.ActionButton {
                visible: root.mode !== "info"
                enabled: {
                    if (root.mode === "edit")
                        return root.isFormValid && !appRecordsController.areRecordsEqual(root.initialData, root.currentData)
                    else return root.isFormValid
                }
                text: root.mode === "edit" ? "Save Changes" : "Add Record"
                textColor: enabled ? "white" : "#9CA3AF"
                textSize: 12
                buttonColor: enabled ? appTheme.activeButtonBgColor : "#E5E7EB" 
                Layout.preferredHeight: 32
                
                onClicked: {
                    if (root.mode === "edit") root.requestUpdate(root.initialData, root.currentData)
                    else root.requestAdd(root.currentData)
                }
            }
        }
    }
}