import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../components" as Components

RowLayout {

    // > selection status
    Components.InfoText {
        visible: workspacePage.isEditMode
        text: {
            let selected_item_count = recordsSection.selectedKeys.length
            if (selected_item_count === 0)
                return "No items selected"
            else if (selected_item_count === 1)
                return "One item selected"
            else
                return `${selected_item_count} items selected`
        }
        textSize: 11
        textColor: "#888888"
        Layout.alignment: Qt.AlignVCenter
    }

    // > separator
    Rectangle {
        visible: workspacePage.isEditMode
        width: 1.5
        height: 15
        radius: 1
        color: "#bbbbbb"
        Layout.alignment: Qt.AlignVCenter
    }
    
    // > displays the number of records
    Components.InfoText {
        text: {
            let total_item_count = appRecordsController.totalItemCount
            if (total_item_count <= appRecordsController.pageSize) {
                if (total_item_count === 0) 
                    return "Showing zero items"
                else if (total_item_count === 1)
                    return "Showing one item"
                else
                    return `Showing all ${total_item_count} items`
            }
            let from = appRecordsController.pageIndex * appRecordsController.pageSize + 1
            let to = appRecordsController.pageIndex * appRecordsController.pageSize + appRecordsController.visibleItemCount
            return `Showing ${from}-${to} of ${total_item_count} items`
        }
        textSize: 11
        textColor: "#888888"
    }

    Item { Layout.fillWidth: true }

    // main page control
    Row {
        spacing: 5
        visible: appRecordsController.totalPages !== 1

        // > displays the page status
        Row {
            spacing: 5
            anchors.verticalCenter: parent.verticalCenter

            Components.InfoText {
                text: "Page "
                textSize: 11
                textColor: "#888888"
                anchors.verticalCenter: parent.verticalCenter
            }

            TextField {
                id: pageInput
                width: Math.max(30, contentWidth + 20)
                height: 20
                
                leftPadding: 5
                rightPadding: 5
                topPadding: 0
                bottomPadding: 0
                anchors.verticalCenter: parent.verticalCenter
                
                // > restricts input strictly to numbers between 1 and totalPages
                validator: RegularExpressionValidator { 
                    regularExpression: /^[1-9][0-9]*$/ 
                }

                // > keep text synced with the backend (if changed via next/prev buttons)
                text: (appRecordsController.pageIndex + 1).toString()
                maximumLength: appRecordsController.totalPages.toString().length
                
                font.pixelSize: 11
                font.family: appTheme.rethinkSansFontName
                color: "#888888"
                horizontalAlignment: TextInput.AlignHCenter

                property bool isInputValid: {
                    let num = parseInt(text)
                    return !isNaN(num) && num >= 1 && num <= appRecordsController.totalPages
                }

                background: Rectangle {
                    radius: 4
                    color: "white"
                    border.width: 1
                    border.color: {
                        if (!pageInput.isInputValid)
                            return appTheme.errorColor
                        else if (pageInput.activeFocus)
                            return appTheme.activeButtonBgColor
                        else
                            return "#CCCCCC"
                    }
                }

                // > change page when user hits Enter or clicks away
                onEditingFinished: {
                    if (isInputValid) {
                        appRecordsController.setPage(parseInt(text))
                        focus = false
                    } else {
                        // > if they typed something invalid and clicked away, reset to the current page
                        text = (appRecordsController.pageIndex + 1).toString()
                        focus = false
                    }
                }

                Connections {
                    target: appRecordsController
                    function onPaginationChanged() {
                        if (!pageInput.activeFocus) {
                            pageInput.text = (appRecordsController.pageIndex + 1).toString()
                        }
                    }
                }
            }

            Components.InfoText {
                text: " / " + appRecordsController.totalPages
                textSize: 11
                textColor: "#888888"
                anchors.verticalCenter: parent.verticalCenter
            }
        }
        
        Item { width: 5; height: 1 }

        // > separator
        Rectangle {
            width: 1.5
            height: 15
            radius: 1
            color: "#bbbbbb"
            anchors.verticalCenter: parent.verticalCenter
        }

        Item { width: 5; height: 1 }

        // first page button
        Components.ActionButton {
            text: "◀◀ "
            textColor: "white"
            buttonColor: enabled ? appTheme.activeButtonBgColor : "#bbbbbb"
            width: 20
            height: 20
            topPadding: 11
            enabled: appRecordsController.pageIndex > 0
            onClicked: appRecordsController.setFirstPage()
        }

        // prev button
        Components.ActionButton {
            text: "◀ "
            textColor: "white"
            buttonColor: enabled ? appTheme.activeButtonBgColor : "#bbbbbb"
            width: 20
            height: 20
            topPadding: 11
            enabled: appRecordsController.pageIndex > 0
            onClicked: appRecordsController.prevPage()
        }

        // next button
        Components.ActionButton {
            text: "▶ "
            textColor: "white"
            buttonColor: enabled ? appTheme.activeButtonBgColor : "#bbbbbb"
            width: 20
            height: 20
            topPadding: 11
            enabled: appRecordsController.pageIndex < (appRecordsController.totalPages - 1)
            onClicked: appRecordsController.nextPage()
        }

        // last page button
        Components.ActionButton {
            text: "▶▶ "
            textColor: "white"
            buttonColor: enabled ? appTheme.activeButtonBgColor : "#bbbbbb"
            width: 20
            height: 20
            topPadding: 11
            enabled: appRecordsController.pageIndex < (appRecordsController.totalPages - 1)
            onClicked: appRecordsController.setLastPage()
        }
    }
}