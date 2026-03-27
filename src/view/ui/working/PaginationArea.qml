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
            return `Showing ${appDirectoryController.visibleEntries} of ${total_entries} entries`
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
        Components.InfoText {
            text: "Page " + (appDirectoryController.pageIndex + 1) + " / " + appDirectoryController.totalPages
            textSize: 12
            textColor: appTheme.darkTextColor
            anchors.verticalCenter: parent.verticalCenter
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