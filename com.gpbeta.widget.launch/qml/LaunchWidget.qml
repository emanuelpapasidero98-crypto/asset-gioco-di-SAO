import QtQuick 2.12
import QtQuick.Controls 2.12

import NERvGear 1.0 as NVG
import NERvGear.Dialogs 1.0 as D
import NERvGear.Templates 1.0 as T

T.Widget {
    id: widget

    title: qsTr("Quick Launch")

    solid: true
    resizable: false
    implicitWidth: icon.implicitWidth
    implicitHeight: icon.implicitHeight

    menu: Menu {

        MenuItem {
            text: qsTr("Change Icon")

            onTriggered: iconDialog.open()
        }

        MenuItem {
            text: qsTr("Change Action")

            onTriggered: acionDialog.open()
        }
    }

    D.IconDialog {
        id: iconDialog

        transientParent: widget.NVG.View.window
        configuration: widget.settings.icon
        defaultIcon: icon.defaultIcon

        onAccepted: widget.settings.icon = configuration
    }

    D.ActionDialog {
        id: acionDialog

        transientParent: widget.NVG.View.window
        configuration: widget.settings.action

        onAccepted: widget.settings.action = configuration
    }

    NVG.IconSource {
        id: icon
        anchors.fill: parent

        defaultIcon {
            normal: "../Images/icon.png"
            hovered: "../Images/icon-hovered.png"
            pressed: "../Images/icon-pressed.png"
        }

        configuration: widget.settings.icon

        hovered: mouseArea.containsMouse
        pressed: mouseArea.pressed

        MouseArea {
            id: mouseArea
            anchors.fill: parent

            hoverEnabled: true
            acceptedButtons: Qt.LeftButton

            onPressed: NVG.SystemCall.playSound(NVG.SFX.FeedbackClick);
            onClicked: {
                if (action.status)
                    action.trigger(widget);
                else
                    NVG.SystemCall.showLauncher();
            }
        }
    }

    NVG.ActionSource {
        id: action

        configuration: widget.settings.action
    }

}
