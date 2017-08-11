import QtQuick 2.7
import QtQuick.Controls 2.2

ToolButton{
    property ListModel actions: ListModel{}

    signal actionTriggered( string action )

    Timer{
        id: antiBounceTimer
        running: false
        interval: 250
    }

    id: menuButton
    text: optionsMenu.visible ? "\u25BC" : "\u25B2"
    onClicked: {
        if( !antiBounceTimer.running && !optionsMenu.visible) optionsMenu.open()
    }

    Menu {
        id: optionsMenu
        x: parent.width - width - 5
        y: parent.y - height - 5
        transformOrigin: Menu.BottomRight

        onVisibleChanged: {
            if( !visible ) antiBounceTimer.start()
        }

        Repeater{
            model: actions
            delegate: MenuItem {
                text: name
                onTriggered: actionTriggered( action )
            }
        }
    }
}

