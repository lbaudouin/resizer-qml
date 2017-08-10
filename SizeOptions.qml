import QtQuick 2.5
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.2
import Qt.labs.settings 1.0

GroupBox{
    id: sizeGroup

    function getValues(){
        return {
            "mode" : sizeRadio.checked ? "size" : "ratio",
            "size" : sizeComboBox.editText,
            "ratio" : ratioCombobox.editText
        }
    }

    readonly property string defaultFolder: sizeRadio.checked ? (sizeComboBox.editText+"px") : (ratioCombobox.editText+"p")

    Settings{
        id: settings
        property alias size: sizeComboBox.editText
        property alias ratio: ratioCombobox.editText
    }

    Connections{
        target: app
        onFocusEmptySizeOption:{
            if(sizeRadio.checked){
                if( sizeComboBox.editText === "" ) sizeComboBox.forceActiveFocus()
            }else{
                if( ratioCombobox.editText === "" ) ratioCombobox.forceActiveFocus()
            }
        }
    }

    title: qsTr("Size")

    Column{
        width: parent.width
        spacing: 5

        ButtonGroup { id: radioGroup }

        RowLayout{
            width: parent.width
            RadioButton{
                id: sizeRadio
                text: qsTr("Maximum size")
                checked: true
                ButtonGroup.group: radioGroup
            }
            Item { Layout.fillWidth: true }
            ComboBox{
                id: sizeComboBox
                enabled: sizeRadio.checked
                editable: true
                validator: IntValidator{ bottom: 1; top: 9999 }
                model: [ 320, 480, 640, 720, 800, 1024, 1280, 2048, 4096 ]

                Material.primary: editText === "" ? Material.Red : Material.Primary
                Material.accent: editText === "" ? Material.Red : Material.Accent
                Material.foreground: editText === "" ? Material.Red : Material.Foreground
                Material.background: editText === "" ? Material.Red : Material.Background
                //Material.shade: Material.Red
            }
            Text{
                text: qsTr("pixels")
                Layout.preferredWidth: 50
                color: sizeRadio.checked ? "black" : "lightgray"
            }
        }
        RowLayout{
            width: parent.width
            RadioButton{
                id: ratioRadio
                text: qsTr("Ratio")
                checked: true
                ButtonGroup.group: radioGroup
            }
            Item { Layout.fillWidth: true }
            ComboBox{
                id: ratioCombobox
                enabled: ratioRadio.checked
                editable: true
                validator: IntValidator{ bottom: 1; top: 100 }
                model: [ 10, 20, 30, 33, 40, 50, 60, 66, 70, 80, 90, 100]
            }
            Text{
                text: qsTr("%")
                Layout.preferredWidth: 50
                color: ratioRadio.checked ? "black" : "lightgray"
            }
        }
    }
}
