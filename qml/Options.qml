import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3

Page{
    id: page
    signal back()

    property alias size: sizeOptions
    property alias logo: logoOptions
    property alias general: generalOptions

    function getValues(){
        return {
            size: size.getValues(),
            logo: logo.getValues(),
            general: general.getValues()
        }
    }

    header: ToolBar{
        RowLayout{
            anchors.fill: parent
            anchors.leftMargin: 0.01 * parent.width
            anchors.rightMargin: 0.01 * parent.width
            ColorImage{
               image.source: "qrc:/images/options"
               color: Material.foreground
               height: 32
               width: height
               image.sourceSize.width: height
               image.sourceSize.height: height
            }
            Label{
                text: qsTr("Options")
                font.pointSize: 16
            }
            Item { Layout.fillWidth: true }
            ToolButton{
                text: qsTr("Close \u25B6")
                onClicked: page.back()
            }
        }
    }



    Flickable{
        anchors.fill: parent

        contentHeight: optionsCol.height
        contentWidth: width

        clip: true

        Column{
            id: optionsCol
            width: parent.width

            SizeOptions{
                id: sizeOptions
                width: parent.width
            }

            GeneralOptions{
                id: generalOptions
                width: parent.width
                defaultFolder: sizeOptions.defaultFolder
            }

            LogoOptions{
                id: logoOptions
                width: parent.width
            }
        }
    }
}
