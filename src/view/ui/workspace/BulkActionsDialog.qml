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
    
    title: `Editing ${selectedKeys.length} ${appRecordsController.selectedEntityName} Records`

    signal requestBulkUpdate(var selectedKeys, var updates)

    property var selectedKeys: []
    property var updates: ({})
    property var activeToggles: ({}) 
    property var fieldErrors: ({}) 

    property bool hasActiveErrors: {
        for (let key in fieldErrors) {
            if (activeToggles[key] === true && fieldErrors[key] !== undefined) return true;
        }
        return false;
    }

    property var allowedBulkFields: {
        let entityName = appRecordsController.selectedEntityName
        if (entityName === "Student") 
            return ["program_code", "gender", "year"]
        if (entityName === "Program")
            return ["college_code"]
        return [] 
    }

    function openForBulk(keys) {
        selectedKeys = keys
        
        let initUpdates = {}
        if (appRecordsController.selectedEntityName === "Student") 
            initUpdates['year'] = 1
            
        updates = initUpdates
        activeToggles = ({})
        fieldErrors = ({}) 
        root.show()
    }

    // > NEW: Unified validation powered by your Python Backend
    function triggerValidation() {
        let tempErrors = {}
        
        // 1. Run the Python validation on the current updates
        // We pass "edit" mode and {} for initialData to simulate a partial update
        let result = appRecordsController.validateRecord({}, root.updates, "edit")
        
        // 2. Filter the errors so we ONLY flag fields that are currently activated
        for (let key in root.activeToggles) {
            if (root.activeToggles[key] === true) {
                // If backend found an error for this specific field, apply it
                if (result && result.errors && result.errors[key] !== undefined) {
                    tempErrors[key] = result.errors[key]
                } 
                // Fallback: Prevent completely empty strings
                else if (root.updates[key] === undefined || root.updates[key] === null || String(root.updates[key]).trim() === "") {
                    tempErrors[key] = "This field cannot be empty."
                }
            }
        }
        
        root.fieldErrors = tempErrors
    }

    function toggleField(key, isActive) {
        let tempToggles = Object.assign({}, activeToggles)
        tempToggles[key] = isActive
        activeToggles = tempToggles
        
        if (!isActive) {
            // > FIX: Actually wipe the data from memory when they click Cancel
            let tempUpdates = Object.assign({}, updates)
            if (key === "year" && appRecordsController.selectedEntityName === "Student") {
                tempUpdates[key] = 1 // Reset to default
            } else {
                delete tempUpdates[key] // Delete completely
            }
            updates = tempUpdates
        }
        
        triggerValidation() // Re-validate
    }

    function setUpdate(key, value) {
        let temp = Object.assign({}, updates)
        temp[key] = value
        updates = temp
        triggerValidation() // Re-validate on every keystroke
    }

    ColumnLayout {
        id: mainLayout
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 24
        spacing: 16

        // = MESSAGE IF BULK EDIT IS NOT ALLOWED
        Components.InfoText {
            visible: allowedBulkFields.length === 0
            text: "Bulk editing is not supported for this directory."
            textColor: appTheme.errorColor
            Layout.fillWidth: true
        }

        // = DYNAMIC BULK FORM
        ScrollView {
            visible: allowedBulkFields.length > 0
            Layout.fillWidth: true
            Layout.preferredHeight: contentFlow.implicitHeight
            clip: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ScrollBar.vertical.policy: ScrollBar.AlwaysOff

            Flow {
                id: contentFlow
                width: parent.width
                spacing: 12

                Repeater {
                    model: appRecordsController.selectedEntityTransformedModel

                    delegate: Column {
                        property string fieldKey: modelData.internal_name
                        property bool isAllowed: root.allowedBulkFields.includes(fieldKey)
                        property bool isEnabled: root.activeToggles[fieldKey] === true
                        property bool isComboField: modelData.options !== undefined
                        property bool hasError: root.fieldErrors[fieldKey] !== undefined

                        visible: isAllowed
                        
                        width: {
                            if (fieldKey === "gender" || fieldKey === "year") 
                                return (contentFlow.width / 2) - 6
                            return contentFlow.width
                        }
                        
                        spacing: 2 

                        // > Field Label & Cancel Button Row
                        Item {
                            width: parent.width
                            height: 20
                            
                            Components.InfoText {
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData.display_name
                                textSize: 11
                                textColor: isEnabled ? (hasError ? appTheme.errorColor : "#666666") : "#9CA3AF"
                                font.bold: true
                            }
                            
                            Rectangle {
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                visible: isEnabled
                                width: cancelText.implicitWidth + 12
                                height: cancelText.implicitHeight + 8
                                radius: 4
                                color: cancelMouseArea.containsMouse ? "#FEE2E2" : "transparent"

                                Text {
                                    id: cancelText
                                    anchors.centerIn: parent
                                    text: "Cancel"
                                    font.pixelSize: 11
                                    color: appTheme.errorColor
                                    font.bold: true
                                }
                                
                                MouseArea {
                                    id: cancelMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: { root.toggleField(fieldKey, false) }
                                }
                            }
                        }

                        // > Input Fields
                        Item {
                            width: parent.width
                            height: 32

                            // 0: "Keep Original" Clickable Placeholder
                            Rectangle {
                                anchors.fill: parent
                                visible: !isEnabled
                                color: placeholderHover.hovered ? "#E5E7EB" : "#F3F4F6"
                                radius: 8
                                border.color: "#E5E7EB"
                                
                                Components.InfoText { 
                                    anchors.centerIn: parent
                                    text: "Keep Original"
                                    textColor: "#9CA3AF"
                                    font.italic: true
                                }
                                
                                HoverHandler { id: placeholderHover; cursorShape: Qt.PointingHandCursor }
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: { root.toggleField(fieldKey, true) }
                                }
                            }

                            // 1: ComboBox
                            ComboBox {
                                anchors.fill: parent
                                visible: isEnabled && isComboField && fieldKey !== "year"
                                id: comboControl
                                
                                model: modelData.options !== undefined ? modelData.options : []
                                onActivated: { root.setUpdate(fieldKey, currentValue) }
                                
                                currentIndex: {
                                    let val = root.updates[fieldKey]
                                    if (val !== undefined && model) {
                                        for (let i = 0; i < count; i++) {
                                            if (textAt(i) === val) return i
                                        }
                                    }
                                    return -1
                                }

                                editable: true

                                contentItem: TextField {
                                    text: root.updates[fieldKey] !== undefined ? String(root.updates[fieldKey]) : ""
                                    font.pixelSize: 12
                                    color: appTheme.darkTextColor
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 10
                                    rightPadding: 24
                                    
                                    placeholderText: "Select " + modelData.display_name.toLowerCase()
                                    placeholderTextColor: "#6B7280"
                                    background: Item {}
                                    selectByMouse: true

                                    onReleased: (event) => { 
                                        if (!comboControl.popup.visible) comboControl.popup.open() 
                                    }
                                    onTextEdited: {
                                        root.setUpdate(fieldKey, text)
                                        if (!comboControl.popup.visible) comboControl.popup.open()
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
                                    border.color: hasError ? appTheme.errorColor : (comboControl.activeFocus ? appTheme.activeButtonBgColor : "#CCCCCC")
                                    color: comboControl.hovered ? "#EEEEEE" : "transparent"
                                }
                                
                                popup: Popup {
                                    id: popupControl
                                    width: comboControl.width
                                    padding: 4

                                    property real maxAvailableHeight: 180
                                    property bool opensUpwards: false

                                    onAboutToShow: {
                                        let absoluteY = comboControl.mapToItem(null, 0, 0).y
                                        let spaceBelow = root.height - absoluteY - comboControl.height - 8
                                        let spaceAbove = absoluteY - 8
                                        
                                        if (spaceAbove > spaceBelow) {
                                            opensUpwards = true
                                            maxAvailableHeight = spaceAbove
                                        } else {
                                            opensUpwards = false
                                            maxAvailableHeight = spaceBelow
                                        }
                                    }

                                    implicitHeight: Math.min(contentItem.implicitHeight + (padding * 2), Math.max(maxAvailableHeight, 40))
                                    y: opensUpwards ? -implicitHeight - 4 : comboControl.height + 4

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
                                        layer.effect: MultiEffect { shadowEnabled: true; shadowBlur: 10; shadowOpacity: 0.1; shadowVerticalOffset: 2 }
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

                            // 2: SpinBox
                            SpinBox {
                                anchors.fill: parent
                                visible: isEnabled && fieldKey === "year"
                                id: yearControl
                                from: 1; to: 4
                                value: root.updates[fieldKey] !== undefined ? parseInt(root.updates[fieldKey]) : 1
                                onValueModified: { root.setUpdate(fieldKey, value) }
                                editable: false
                                
                                background: Rectangle {
                                    radius: 8
                                    border.color: hasError ? appTheme.errorColor : (yearControl.activeFocus ? appTheme.activeButtonBgColor : "#CCCCCC")
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
                                        font.pixelSize: 12; font.bold: true
                                        color: yearControl.up.hovered ? appTheme.activeButtonBgColor : "#9CA3AF"
                                        anchors.centerIn: parent; anchors.verticalCenterOffset: -1
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
                                        font.pixelSize: 12; font.bold: true
                                        color: yearControl.down.hovered ? appTheme.activeButtonBgColor : "#9CA3AF"
                                        anchors.centerIn: parent; anchors.verticalCenterOffset: -1
                                    }
                                    HoverHandler { cursorShape: Qt.PointingHandCursor }
                                }
                            }

                            // 3: TextField
                            TextField {
                                anchors.fill: parent
                                visible: isEnabled && !isComboField && fieldKey !== "year"
                                
                                text: root.updates[fieldKey] !== undefined ? String(root.updates[fieldKey]) : ""
                                placeholderText: "Enter new " + modelData.display_name.toLowerCase()
                                placeholderTextColor: "#6B7280" 

                                onTextEdited: { root.setUpdate(fieldKey, text) }

                                background: Rectangle {
                                    color: parent.hovered ? "#EEEEEE" : "transparent"
                                    radius: 8
                                    border.color: hasError ? appTheme.errorColor : (parent.activeFocus ? appTheme.activeButtonBgColor : "#CCCCCC")
                                }
                                
                                color: appTheme.darkTextColor
                                font.pixelSize: 12
                                leftPadding: 10
                            }
                        }
                        
                        Text {
                            text: root.fieldErrors[fieldKey] || ""
                            visible: isEnabled && hasError
                            color: appTheme.errorColor
                            font.pixelSize: 11
                            font.bold: true
                            leftPadding: 4
                        }
                    }
                }
            }
        }

        // = ACTION BUTTONS
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            Layout.topMargin: 8

            Components.ActionButton {
                text: "Reset"
                textSize: 12 
                textColor: "#333333"
                buttonColor: "#F3F4F6"
                bordered: true
                Layout.preferredHeight: 32 
                onClicked: {
                    let initUpdates = {}
                    if (appRecordsController.selectedEntityName === "Student") 
                        initUpdates["year"] = 1
                    
                    root.updates = initUpdates
                    root.activeToggles = ({})
                    root.fieldErrors = ({}) 
                }
            }

            Item { Layout.fillWidth: true }

            Components.ActionButton {
                text: "Cancel"
                textSize: 12 
                textColor: "#333333"
                buttonColor: "#F3F4F6"
                onClicked: root.hide() 
                bordered: true
                Layout.preferredHeight: 32 
            }
            
            Components.ActionButton {
                enabled: allowedBulkFields.length > 0 && Object.values(activeToggles).includes(true) && !hasActiveErrors
                text: "Apply to All"
                textSize: 12 
                textColor: enabled ? "white" : "#9CA3AF"
                buttonColor: enabled ? appTheme.activeButtonBgColor : "#E5E7EB" 
                Layout.preferredHeight: 32 
                
                onClicked: {
                    let finalUpdates = {}
                    for (let key in root.activeToggles) {
                        if (root.activeToggles[key] === true) {
                            finalUpdates[key] = root.updates[key]
                        }
                    }
                    root.requestBulkUpdate(root.selectedKeys, finalUpdates)
                }
            }
        }
    }
}