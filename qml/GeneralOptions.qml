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
            "replace": replaceCheckbox.checked,
            "outputFolder": outputFolder.text,
            "keepExif": keepExifCheckbox.checked,
            "openAfterResize": openAfterResizeCheckbox.checked,
            "closeAfterResize": closeAfterResizeCheckbox.checked,
        }
    }

    title: qsTr("General")

    property string defaultFolder
    property string customFolder

    readonly property alias autoDetectRotation: autoDetectRotationCheckbox.checked

    Settings{
        id: settings
        property alias replace: replaceCheckbox.checked
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
            checked: true
        }

        TextField{
            id: outputFolder
            width: parent.width
            text: automaticFolderCheckbox.checked ? defaultFolder : customFolder
            selectByMouse: true
            readOnly: automaticFolderCheckbox.checked
        }
        CheckBox{
            id: replaceCheckbox
            text: qsTr("Replace files") + (checked ? " " + qsTr("(original files will be lost)") : "")
            checked: false
            Material.foreground: checked ? Material.Red : Material.Foreground
            Material.accent: checked ? Material.Red : Material.Accent
        }
        CheckBox{
            id: keepExifCheckbox
            text: qsTr("Keep exif")
            checked: false
            //enabled: false
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
