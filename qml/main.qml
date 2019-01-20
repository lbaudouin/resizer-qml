import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.0

import Resizer 1.0

ApplicationWindow {
    id: app
    visible: !noWindow
    width: 800
    height: 600
    title: qsTr("Resizer")

    signal focusEmptySizeOption()

    function resize(mode){
        if(imagesModel.count === 0){
            return
        }

        var opt = options.getValues();
        opt.mode = mode

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

    /*Connections{
        target: resizer
        onProgressRangeChanged:{
            progressBar.from = minimum
            progressBar.to = maximum
        }
    }*/

    header: ToolBar{
        id: toolbar
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 0.01 * parent.width
            anchors.rightMargin: 0.01 * parent.width

            ToolButton{
                height: 32
                width: height

                ColorImage{
                    image.source: "qrc:/images/folder"
                    color: "white"
                    height: 32
                    width: 32
                    anchors.centerIn: parent
                }
                /*
                //Need Qt 5.10
                icon{
                    source: "qrc:/images/folder"
                    height: 32
                    width: 32
                }*/

                onClicked: {
                    folderDialog.open()
                }
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Add folder")
            }
            ToolButton{
                height: 32
                width: height

                ColorImage{
                    image.source: "qrc:/images/file"
                    color: "white"
                    height: 32
                    width: 32
                    anchors.centerIn: parent
                }
                /*
                //Need Qt 5.10
                icon{
                    source: "qrc:/images/file"
                    height: 32
                    width: 32
                }*/

                onClicked: {
                    fileDialog.open()
                }
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Add files")
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


    DropArea{
        id: dropArea
        anchors.fill: parent
        anchors.margins: 5

        property bool dropping: false
        property bool validDrop: false

        onEntered: {
            dropping = true
            validDrop = tools.containsValidUrls(drag.urls)
            drag.accepted = true
        }
        onExited: {
            dropping = false
        }

        onDropped: {
            if(validDrop){
                var tmp = []
                for(var index in drop.urls)
                    tmp.push( drop.urls[index] )

                tools.openFiles( tmp )
            }
            drop.accepted = true
            dropping = false
        }


        ColorImage{
            id: dropIcon
            visible: imagesModel.count === 0
            anchors.centerIn: parent
            image.source: "qrc:/images/drop"
            color: dropArea.dropping ? dropArea.validDrop ? Material.color(Material.Green) : Material.color(Material.Red) : Material.color(Material.Grey)
        }

        Flickable{
            visible: imagesModel.count > 0

            anchors.top: parent.top
            anchors.bottom: progressBar.top
            anchors.bottomMargin: 5
            anchors.left: parent.left
            anchors.right: parent.right

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
                        onRemove:{
                            removeDialog.path = path
                            removeDialog.index = index
                            removeDialog.open()
                        }
                    }
                }
            }

            ScrollBar.vertical: ScrollBar { }
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

        ProgressBar{
            id: progressBar
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right

            visible: resizer.progress >= 0
            from: 0
            to: 100
            value: resizer.progress
        }
    }

    footer: ToolBar{
        leftPadding: 5
        RowLayout {
            anchors.fill: parent
            spacing: 2
            Label{
                text: imagesModel.count > 0 ? qsTr("%n images","Number of images", imagesModel.count ) : qsTr("Version: %1").arg(version)
            }
            Item { Layout.fillWidth: true }

            Button{
                /*
                //Need Qt 5.10
                icon{
                    source: "qrc:/images/resize"
                }*/

                text: qsTr("Resize")

                onClicked: {
                    resize(Resizer.NormalMode);
                }
            }

            DropButton{
                Layout.preferredWidth: 25
                actions: ListModel{
                    ListElement{
                        name: qsTr("Create Zip")
                        action: Resizer.ZipMode
                    }
                    ListElement{
                        name: qsTr("Temporary folder")
                        action: Resizer.TempMode
                    }
                    ListElement{
                        name: qsTr("Just add a logo")
                        action: Resizer.LogoMode
                    }
                }

                onActionTriggered: {
                    resize(action);
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
            tools.openFolder( folder, options.general.autoDetectRotation )
        }
    }

    FileDialog{
        id: fileDialog
        title: qsTr("Choose files")
        fileMode: FileDialog.OpenFiles
        folder: StandardPaths.standardLocations(StandardPaths.PicturesLocation)[0]
        nameFilters: [qsTr("Image files") + "(" + tools.supportedFormats() +")"]


        onAccepted: {
            var tmp = []
            for(var i=0;i<files.length;i++)
                tmp.push( files[i] )
            tools.openFiles( tmp, options.general.autoDetectRotation )
        }
    }

    RemoveDialog{
        id: removeDialog
        x: (app.width - width) * 0.5
        y: app.height * 0.5 - height
    }

    Connections{
        target: tools
        onOpenFolderDialog: folderDialog.open()
        onOpenFileDialog: fileDialog.open()
    }

    Connections{
        target: resizer
        onOpenOutputFolder:{
            if( folders.length === 1){
                tools.openFolderInExplorer( folders[0] )
            }else{
                console.debug( JSON.stringify(folders ) )
            }

            if( folders.length <= 1 && close ){
                Qt.quit()
            }
        }
    }
}
