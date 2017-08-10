import QtQuick 2.0
import QtGraphicalEffects 1.0

Item {
    property alias image: img
    property alias color: overlay.color

    implicitHeight: img.implicitHeight
    implicitWidth: img.implicitWidth

    Image{
        id: img
        visible: false
        anchors.fill: parent
        fillMode: Image.PreserveAspectFit
    }
    ColorOverlay {
        id: overlay
        anchors.fill: img
        source: img
        color: "black"
    }
}
