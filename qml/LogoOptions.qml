import QtQuick 2.5
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import Qt.labs.settings 1.0
import Qt.labs.platform 1.0

GroupBox{
    id: logoGroup

    function getValues(){
        return {
            "enabled": logoCheckBox.checked,
            "url": logoInput.text,
            "position": positionComboBox.model.get(positionComboBox.currentIndex).position,
            "horizontal": horizontalSpinbox.value,
            "vertical": verticalSpinbox.value,
            "rotation": rotationSpinbox.value
        }
    }

    title: qsTr("Logo")

    FileDialog{
        id: logoInputDialog
        title: qsTr("Choose a logo")
        folder: StandardPaths.standardLocations(StandardPaths.PicturesLocation)[0]
        nameFilters: [qsTr("Image files") + "(" + tools.supportedFormats() +")"]

        onAccepted: {
            logoInput.text = file
        }
    }

    Settings{
        id: settings
        property alias logoEnabled: logoCheckBox.checked
        property alias logoUrl: logoInput.text
        property alias logoPosition: positionComboBox.currentIndex
        property alias logoHorizontal: horizontalSpinbox.value
        property alias logoVertical: verticalSpinbox.value
        property alias logoRotation: rotationSpinbox.value
    }

    Column{
        id: col
        width: parent.width
        spacing: 5
        CheckBox {
            id: logoCheckBox
            checked: false
            text: qsTr("Add the logo on images")
        }

        Text{
            text: qsTr("Image")
        }

        RowLayout{
            width: parent.width
            TextField{
                id: logoInput
                width: parent.width
                Layout.fillWidth: true
                readOnly: true
            }
            Button{
                text: "..."
                onClicked: {
                    logoInputDialog.open()
                }
            }
        }
        RowLayout{
            width: parent.width
            visible: logoInput.text != ""
            Column{
                Layout.fillWidth: true
                Image{
                    width: 200
                    height: 200
                    source: logoInput.text
                    fillMode: Image.PreserveAspectFit
                }
                Row{
                    spacing: 5
                    Text{
                        text: qsTr("Position")
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    ComboBox{
                        id: positionComboBox
                        anchors.verticalCenter: parent.verticalCenter
                        width: implicitWidth * 2.0
                        textRole: "name"
                        currentIndex: 4

                        model: ListModel{
                            ListElement{
                                name: qsTr("Top Left")
                                position: 0
                            }
                            ListElement{
                                name: qsTr("Top Right")
                                position: 1
                            }
                            ListElement{
                                name: qsTr("Center")
                                position: 2
                            }
                            ListElement{
                                name: qsTr("Bottom Left")
                                position: 3
                            }
                            ListElement{
                                name: qsTr("Bottom Right")
                                position: 4
                            }
                        }
                    }
                }
            }
            Column{
                width: parent.width

                Column{
                    Layout.fillWidth: true
                    Text{
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: qsTr("Horizontal")
                    }
                    SpinBox{
                        id: horizontalSpinbox
                        anchors.horizontalCenter: parent.horizontalCenter
                        editable: true
                        from: -999
                        value: 25
                        to: 999
                    }
                }
                Column{
                    Layout.fillWidth: true
                    Text{
                        text: qsTr("Vertical")
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    SpinBox{
                        id: verticalSpinbox
                        anchors.horizontalCenter: parent.horizontalCenter
                        editable: true
                        from: -999
                        value: 25
                        to: 999
                    }
                }
                Column{
                    Layout.fillWidth: true
                    Text{
                        text: qsTr("Rotation")
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    SpinBox{
                        id: rotationSpinbox
                        anchors.horizontalCenter: parent.horizontalCenter
                        editable: true
                        from: -360
                        value: 0
                        to: 360
                    }
                }
            }
        }
    }
}
