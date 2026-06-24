import QtQuick 2.12
import QtQuick.Controls 2.12

import NERvGear 1.0 as NVG
import NERvGear.Templates 1.0 as T
import NERvGear.Preferences 1.0
import NERvExtras 1.0

T.Widget {
    id: widget

    property bool folderUpdated: false
    property NVG.SettingsList folderItems: NVG.Settings.createList(widget)
    readonly property NVG.SettingsList customItems: NVG.Settings.makeList(settings, "items")
    readonly property NVG.SettingsList menuItems: settings.mode ? folderItems : customItems

    title: qsTr("Quick Menu")

    solid: true
    resizable: false
    editing: dialog.item?.visible ?? false
    implicitWidth: iconSource.implicitWidth
    implicitHeight: iconSource.implicitHeight

    menu: Menu {
        Action {
            text: qsTr("Menu Settings...")

            onTriggered: dialog.active = true
        }
    }

    action: T.Action {
        id: thiz

        title: qsTr("Menu Action")
        description: title

        execute: function () {
            return new Promise(function (resolve, reject) {
                switch (thiz.configuration) {
                case 2: widget.doCloseMenu(menuLoader.item); break;
                case 1: widget.doOpenMenu(menuLoader.item); break;
                case 0:
                default: widget.doToggleMenu(menuLoader.item); break;
                }
                resolve();
            });
        }

        preference: SelectPreference {
            label: qsTr("Command")
            model: [ qsTr("Toggle Menu"), qsTr("Show Menu"), qsTr("Hide Menu") ]
            defaultValue: 0
        }
    }

    function fileBaseName(str) {
        const slash = str.lastIndexOf('.');
        return slash > 0 ? str.slice(0, slash) : str;
    }

    function updateFolderItems() {
        if (folderUpdated && !settings.autoRefresh)
            return;

        const folderPath = settings.folder;

        if (folderPath) {
            const newItems = NVG.Settings.createList(widget);

            let basePath = NVG.Url.toLocalFile(Qt.resolvedUrl(folderPath));
            if (!basePath.endsWith('/'))
                basePath = basePath + '/';
            // handle UNC paths
            const baseUrl = (basePath.startsWith('/') ? "file://" : "file:///") + basePath;
            const qDir = QtDir.construct();
            qDir.setPath(basePath);
            qDir.entryList(QtDir.Files | QtDir.AllDirs | QtDir.NoDotAndDotDot,
                           QtDir.DirsFirst | QtDir.IgnoreCase).forEach(function (entry) {
                const item = NVG.Settings.createMap(newItems);
                item.label = fileBaseName(entry);
                item.icon = { normal: "image://shell-icon//" + basePath + entry };
                item.action = {
                    data: { type: 0, url: baseUrl + entry },
                    source: "nvg://system/action#open"
                };
                newItems.append(item);
            });

            folderItems.destroy(1); // suppress warnings in DefaultMenu
            folderItems = newItems;
        } else {
            if (folderItems.count)
                folderItems.clear();
        }
        folderUpdated = true;
    }

    function doOpenMenu(menu) {
        if (menuItems === folderItems)
            updateFolderItems();
        menu.open();
    }

    function doCloseMenu(menu) {
        menu.close();
    }

    function doToggleMenu(menu) {
        if (menu.visible)
            doCloseMenu(menu);
        else
            doOpenMenu(menu);
    }

    NVG.IconSource {
        id: iconSource
        anchors.fill: parent

        defaultIcon {
            normal: "../Images/icon.png"
            hovered: "../Images/icon-hovered.png"
            pressed: "../Images/icon-pressed.png"
        }

        configuration: widget.settings.icon

        hovered: mouseArea.containsMouse
        pressed: mouseArea.pressed || (menuLoader.item?.visible ?? false)

        MouseArea {
            id: mouseArea
            anchors.fill: parent

            hoverEnabled: true

            onPressed: NVG.SystemCall.playSound(NVG.SFX.FeedbackClick)
            onClicked: doToggleMenu(menuLoader.item)
        }
    }

    Loader {
        id: dialog
        active: false
        sourceComponent: EditDialog {
            onClosing: dialog.active = false
        }
    }

    Loader {
        id: menuLoader
        source: Qt.resolvedUrl(settings.style || "DefaultMenu.qml")

        readonly property alias ctx_items: widget.menuItems
        readonly property alias ctx_widget: widget
    }

    Component.onCompleted: {
        if (customItems.count === 0) {
            const item = NVG.Settings.createMap(customItems);
            item.label = qsTr("Menu Item");
            customItems.append(item);
        }
    }
}
