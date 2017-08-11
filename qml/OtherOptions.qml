import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Controls.impl 2.2
import QtQuick.Layouts 1.2
import Qt.labs.settings 1.0
import QtQuick.Controls.Material 2.1

GroupBox{
    id: optionsGroup

    function getValues(){
        return {
            "outputFolder": outputFolder.text,
            "keepExif": keepExifCheckbox.checked,
            "openAfterResize": openAfterResizeCheckbox.checked,
            "closeAfterResize": closeAfterResizeCheckbox.checked,
        }
    }

    title: qsTr("Options")

    property string defaultFolder
    property string customFolder

    readonly property alias autoDetectRotation: autoDetectRotationCheckbox.checked

    Settings{
        id: settings
        property alias automaticFolder: automaticFolderCheckbox.checked
        property alias keepExif: keepExifCheckbox.checked
        property alias autoDetectRotation: autoDetectRotationCheckbox.checked
        property alias openAfterResize: openAfterResizeCheckbox.checked
        property alias closeAfterResize: closeAfterResizeCheckbox.checked
    }

    Column{
        width: parent.width
        Text{
            text: qsTr("Output folder")
        }
        CheckBox{
            id: automaticFolderCheckbox
            text: qsTr("Automatic")
        }

        TextField{
            id: outputFolder
            width: parent.width
            text: automaticFolderCheckbox.checked ? defaultFolder : customFolder
            selectByMouse: true
            readOnly: automaticFolderCheckbox.checked
        }

        property alias replaceCheckbox: control
        /*CheckBox{
            id: control
            text: qsTr("Replace files") + (checked ? " " + qsTr("(original files will be lost)") : "")
            checked: false

            indicator: CheckIndicator {
                x: control.text ? (control.mirrored ? control.width - width - control.rightPadding : control.leftPadding) : control.leftPadding + (control.availableWidth - width) / 2
                y: control.topPadding + (control.availableHeight - height) / 2
                control: control
                border.color: control.down ? "#b71c1c" : control.checked ? "#c62828" : Default.indicatorFrameColor
            }

            contentItem: Text {
                leftPadding: control.indicator && !control.mirrored ? control.indicator.width + control.spacing : 0
                rightPadding: control.indicator && control.mirrored ? control.indicator.width + control.spacing : 0

                text: control.text
                font: control.font
                color: control.down ? "#b71c1c" : control.checked ? "#c62828" : Default.textColor
                elide: Text.ElideRight
                visible: control.text
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                opacity: enabled ? 1 : 0.3
            }

        }*/
        CheckBox{
            id: control
            text: qsTr("Replace files") + (checked ? " " + qsTr("(original files will be lost)") : "")
            checked: false
            Material.foreground: checked ? Material.Red : Material.Foreground
            Material.accent: checked ? Material.Red : Material.Accent
        }
        CheckBox{
            id: keepExifCheckbox
            text: qsTr("Keep exif")
            checked: false
            enabled: false
        }
        CheckBox{
            id: autoDetectRotationCheckbox
            text: qsTr("Auto detect rotation")
            checked: true
        }
        CheckBox{
            id: openAfterResizeCheckbox
            text: qsTr("Open folder after resize")
            checked: true
        }
        CheckBox{
            id: closeAfterResizeCheckbox
            text: qsTr("Close after resize")
            checked: true
        }
    }
}
