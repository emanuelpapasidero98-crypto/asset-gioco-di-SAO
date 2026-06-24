import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Templates 2.12 as T
import QtQuick.Controls.Material.impl 2.4

import NERvGear.Controls 1.0
import NERvGear 1.0 as NVG

T.ItemDelegate {
    id: control

    signal addClicked
    signal removeClicked

    signal dragEnter(var drag)

    property int itemIndex: -1
    property Item controlParent

    implicitWidth: implicitBackgroundWidth + leftInset + rightInset
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    topInset: 4
    bottomInset: 4
    leftInset: 148
    rightInset: 108

    verticalPadding: 12
    leftPadding: leftInset + 44
    rightPadding: rightInset + 32

    focusPolicy: Qt.StrongFocus
    opacity: Drag.active ? 0.5 : 1

    icon.width: 18
    icon.height: 18
    icon.color: !enabled ? Style.iconDisabledColor : highlighted ? Style.primaryHighlightedTextColor : Style.iconColor
    icon.name: "regular:\uf105"

    font.weight: highlighted ? Font.Medium : Font.Normal

    Drag.active: mouseArea.drag.active
    Drag.hotSpot: Qt.point(width / 2, height / 2)

    Style.elevation: down ? 8 : 2

    contentItem: Text {
        text: control.text
        font: control.font
        elide: Text.ElideRight
        maximumLineCount: 1

        color: !control.enabled ? control.Style.hintTextColor :
                                  control.highlighted ? control.Style.primaryHighlightedTextColor :
                                                        control.Style.primaryTextColor
    }

    background: Rectangle {
        implicitWidth: 200
        implicitHeight: control.Style.delegateHeight

        layer.enabled: control.enabled
        layer.effect: ElevationEffect {
            elevation: control.Style.elevation

            // hack the layer.smooth property
            Component.onCompleted: children[0].layer.smooth = true
        }

        transform: Matrix4x4 {
            matrix: Qt.matrix4x4(1, -0.35, 0, height * 0.35 * 0.5,
                                 0, 1, 0, 0,
                                 0, 0, 1, 0,
                                 0, 0, 0, 1)
        }
        radius: 2
        color: control.highlighted ? control.Style.primaryColor : control.Style.dialogColor

        Ripple {
            width: parent.width
            height: parent.height

            clip: visible
            pressed: control.pressed
            anchor: control
            active: control.down || control.visualFocus || control.hovered
            color: control.Style.rippleColor
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        anchors.leftMargin: control.leftInset
        anchors.rightMargin: control.rightInset

        cursorShape: Qt.SizeAllCursor

        onPressed: control.forceActiveFocus()

        onClicked: control.clicked()
        onDoubleClicked: control.doubleClicked()

        drag.target: control
        drag.axis: Drag.YAxis

        drag.onActiveChanged: {
            if (drag.active) {
                controlParent = control.parent;
                control.parent = dialog.contentItem;
            } else {
                control.parent = controlParent;
                control.x = 0;
                control.y = 0;
            }
        }
    }

    DropArea {
        anchors.fill: parent

        enabled: !control.Drag.active
        onEntered: control.dragEnter(drag)
    }

    Icon {
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: control.leftInset + 22

        icon: control.icon
    }

    NVG.IconSource {
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: extras.left
        anchors.rightMargin: 28

        width: 32
        height: 32
        pressed: control.highlighted
        configuration: modelData.icon

        image.asynchronous: true
    }

    Row {
        id: extras
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right

        visible: control.hovered && !control.Drag.active

        ToolButton {
            icon.name: "regular:\uf067"

            onClicked: control.addClicked()
        }

        ToolButton {
            icon.name: "regular:\uf068"

            onClicked: control.removeClicked()
        }
    }

}

