import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.0
import QtQuick.Controls.Material 2.1

ApplicationWindow {
    id: app
    visible: true
    width: 800
    height: 600
    title: qsTr("Resizer")

    signal focusEmptySizeOption()

    property string version: "0.1"

    function resize(){
        var opt = options.getValues();

        opt.noResize = false

        console.debug( JSON.stringify(opt,null,2))

        if( (opt.size.mode === "size" && opt.size.size==="") ||
            (opt.size.mode === "ratio" && opt.size.ratio==="") ){
            optionsDrawer.open()
            app.focusEmptySizeOption()
            return
        }

        var list = []
        for(var i=0; i<imagesModel.count; i++){
            list.push( imagesModel.get(i) )
        }
        resizer.resize( list, opt )
    }

    Shortcut {
        sequence: StandardKey.Quit
        context: Qt.ApplicationShortcut
        onActivated: Qt.quit()
    }

    ListModel{
        id: imagesModel

        function addItem( path, rotation ){
            var found = false
            for( var i=0; i<count; i++ ){
                if( get(i).path === path ){
                    found = true
                    break
                }
            }

            if( !found ){
                imagesModel.append(
                            {
                                path: path,
                                imgRotation: rotation,
                                selected: false
                            })
            }
        }
    }

    Connections{
        target: tools
        onLoad: {
            imagesModel.addItem( path, rotation )
        }
    }

    header: ToolBar{
        id: toolbar
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 0.01 * parent.width
            anchors.rightMargin: 0.01 * parent.width

            ToolButton{
                height: 32
                width: height
                contentItem: ColorImage {
                    anchors.verticalCenter: parent.verticalCenter
                    image.fillMode: Image.PreserveAspectFit
                    image.source: "qrc:/images/folder"
                    height: 32
                    width: height
                    image.sourceSize.width: height
                    image.sourceSize.height: height
                    color: Material.foreground
                }
                onClicked: {
                    folderDialog.open()
                }
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Open folder")
            }
            ToolButton{
                height: 32
                width: height
                contentItem: ColorImage {
                    anchors.verticalCenter: parent.verticalCenter
                    image.fillMode: Image.PreserveAspectFit
                    image.source: "qrc:/images/file"
                    height: 32
                    width: height
                    image.sourceSize.width: height
                    image.sourceSize.height: height
                    color: Material.foreground
                }
                onClicked: {
                    fileDialog.open()
                }
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Open files")
            }
            Item { Layout.fillWidth: true }
            ToolButton{
                text: qsTr("Options")
                onClicked: {
                    optionsDrawer.open()
                }
            }
        }
    }


    Item{
        anchors.fill: parent
        anchors.margins: 5

        Flickable{
            anchors.fill: parent

            contentWidth: width
            contentHeight: grid.height

            interactive: contentHeight > height
            clip: true

            Grid {
                id: grid
                width: columns * size
                spacing: 1

                anchors.horizontalCenter: parent.horizontalCenter

                property int size: 205

                columns: parent.width / size

                Repeater{
                    model: imagesModel

                    delegate: ImageItem{
                    }
                }
            }
        }

        Drawer{
            id: optionsDrawer
            width: parent.width * 0.9
            height: parent.height
            edge: Qt.RightEdge

            Options{
                id: options
                anchors.fill: parent

                onBack: {
                    optionsDrawer.close()
                }
            }
        }
    }

    footer: ToolBar{
        leftPadding: 5
        RowLayout {
            anchors.fill: parent
            spacing: 2
            Label{
                text: imagesModel.count > 0 ? qsTr("%n images","Number of images", imagesModel.count ) : qsTr("Version: %1").arg(app.version)
            }
            Item { Layout.fillWidth: true }

            Button{
                contentItem: Row{
                    spacing: 5
                    leftPadding: 5
                    Image {
                        anchors.verticalCenter: parent.verticalCenter
                        height: buttonText.height * 1.2
                        width: height

                        source: "qrc:/images/resize"
                        fillMode: Image.PreserveAspectFit
                    }
                    Text{
                        anchors.verticalCenter: parent.verticalCenter
                        id: buttonText
                        text: qsTr("Resize")
                    }
                }

                onClicked: {
                    resize();
                }
            }

            DropButton{
                Layout.preferredWidth: 25
                actions: ListModel{
                    ListElement{
                        name: qsTr("Zip folder")
                        action: "zip"
                    }
                    ListElement{
                        name: qsTr("Open in temporary folder")
                        action: "temp"
                    }
                    ListElement{
                        name: qsTr("Add a logo without resizing")
                        action: "logo"
                    }
                }

                onActionTriggered: {
                    if( action == "zip" ){
                        console.debug( "zip" )
                    }
                    if( action == "temp" ){
                        console.debug( "temp" )
                    }
                    if( action == "logo" ){
                        console.debug( "logo" )
                    }
                }
            }
        }
    }

    FolderDialog {
        id: folderDialog
        title: qsTr("Choose a folder")
        folder: StandardPaths.standardLocations(StandardPaths.PicturesLocation)[0]

        onAccepted: {
            console.debug( folder )
            tools.openFolder( folder, options.other.autoDetectRotation )
        }
    }

    FileDialog{
        id: fileDialog
        title: qsTr("Choose files")
        fileMode: FileDialog.OpenFiles
        folder: StandardPaths.standardLocations(StandardPaths.PicturesLocation)[0]

        onAccepted: {
            var tmp = []
            for(var i=0;i<files.length;i++)
                tmp.push( files[i] )
            tools.openFiles( tmp, options.other.autoDetectRotation )
        }
    }
}
