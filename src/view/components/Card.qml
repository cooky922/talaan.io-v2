import QtQuick
import QtQuick.Effects

Item {
    id: card
    property string cardTitle: "Default Title"
    property color cardColor: "#ffffff"
    property bool bordered: false

    default property alias cardContent: foregroundContent.data

    // hidden base shape
    Rectangle {
        id: backgroundShape
        anchors.fill: parent
        color: card.cardColor
        border.width: bordered ? 2 : 0
        border.color: bordered ? Qt.rgba(0, 0, 0, 0.10) : "transparent"
        radius: 12
        visible: false 
    }

    // drop shadow
    MultiEffect {
        source: backgroundShape
        anchors.fill: backgroundShape
        shadowEnabled: true
        shadowHorizontalOffset: 4
        shadowVerticalOffset: 4
        shadowBlur: 4
        shadowColor: appTheme.cardShadowColor
    }

    // all children contents will go inside here
    Item {
        id: foregroundContent
        anchors.fill: parent
    }
}