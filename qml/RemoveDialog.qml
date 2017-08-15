import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2

Dialog {
    property string path
    property int index: -1

    id: messageDialog
    title: qsTr("Warning")

    contentItem: Label{
        text: qsTr("File '%1' will be deleted").arg(path)
    }

    standardButtons: Dialog.Cancel

    footer: DialogButtonBox {
        Button {
            text: qsTr("Remove")
            DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole

            Material.background: Material.Red
            Material.primary: Material.Red
            Material.accent: Material.Red
            Material.foreground: Material.Yellow
        }
    }

    onAccepted: {
        if( !tools.removeFile( path ) ){
            errorDialog.path = path
            errorDialog.open()
        }else{
            imagesModel.remove( index )
        }
    }

    ErrorDialog{
        property string path
        id: errorDialog
        title: qsTr("Error")
        text: qsTr("Failed to remove file '%1'").arg(path)
    }
}
