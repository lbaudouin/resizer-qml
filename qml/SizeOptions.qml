import QtQuick 2.5
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.2
import Qt.labs.settings 1.0

Page{
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
        category: "SizeOptions"
        property alias size: sizeComboBox.editText
        property alias ratio: ratioCombobox.editText
        property alias size_mode: sizeRadio.checked
        property alias ratio_mode: ratioRadio.checked
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

    header:ToolBar{
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 0.01 * parent.width
            anchors.rightMargin: 0.01 * parent.width
            Label{
                text: qsTr("Size")
                font.pointSize: 16
            }
        }
        Material.background: Material.Orange
    }


    Column{
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 5
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
                editText: "1024"

                Material.primary: editText === "" ? Material.Red : Material.Primary
                Material.accent: editText === "" ? Material.Red : Material.Accent
                Material.foreground: editText === "" ? Material.Red : Material.Foreground
                Material.background: editText === "" ? Material.Red : Material.Background

                onEditTextChanged: {
                    for(var i=0;i<count;i++){
                        if( model[i] == parseInt(editText) ){
                            currentIndex  = i
                            return
                        }
                    }
                }
            }
            Label{
                text: qsTr("pixels")
                Layout.preferredWidth: 50
                enabled: sizeRadio.checked
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
                editText: "33"

                Material.primary: editText === "" ? Material.Red : Material.Primary
                Material.accent: editText === "" ? Material.Red : Material.Accent
                Material.foreground: editText === "" ? Material.Red : Material.Foreground
                Material.background: editText === "" ? Material.Red : Material.Background

                onEditTextChanged: {
                    for(var i=0;i<count;i++){
                        if( model[i] == parseInt(editText) ){
                            currentIndex  = i
                            return
                        }
                    }
                }
            }
            Label{
                text: qsTr("%")
                Layout.preferredWidth: 50
                enabled: ratioRadio.checked
            }
        }
        Item{
            height: 5
            width: parent.width
        }
    }
}
