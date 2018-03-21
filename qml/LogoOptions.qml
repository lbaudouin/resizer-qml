import QtQuick 2.5
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.2
import Qt.labs.settings 1.0

import Qt.labs.platform 1.0

Page{
    id: logoGroup

    function getValues(){
        return {
            "enabled": logoCheckBox.checked,
            "url": logoInput.text,
            "position": positionComboBox.model.get(positionComboBox.currentIndex).position,
            "horizontal": horizontalSpinbox.value,
            "vertical": verticalSpinbox.value,
            "rotation": rotationSpinbox.value,
            "opacity": opacitySpinbox.value
        }
    }

    header:ToolBar{
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 0.01 * parent.width
            anchors.rightMargin: 0.01 * parent.width
            Label{
                text: qsTr("Logo")
                font.pointSize: 16
            }
        }
        Material.background: Material.Orange
    }

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
        category: "LogoOptions"
        property alias logoEnabled: logoCheckBox.checked
        property alias logoUrl: logoInput.text
        property alias logoPosition: positionComboBox.currentIndex
        property alias logoHorizontal: horizontalSpinbox.value
        property alias logoVertical: verticalSpinbox.value
        property alias logoRotation: rotationSpinbox.value
        property alias logoOpacity: opacitySpinbox.value
    }

    Column{
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 5
        spacing: 5

        CheckBox {
            id: logoCheckBox
            checked: false
            text: qsTr("Add the logo on images")
        }

        RowLayout{
            width: parent.width
            enabled: logoCheckBox.checked
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
            enabled: logoCheckBox.checked
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
                    Label{
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
                enabled: logoCheckBox.checked
                width: parent.width

                Column{
                    Layout.fillWidth: true
                    Label{
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
                    Label{
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
                    Label{
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
                Column{
                    Layout.fillWidth: true
                    Label{
                        text: qsTr("Opacity")
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    SpinBox{
                        id: opacitySpinbox
                        anchors.horizontalCenter: parent.horizontalCenter
                        editable: true
                        from: 0
                        value: 100
                        to: 100
                    }
                }
            }
        }
        Item{
            height: 5
            width: parent.width
        }
    }
}
