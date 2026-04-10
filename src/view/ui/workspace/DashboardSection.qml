import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtCharts
import "../../components" as Components

ScrollView {
    id: root
    clip: true
    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff 
    ScrollBar.vertical.policy: ScrollBar.AsNeeded

    onVisibleChanged: {
        if (visible) {
            appDashboardController.refreshData() 
        }
    }

    function getCategoryColor(categoryType, labelText, index) {
        let text = labelText.toString().toUpperCase().trim();
        
        // > 0: GENDER
        if (categoryType === 0) { 
            if (text === "MALE" || text === "M") return "#3B82F6";    
            if (text === "FEMALE" || text === "F") return "#EC4899";  
            return "#9CA3AF";                                         
        } 
        // > 1: YEAR LEVEL
        else if (categoryType === 1) { 
            if (text.includes("1")) return "#3B82F6"; 
            if (text.includes("2")) return "#A855F7"; 
            if (text.includes("3")) return "#EF4444"; 
            if (text.includes("4")) return "#EAB308"; 
            if (text.includes("5")) return "#F97316"; 
            return "#14B8A6"; 
        } 
        // > 2: COLLEGE
        else { 
            if (text === "CCS") return "#14B8A6";  
            if (text === "CED") return "#1E3A8A";  
            if (text === "CSM") return "#7E22CE";  
            if (text === "COE") return "#991B1B";  
            if (text === "CEBA") return "#EAB308"; 
            if (text === "CHS") return "#38BDF8";  
            if (text === "CASS") return "#16A34A"; 
            
            let fallbackColors = ["#F43F5E", "#8B5CF6", "#D946EF", "#F97316", "#0EA5E9", "#10B981"];
            return fallbackColors[index % fallbackColors.length];
        }
    }

    // > INLINE COMPONENTS
    // >> Dashboard ComboBox
    component DashboardComboBox : ComboBox {
        id: control
        property int choiceWidth: 140

        Layout.preferredHeight: 28
        hoverEnabled: true

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: control.popup.visible = !control.popup.visible
        }
        
        indicator: Components.InfoText {
            text: "..."
            textSize: 16
            textColor: appTheme.darkTextColor
            font.bold: true
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -4 
        }
        
        delegate: ItemDelegate {
            width: control.choiceWidth - 10
            height: 25
            contentItem: Components.InfoText {
                text: modelData
                textColor: control.highlightedIndex === index ? appTheme.activeButtonBgColor : appTheme.darkTextColor
                textSize: 12 
                font.bold: control.currentIndex === index
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                leftPadding: 2
                rightPadding: 2
            }
            background: Rectangle {
                color: control.highlightedIndex === index ? "#E5E7EB" : "transparent"
                radius: 16
            }
        }

        contentItem: Components.InfoText {
            text: control.displayText
            textSize: 12
            textColor: appTheme.darkTextColor
            font.bold: true
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            leftPadding: 12
            elide: Text.ElideRight
        }

        background: Rectangle {
            implicitWidth: control.choiceWidth
            implicitHeight: 20
            border.color: control.popup.visible ? appTheme.activeButtonBgColor : "#D1D5DB"
            border.width: control.popup.visible ? 2 : 1
            radius: 14 
            color: control.hovered && !control.popup.visible ? "#F3F4F6" : "white"
        }

        popup: Popup {
            y: control.height + 4
            width: control.width
            implicitHeight: contentItem.implicitHeight + 8
            padding: 4

            contentItem: ListView {
                clip: true
                implicitHeight: contentHeight
                model: control.popup.visible ? control.delegateModel : null
                currentIndex: control.highlightedIndex
            }

            background: Rectangle {
                border.color: "#E5E7EB"
                radius: 14
                color: "white"
                Rectangle {
                    z: -1; anchors.fill: parent; anchors.margins: -1; anchors.topMargin: 2
                    color: Qt.rgba(0,0,0,0.05); radius: 14
                }
            }
        }
    }

    // >> Explore Button
    component ExploreButton : Rectangle {
        id: btn
        property string text: "Button"
        property string icon: ""
        
        Layout.fillWidth: true
        Layout.preferredHeight: 28
        color: hover.hovered ? "#EEEEEE" : "transparent"
        radius: 8
        
        HoverHandler { id: hover }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (btn.text === "About") workspacePage.currentSection = "about"
                else if (btn.text === "Settings") workspacePage.currentSection = "settings"
            }
        }
        
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            spacing: 10
            
            Image { 
                source: btn.icon
                sourceSize.width: 16
                sourceSize.height: 16
                opacity: 0.7
            }
            Components.InfoText {
                text: btn.text
                font.bold: true
                textColor: "#333333"
            }
            Item { Layout.fillWidth: true }
        }
    }

    // >> Custom Legend Row (For Demographics)
    component LegendRowItem : RowLayout {
        property string labelText: ""
        property int valueCount: 0
        property string percentage: "0%"
        property color markerColor: "transparent"

        Layout.fillWidth: true
        Layout.preferredHeight: 20
        
        Rectangle {
            width: 14; height: 14; radius: 4
            color: markerColor
        }
        
        Components.InfoText { 
            text: labelText
            textSize: 12
            textColor: appTheme.darkTextColor
            font.bold: true
            Layout.leftMargin: 5
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredHeight: 1
            Layout.leftMargin: 8; Layout.rightMargin: 8
            color: "#E5E7EB"
        }

        Components.InfoText { 
            text: valueCount + " (" + percentage + ")"
            textSize: 12
            textColor: appTheme.darkTextColor
        }
    }

    // >> Custom Ranking Row (For Program Rankings)
    component RankingRowItem : RowLayout {
        property int rankIndex: 0
        property string labelText: ""
        property int valueCount: 0

        Layout.fillWidth: true
        Layout.preferredHeight: 25
        
        Components.InfoText {
            text: {
                let rankNum = rankIndex + 1
                return rankNum === 10 ? "10" : `0${rankNum}`
            }
            textSize: 12
            textColor: "#AAAAAA"
            horizontalAlignment: Text.AlignLeft
            Layout.preferredWidth: 20
        }
        
        Components.InfoText { 
            text: labelText
            textSize: 12
            textColor: appTheme.darkTextColor
            font.bold: true
            Layout.leftMargin: 10
        }
        
        Rectangle {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            height: 1
            color: "#E5E7EB"
            Layout.leftMargin: 8; Layout.rightMargin: 8
        }
        
        Components.InfoText {
            text: valueCount.toString()
            textSize: 12
            textColor: appTheme.darkTextColor
        }
    }

    // > MAIN DASHBOARD LAYOUT
    GridLayout {
        id: dashboardGrid
        columns: 12
        columnSpacing: 15
        rowSpacing: 15
        width: root.availableWidth - 20
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: 10

        // > ROW 1: WELCOME CARD & ADMIN NOTICE
        RowLayout {
            Layout.columnSpan: 12
            Layout.fillWidth: true
            Layout.preferredHeight: 100
            spacing: 15

            // > Welcome Card
            Components.Card {
                id: welcomeCard
                Layout.preferredWidth: app.activeRole === 0 ? 450 : -1
                Layout.fillWidth: app.activeRole !== 0
                Layout.fillHeight: true
                cardColor: appTheme.mainBgColor
                bordered: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 2
                    
                    Components.TitleText { 
                        text: "Hello " + (app.activeRole === 0 ? "Admin" : "Viewer") + "!"
                        textSize: 24 
                    }
                    Components.InfoText {
                        text: app.activeRole === 0 ? "You have full administrative access to academic records." : "You are currently exploring the database in read-only mode."
                        textColor: "#333333"
                        wrapMode: Text.Wrap
                    }
                    Item { Layout.fillHeight: true }
                }
            }

            // > Admin Notice Card
            Components.Card {
                id: adminCard
                visible: app.activeRole === 0
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true 
                cardColor: appTheme.mainBgColor
                bordered: true
                
                property bool hasWarning: appDashboardController.nullProgramStudents > 0 || appDashboardController.nullCollegePrograms > 0

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 5
                    
                    Components.InfoText { 
                        text: "ADMIN NOTICE" 
                        textSize: 13
                        textColor: "#333333"
                        font.bold: true
                    }
                    
                    Item { Layout.fillHeight: true }

                    RowLayout {
                        visible: !adminCard.hasWarning
                        Layout.alignment: Qt.AlignLeft
                        Image { source: "../../../../assets/images/icons/done-dark.svg"; sourceSize.width: 18; sourceSize.height: 18 }
                        Components.InfoText { 
                            text: "System operates normally."
                            textColor: "#333333"; textSize: 12
                        }
                    }

                    ColumnLayout {
                        visible: adminCard.hasWarning
                        Layout.fillWidth: true
                        spacing: 4

                        RowLayout {
                            visible: appDashboardController.nullProgramStudents > 0
                            Layout.fillWidth: true; spacing: 6
                            Image { source: "../../../../assets/images/icons/info-dark.svg"; sourceSize.width: 14; sourceSize.height: 14; opacity: 0.8 }
                            Components.InfoText { 
                                text: appDashboardController.nullProgramStudents + " unassigned students"
                                textColor: "#333333"; textSize: 12; Layout.fillWidth: true; elide: Text.ElideRight
                            }
                        }

                        RowLayout {
                            visible: appDashboardController.nullCollegePrograms > 0
                            Layout.fillWidth: true; spacing: 6
                            Image { source: "../../../../assets/images/icons/info-dark.svg"; sourceSize.width: 14; sourceSize.height: 14; opacity: 0.8 }
                            Components.InfoText { 
                                text: appDashboardController.nullCollegePrograms + " orphaned programs"
                                textColor: "#333333"; textSize: 12; Layout.fillWidth: true; elide: Text.ElideRight
                            }
                        }
                    }
                    Item { Layout.fillHeight: true }
                }
            }
        }

        // > ROW 2: FIXED STATS & EXPLORE
        RowLayout {
            Layout.columnSpan: 12
            Layout.fillWidth: true
            Layout.preferredHeight: 110
            spacing: 15

            component ItemCountCard : Components.Card {
                cardColor: mouseArea.containsMouse ? appTheme.activeButtonBorderColor : appTheme.activeButtonBgColor
                property string entityName: "Student"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 1

                    Components.TitleText {
                        text: {
                            let totalCount = 0
                            if (entityName === "Student") totalCount = appDashboardController.totalStudents
                            else if (entityName === "Program") totalCount = appDashboardController.totalPrograms
                            else if (entityName === "College") totalCount = appDashboardController.totalColleges
                            return totalCount.toString()
                        }
                        textSize: 32; textColor: "white"
                    }
                    Components.InfoText { 
                        text: `${entityName.toUpperCase()}S`
                        textSize: 13; textColor: "white"; font.bold: true
                    }
                    Item { Layout.fillHeight: true }
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        appRecordsController.reselectEntity(entityName)
                        workspacePage.currentSection = "records"
                    }
                }
            }

            ItemCountCard { 
                Layout.preferredWidth: 140
                Layout.fillHeight: true
                entityName: "Student" 
            }

            ItemCountCard { 
                Layout.preferredWidth: 140
                Layout.fillHeight: true
                entityName: "Program" 
            }

            ItemCountCard { 
                Layout.preferredWidth: 140
                Layout.fillHeight: true
                entityName: "College" 
            }

            // > Explore Card
            Components.Card {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true 

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 5
                    
                    Components.InfoText { 
                        text: "EXPLORE"
                        textSize: 13; textColor: appTheme.activeButtonBorderColor
                        font.bold: true
                    }
                    
                    Item { Layout.fillHeight: true }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        
                        ExploreButton { 
                            text: "About"
                            icon: "../../../../assets/images/icons/info-dark.svg" 
                        }
                        ExploreButton { 
                            text: "Settings"
                            icon: "../../../../assets/images/icons/settings-dark.svg" 
                        }
                    }
                }
            }
        }

        // > ROW 3: INTERACTIVE VISUALIZATIONS
        RowLayout {
            Layout.columnSpan: 12
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop
            spacing: 15

            // >> Demographics Card
            Components.Card {
                Layout.preferredWidth: 320 
                Layout.maximumWidth: 320   
                Layout.fillWidth: false    
                Layout.alignment: Qt.AlignTop
                Layout.preferredHeight: demoLayout.implicitHeight + 40
                clip: true 
                
                ColumnLayout {
                    id: demoLayout
                    anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
                    anchors.margins: 20
                    spacing: 15 

                    // >>> Header
                    RowLayout {
                        Layout.fillWidth: true
                        Components.InfoText { text: "STUDENT DISTRIBUTION"; textSize: 13; textColor: appTheme.activeButtonBorderColor; font.bold: true }
                        Item { Layout.fillWidth: true }
                        DashboardComboBox { id: demoCombo; model: ["Gender", "Year Level", "College"]; choiceWidth: 100 }
                    }

                    // >>> Chart Area
                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 280 

                        HoverHandler { id: chartHover }

                        StackLayout {
                            anchors.fill: parent
                            currentIndex: demoCombo.currentIndex

                            Item {
                                ChartView {
                                    width: parent.width * 2; height: parent.height * 2; scale: 0.5; transformOrigin: Item.TopLeft
                                    legend.visible: false; backgroundColor: "transparent"; margins.top: 0; margins.bottom: 0; margins.left: 0; margins.right: 0
                                    PieSeries { id: genderSeries; holeSize: 0.4; size: 0.6 } 
                                }
                            }
                            ChartView {
                                legend.visible: false; backgroundColor: "transparent"; margins.top: 0; margins.bottom: 0; margins.left: 0; margins.right: 0
                                PieSeries { id: yearSeries; holeSize: 0.4; size: 0.6 }
                            }
                            ChartView {
                                legend.visible: false; backgroundColor: "transparent"; margins.top: 0; margins.bottom: 0; margins.left: 0; margins.right: 0
                                PieSeries { id: collegeSeries; size: 0.6 } 
                            }
                        }

                        // >>>> Floating Tooltip
                        Rectangle {
                            id: customTooltip
                            visible: false
                            color: "#333333"
                            radius: 16
                            z: 100
                            x: Math.min(chartHover.point.position.x + 15, parent.width - width - 5)
                            y: Math.min(chartHover.point.position.y + 15, parent.height - height - 5)
                            width: tooltipText.implicitWidth + 20; height: tooltipText.implicitHeight + 12
                            
                            property string tipLabel: ""
                            property string tipValue: ""
                            
                            Text {
                                id: tooltipText
                                anchors.centerIn: parent
                                text: customTooltip.tipLabel + ": " + customTooltip.tipValue
                                color: "white"; font.pixelSize: 12; font.bold: true
                            }
                        }
                    }

                    // >>> Custom Legend List
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8 
                        
                        // >>>> Legend Header
                        RowLayout {
                            Layout.fillWidth: true
                            Components.InfoText { text: demoCombo.currentText.toUpperCase(); textSize: 11; textColor: "#AAAAAA"; font.bold: true }
                            Item { Layout.fillWidth: true }
                            Components.InfoText { text: "STUDENTS"; textSize: 11; textColor: "#AAAAAA"; font.bold: true }
                        }

                        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 2; radius: 2; color: "#E5E7EB"; Layout.bottomMargin: 5 }

                        // >>>> Data Rows
                        property var currentModel: {
                            if (demoCombo.currentIndex === 0) return appDashboardController.studentDistributionByGenderData;
                            if (demoCombo.currentIndex === 1) return appDashboardController.studentDistributionByYearData;
                            return appDashboardController.studentDistributionByCollegeData;
                        }
                        property real totalValue: appDashboardController.totalStudents

                        Repeater {
                            model: parent.currentModel
                            delegate: LegendRowItem {
                                labelText: modelData.label
                                valueCount: modelData.value
                                markerColor: getCategoryColor(demoCombo.currentIndex, modelData.label, index)
                                percentage: {
                                    if (customLegendCol.totalValue === 0) return "0%"
                                    return ((modelData.value / customLegendCol.totalValue) * 100).toFixed(1) + "%"
                                }
                            }
                        }
                        id: customLegendCol
                    }
                }
            }

            // >> Program Rankings Card
            Components.Card {
                Layout.fillWidth: true 
                Layout.alignment: Qt.AlignTop
                Layout.preferredHeight: rankingsLayout.implicitHeight + 40
                clip: true 
                
                ColumnLayout {
                    id: rankingsLayout
                    anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
                    anchors.margins: 20
                    spacing: 15 

                    // >>> Header
                    RowLayout {
                        Layout.fillWidth: true
                        Components.InfoText { text: "PROGRAM RANKING"; textSize: 13; textColor: appTheme.activeButtonBorderColor; font.bold: true }
                        Item { Layout.fillWidth: true }
                        DashboardComboBox { id: rankCombo; model: ["Most Popular", "Least Popular"]; choiceWidth: 140 }
                    }

                    // >>> Ranking List
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5
                        Layout.topMargin: 5
                        
                        // >>>> Table Header
                        RowLayout {
                            Layout.fillWidth: true
                            Components.InfoText { text: "#"; textSize: 11; textColor: "#AAAAAA"; font.bold: true; horizontalAlignment: Text.AlignLeft; Layout.preferredWidth: 20 }
                            Components.InfoText { text: "PROGRAM"; textSize: 11; textColor: "#AAAAAA"; font.bold: true; Layout.leftMargin: 10 }
                            Item { Layout.fillWidth: true }
                            Components.InfoText { text: "STUDENTS"; textSize: 11; textColor: "#AAAAAA"; font.bold: true }
                        }

                        Rectangle { Layout.fillWidth: true; height: 2; radius: 2; color: "#E5E7EB"; Layout.bottomMargin: 5 }

                        // >>>> Data Rows
                        Repeater {
                            model: rankCombo.currentIndex === 0 ? appDashboardController.topProgramsData : appDashboardController.leastPopularProgramsData
                            delegate: RankingRowItem {
                                rankIndex: index
                                labelText: modelData.label
                                valueCount: modelData.value
                            }
                        }
                    }
                }
            }
        }
        
        Item { Layout.columnSpan: 12; Layout.preferredHeight: 40 } 
    }

    // > CHART POPULATION LOGIC & TOOLTIPS
    function populatePieSeries(series, dataArray, categoryType) {
        series.clear()
        
        for (let i = 0; i < dataArray.length; i++) {
            let d = dataArray[i]
            let slice = series.append(d.label, d.value)
            
            slice.color = getCategoryColor(categoryType, d.label, i)
            slice.borderColor = "white"
            slice.borderWidth = 2
            slice.labelVisible = false 
            
            slice.onHovered.connect(function(state) {
                if (state) {
                    customTooltip.tipLabel = slice.label.toUpperCase() 
                    customTooltip.tipValue = slice.value.toString()    
                    customTooltip.visible = true
                    slice.borderWidth = 3 
                } else {
                    customTooltip.visible = false
                    slice.borderWidth = 2
                }
            })
        }
    }

    function updateCharts() {
        populatePieSeries(genderSeries, appDashboardController.studentDistributionByGenderData, 0)
        populatePieSeries(yearSeries, appDashboardController.studentDistributionByYearData, 1)
        populatePieSeries(collegeSeries, appDashboardController.studentDistributionByCollegeData, 2)
    }

    Component.onCompleted: updateCharts()

    Connections {
        target: appDashboardController
        function onDataChanged() { updateCharts() }
    }
}