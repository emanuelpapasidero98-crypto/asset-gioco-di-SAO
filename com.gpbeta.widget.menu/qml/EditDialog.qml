import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import NERvGear 1.0 as NVG
import NERvGear.Private 1.0 as NVG
import NERvGear.Preferences 1.0 as P
import NERvGear.Controls 1.0

NVG.Window {
    id: dialog

    Style.theme: menuLoader.item?.style ?? Style.System

    property QtObject currentItem: widget.customItems.get(0)

    title: qsTr("Quick Menu")
    visible: true
    minimumWidth: 1024
    minimumHeight: 720
    width: minimumWidth
    height: minimumHeight

    onClosing: titleBar.forceActiveFocus()

    Page {
        anchors.fill: parent

        header: TitleBar { id: titleBar; text: dialog.title }

        Loader {
            anchors.left: parent.left
            anchors.right: settingsPane.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            enabled: pMode.value === 0
            sourceComponent: Flickable {
                id: flickable
                anchors.fill: parent

                topMargin: 96
                bottomMargin: 64
                contentWidth: width
                contentHeight: menuView.height

                Column {
                    id: menuView

                    Repeater {
                        model: widget.customItems
                        delegate: Item {
                            width: itemDelegate.width
                            height: itemDelegate.height

                            MenuItemDelegate {
                                id: itemDelegate

                                itemIndex: index
                                text: modelData.label
                                highlighted: dialog.currentItem === modelData

                                onClicked: currentItem = modelData

                                onDragEnter: {
                                    if (drag.source === null) {
                                        drag.accepted = false;
                                        return;
                                    }
                                    widget.customItems.move(drag.source.itemIndex, itemIndex, 1);
                                }

                                onAddClicked: {
                                    const item = NVG.Settings.createMap(widget.customItems);
                                    widget.customItems.insert(itemIndex, item);
                                    dialog.currentItem = item;
                                }

                                onRemoveClicked: {
                                    if (itemIndex === 0 && widget.customItems.count <= 1)
                                        return;

                                    if (dialog.currentItem === modelData) {
                                        if (itemIndex + 1 < widget.customItems.count)
                                            dialog.currentItem = widget.customItems.get(itemIndex + 1);
                                        else
                                            dialog.currentItem = widget.customItems.get(itemIndex - 1);
                                    }

                                    widget.customItems.remove(itemIndex);
                                }

                            }
                        }
                    }
                }

                Timer {
                    interval: 500
                    repeat: true
                    running: topDropArea.containsDrag || bottomDropArea.containsDrag

                    onTriggered: {
                        if (topDropArea.containsDrag) {
                            if (flickable.contentY > 0)
                                topDropArea.entered(null);
                        } else {
                            if (flickable.contentY < flickable.contentHeight - flickable.height)
                                bottomDropArea.entered(null);
                        }
                    }
                }

                DropArea {
                    id: topDropArea
                    parent: flickable
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top

                    height: 32
                    onEntered: flickable.flick(0, 800)
                }

                DropArea {
                    id: bottomDropArea
                    parent: flickable
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom

                    height: 64
                    onEntered: flickable.flick(0, -800)
                }

                ScrollBar.vertical: ScrollBar {}
            }
        }

        Pane {
            id: settingsPane
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right

            width: 450
            topPadding: 0

            ColumnLayout {
                anchors.left: parent.left
                anchors.right: parent.right

                P.ObjectPreferenceGroup {
                    Layout.fillWidth: true

                    label: qsTr("Widget Settings")
                    defaultValue: widget.settings
                    syncProperties: true

//                    P.BackgroundPreference {
//                        name: "background"
//                        label: qsTr("Background")

//                        defaultBackground: itemOptions.iconPreviewDefaultIcon

//                        onPreferenceEdited: currentItem.theme.icon = save()
//                    }

                    P.IconPreference {
                        name: "icon"
                        label: qsTr("Icon")

                        defaultIcon: iconSource.defaultIcon
                    }

                    P.SelectPreference {
                        id: pStyle
                        name: "style"
                        label: qsTr("Style")
                        textRole: "label"
                        valueRole: "url"
                        defaultValue: 0
                        model: {
                            const files = [ { label: qsTr("Default Menu"), url: "DefaultMenu.qml" } ];
                            const resources = NVG.Resources.filter(/.*/, /com.gpbeta.quick-menu(?:$|\/.+)/);
                            resources.forEach(function (resource) {
                                resource.files().forEach(function (file) {
                                    files.push({ label: file.title || file.name, url: file.url.toString() });
                                });
                            });
                            return files;
                        }
                    }

                    P.SelectPreference {
                        id: pMode
                        name: "mode"
                        label: qsTr("Mode")
                        model: [ qsTr("Custom Menu"), qsTr("System Folder") ]
                        defaultValue: 0
                    }
                }

                P.ObjectPreferenceGroup {
                    Layout.fillWidth: true

                    label: qsTr("Folder Settings")
                    defaultValue: widget.settings
                    visible: pMode.value === 1
                    syncProperties: true

                    P.FolderPreference {
                        name: "folder"
                        label: qsTr("Path")
                        visible: pMode.value === 1
                        onPreferenceEdited: widget.folderUpdated = false
                    }

                    P.SwitchPreference {
                        name: "autoRefresh"
                        label: qsTr("Auto Refresh")
                        visible: pMode.value === 1
                        defaultValue: false
                    }
                }

                P.ObjectPreferenceGroup {
                    Layout.fillWidth: true

                    label: qsTr("Item Settings")
                    defaultValue: currentItem
                    enabled: currentItem
                    visible: pMode.value === 0
                    syncProperties: true

                    P.TextFieldPreference {
                        name: "label"
                        label: qsTr("Name")
                        display: P.TextFieldPreference.ExpandControl
                    }

                    P.IconPreference {
                        name: "icon"
                        label: qsTr("Icon")

                        preview: menuLoader.item.iconPreview
                        defaultIcon: menuLoader.item.iconPreviewDefaultIcon
                        availableFilter: menuLoader.item.iconAvailableFilter
                        preferableFilter: menuLoader.item.iconPreferableFilter
                    }

                    P.ActionPreference {
                        name: "action"
                        label: qsTr("Action")
                    }
                }
            }

            Style.elevation: 1
            Style.background: dialog.Style.dialogColor
        }

    }
}

