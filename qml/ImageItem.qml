import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.1

Rectangle{
    id: item
    width: grid.size
    height: grid.size

    border.color: "black"
    border.width: 1

    color: mouse.containsMouse ? Material.accent : "white"

    signal remove()

    Image{
        id: image
        anchors.fill: parent
        anchors.margins: 5
        asynchronous: true
        fillMode: Image.PreserveAspectFit
        source: "image://preview/" + path

        rotation: imgRotation * 90

        BusyIndicator{
            running: image.status === Image.Loading
            anchors.centerIn: parent
        }
    }

    Image {
        source: "qrc:/images/select"
        width: 35
        height: 35
        fillMode: Image.PreserveAspectFit

        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 5

        visible: selected
    }

    MouseArea{
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            //selected = !selected
        }
    }


    Item{
        width: col.width * 1.2
        height: parent.height

        visible: mouse.containsMouse

        Rectangle{
            anchors.fill: parent
            color: "white"
            opacity: 0.5
        }

        Column{
            id: col
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 5
            Image {
                source: "qrc:/images/left"
                width: 35
                height: 35
                fillMode: Image.PreserveAspectFit
                MouseArea{
                    anchors.fill: parent
                    onClicked: imgRotation--
                 }
            }
            Image {
                source: "qrc:/images/right"
                width: 35
                height: 35
                fillMode: Image.PreserveAspectFit
                MouseArea{
                    anchors.fill: parent
                    onClicked: imgRotation++
                }
            }
            Image {
                source: "qrc:/images/remove"
                width: 35
                height: 35
                fillMode: Image.PreserveAspectFit
                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        imagesModel.remove(index)
                    }
                }
            }
            Image {
                source: "qrc:/images/delete"
                width: 35
                height: 35
                fillMode: Image.PreserveAspectFit
                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        remove()
                    }
                }
            }
        }
    }
}
