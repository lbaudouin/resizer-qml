import QtQuick 2.5
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import Qt.labs.settings 1.0
import Qt.labs.platform 1.0

GroupBox{
    id: logoGroup

    function getValues(){
        return "LOGO"
    }

    label: CheckBox {
        id: logoCheckBox
        checked: true
        text: qsTr("Logo")
    }

    FileDialog{
        id: logoInputDialog

        onAccepted: {
            logoInput.text = file
        }
    }

    Settings{
        id: settings
        property alias url: logoInput.text
        property alias position: positionComboBox.currentIndex
        property alias horizontal: horizontalSpinbox.value
        property alias vertical: verticalSpinbox.value
        property alias rotation: rotationSpinbox.value
    }

    Column{
        id: col
        enabled: logoCheckBox.checked
        width: parent.width
        spacing: 5

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
                Column{
                    Text{
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: qsTr("Position")
                    }
                    ComboBox{
                        id: positionComboBox
                        width: implicitWidth * 2.0
                        anchors.horizontalCenter: parent.horizontalCenter
                        model: [qsTr("Top Left"), qsTr("Top Right"), qsTr("Center"), qsTr("Bottom Left"), qsTr("Bottom Right")]
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
