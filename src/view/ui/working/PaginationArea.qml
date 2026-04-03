import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../components" as Components

RowLayout {
    
    // > displays the number of entries
    Components.InfoText {
        text: {
            let total_entries = appDirectoryController.totalEntries
            if (total_entries <= appDirectoryController.pageSize) {
                if (total_entries === 0) 
                    return "Showing no entries"
                else if (total_entries === 1)
                    return "Showing one entry"
                else
                    return `Showing all ${total_entries} entries`
            }
            let from = appDirectoryController.pageIndex * appDirectoryController.pageSize + 1
            let to = appDirectoryController.pageIndex * appDirectoryController.pageSize + appDirectoryController.visibleEntries
            return `Showing ${from}-${to} of ${total_entries} entries`
        }
        textSize: 12
        textColor: appTheme.darkTextColor
    }

    Item { Layout.fillWidth: true }

    // main layout 
    Row {
        spacing: 5
        visible: appDirectoryController.totalPages !== 1

        // > displays the page status
        Row {
            spacing: 5
            anchors.verticalCenter: parent.verticalCenter

            Components.InfoText {
                text: "Page "
                textSize: 12
                textColor: appTheme.darkTextColor
                anchors.verticalCenter: parent.verticalCenter
            }

            TextField {
                id: pageInput
                width: Math.max(30, contentWidth + 20)
                height: 24
                
                leftPadding: 5
                rightPadding: 5
                anchors.verticalCenter: parent.verticalCenter
                
                // > restricts input strictly to numbers between 1 and totalPages
                validator: RegularExpressionValidator { 
                    regularExpression: /^[1-9][0-9]*$/ 
                }

                // > keep text synced with the backend (if changed via next/prev buttons)
                text: (appDirectoryController.pageIndex + 1).toString()
                maximumLength: appDirectoryController.totalPages.toString().length
                
                font.pixelSize: 12
                font.family: appTheme.rethinkSansFontName
                color: appTheme.darkTextColor
                horizontalAlignment: TextInput.AlignHCenter

                property bool isInputValid: {
                    let num = parseInt(text)
                    return !isNaN(num) && num >= 1 && num <= appDirectoryController.totalPages
                }

                background: Rectangle {
                    radius: 4
                    color: "white"
                    border.width: 1
                    border.color: pageInput.isInputValid ? "#CCCCCC" : "#ff4c4c" 
                }

                // > change page when user hits Enter or clicks away
                onEditingFinished: {
                    if (isInputValid) {
                        appDirectoryController.setPage(parseInt(text))
                        focus = false
                    } else {
                        // > if they typed something invalid and clicked away, reset to the current page
                        text = (appDirectoryController.pageIndex + 1).toString()
                        focus = false
                    }
                }

                Connections {
                    target: appDirectoryController
                    function onPaginationChanged() {
                        if (!pageInput.activeFocus) {
                            pageInput.text = (appDirectoryController.pageIndex + 1).toString()
                        }
                    }
                }
            }

            Components.InfoText {
                text: " / " + appDirectoryController.totalPages
                textSize: 12
                textColor: appTheme.darkTextColor
                anchors.verticalCenter: parent.verticalCenter
            }
        }
        
        Item { width: 10; height: 1 }

        // first page button
        Components.ActionButton {
            text: "<< "
            textColor: "white"
            buttonColor: enabled ? appTheme.activeButtonBgColor : "#bbbbbb"
            width: 20
            height: 20
            topPadding: 11
            enabled: appDirectoryController.pageIndex > 0
            onClicked: appDirectoryController.setFirstPage()
        }

        // prev button
        Components.ActionButton {
            text: "< "
            textColor: "white"
            buttonColor: enabled ? appTheme.activeButtonBgColor : "#bbbbbb"
            width: 20
            height: 20
            topPadding: 11
            enabled: appDirectoryController.pageIndex > 0
            onClicked: appDirectoryController.prevPage()
        }

        // next button
        Components.ActionButton {
            text: "> "
            textColor: "white"
            buttonColor: enabled ? appTheme.activeButtonBgColor : "#bbbbbb"
            width: 20
            height: 20
            topPadding: 11
            enabled: appDirectoryController.pageIndex < (appDirectoryController.totalPages - 1)
            onClicked: appDirectoryController.nextPage()
        }

        // last page button
        Components.ActionButton {
            text: ">> "
            textColor: "white"
            buttonColor: enabled ? appTheme.activeButtonBgColor : "#bbbbbb"
            width: 20
            height: 20
            topPadding: 11
            enabled: appDirectoryController.pageIndex < (appDirectoryController.totalPages - 1)
            onClicked: appDirectoryController.setLastPage()
        }
    }
}