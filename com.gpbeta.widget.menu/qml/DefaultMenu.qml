import QtQml.Models 2.12
import QtQuick 2.12
import QtQuick.Controls 2.12

import NERvGear 1.0 as NVG
import com.gpbeta.common 1.0 as G

G.QuickMenuTemplate {

    readonly property QtObject listModel: ctx_items

    visible: menu.visible

    onOpen: NVG.SystemCall.popupMenu(menu)
    onClose: menu.dismiss()
    onListModelChanged: reloadItems()

    function createMenuItem(index) {
        return cMenuItem.createObject(menu.contentItem, { modelData: listModel.get(index) });
    }

    function reloadItems() {
        while (menu.count)
            menu.removeItem(menu.itemAt(0));

        for (let i = 0; i < listModel.count; ++i)
            menu.addItem(createMenuItem(i));
    }

    Menu { id: menu }

    Component {
        id: cMenuItem

        MenuItem {
            property QtObject modelData

            action: NVG.ActionSource {
                text: modelData.label || this.title
                configuration: modelData.action
            }

            icon {
                width: 24
                height: 24
                source: {
                    const cfg = modelData.icon;

                    if (typeof cfg === "string")
                        return cfg;

                    if (typeof cfg === "object")
                        return Qt.resolvedUrl(cfg.normal || "");

                    return "";
                }
            }
        }
    }

    Connections {
        target: listModel

        onRowsInserted: menu.insertItem(first, createMenuItem(first))
        onRowsRemoved: menu.removeItem(menu.itemAt(first))
        onRowsMoved: menu.moveItem(start, row > start ? row - 1 : row)
        onModelReset: reloadItems()
    }
}
