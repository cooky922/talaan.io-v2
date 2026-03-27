import QtQuick

Text {
    property int textSize: 12
    property color textColor: "black"

    font.pixelSize: textSize
    font.family: appTheme.rethinkSansFontName
    color: textColor
}