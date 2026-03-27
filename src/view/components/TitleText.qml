import QtQuick

Text {
    property int textSize: 45
    property color textColor: "black"

    font.pixelSize: textSize
    font.bold: true
    font.family: appTheme.rokkittFontName
    color: textColor
}