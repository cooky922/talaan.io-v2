import QtQuick
import QtQuick.Effects

Item {
    id: card
    property string cardTitle: "Default Title"
    property color cardColor: "#ffffff"

    default property alias cardContent: foregroundContent.data

    // hidden base shape
    Rectangle {
        id: backgroundShape
        anchors.fill: parent
        color: card.cardColor
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

// Glass Effect (soon)
/*
Item {
    id: root
    
    // The background item to blur (e.g., your colorful wallpaper)
    property Item blurTarget
    // Liquid glass usually uses softer, larger curves
    property int cardRadius: 24 

    // 1. THE CATCHER
    ShaderEffectSource {
        id: bgSource
        sourceItem: root.blurTarget
        sourceRect: Qt.rect(root.x, root.y, root.width, root.height)
        visible: false 
    }

    // Mask for the rounded corners
    Rectangle {
        id: maskRect
        anchors.fill: parent
        radius: root.cardRadius
        visible: false
    }

    // 2. THE LIQUID BLUR (Notice the saturation boost!)
    MultiEffect {
        anchors.fill: parent
        source: bgSource
        
        blurEnabled: true
        blurMax: 80       // Higher max blur for a deeper liquid feel
        blur: 0.85        // Push the blur heavily
        
        saturation: 1.3   // THE SECRET: Boost the colors by 30% so they pop through the glass!
        
        maskEnabled: true
        maskSource: maskRect
    }

    // 3. THE SPECULAR HIGHLIGHT (Simulating light hitting a fluid curve)
    Rectangle {
        anchors.fill: parent
        radius: root.cardRadius
        
        // A diagonal gradient that mimics light hitting the top-left curve
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.35) } // Bright top-left shine
            GradientStop { position: 0.2; color: Qt.rgba(1, 1, 1, 0.05) } // Fades out quickly
            GradientStop { position: 0.8; color: Qt.rgba(1, 1, 1, 0.0) }  // Completely clear in the middle
            GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0.15) } // Slight reflection at bottom-right
        }

        // 4. THE EDGE LIGHTING
        // We use a subtle border that catches the light
        border.width: 1.5
        border.color: Qt.rgba(1, 1, 1, 0.4)
        
        // Optional: A tiny inner shadow to give it 3D volume
        // We simulate this by drawing a highly transparent black layer 
        // that is pushed slightly down
        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: root.cardRadius - 1
            color: "transparent"
            border.color: Qt.rgba(0, 0, 0, 0.05)
            border.width: 1
        }
    }
}
*/