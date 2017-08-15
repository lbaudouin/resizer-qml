import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2

Dialog {
    id: dialog
    property string text
    standardButtons: Dialog.Ok
    contentItem: Label{
        text: dialog.text
    }
}
