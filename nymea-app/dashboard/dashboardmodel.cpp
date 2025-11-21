// SPDX-License-Identifier: GPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright (C) 2013 - 2024, nymea GmbH
* Copyright (C) 2024 - 2025, chargebyte austria GmbH
*
* This file is part of nymea-app.
*
* nymea-app is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* nymea-app is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with nymea-app. If not, see <https://www.gnu.org/licenses/>.
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include "dashboardmodel.h"
#include "dashboarditem.h"

#include <QJsonDocument>
#include <QDebug>

DashboardModel::DashboardModel(QObject *parent) : QAbstractListModel(parent)
{

}

int DashboardModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return static_cast<int>(m_list.count());
}

QVariant DashboardModel::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case RoleType:
        return m_list.at(index.row())->type();
    case RoleColumnSpan:
        return m_list.at(index.row())->columnSpan();
    case RoleRowSpan:
        return m_list.at(index.row())->rowSpan();
    }
    Q_ASSERT_X(false, "DashboardModel", "Unhandled role");
    return QVariant();
}

QHash<int, QByteArray> DashboardModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleType, "type");
    roles.insert(RoleColumnSpan, "columnSpan");
    roles.insert(RoleRowSpan, "rowSpan");
    return roles;
}

DashboardItem *DashboardModel::get(int index) const
{
    if (index < 0 || index >= m_list.size()) {
        return nullptr;
    }
    return m_list.at(index);
}

void DashboardModel::addThingItem(const QUuid &thingId, int index)
{
    DashboardThingItem *item = new DashboardThingItem(thingId, this);
    addItem(item, index);
}

void DashboardModel::addFolderItem(const QString &name, const QString &icon, int index)
{
    DashboardFolderItem *item = new DashboardFolderItem(name, icon, this);
    connect(item->model(), &DashboardModel::save, this, &DashboardModel::save);
    addItem(item, index);
}

void DashboardModel::addGraphItem(const QUuid &thingId, const QUuid &stateTypeId, int index)
{
    DashboardGraphItem *item = new DashboardGraphItem(thingId, stateTypeId, this);
    item->setColumnSpan(2);
    addItem(item, index);
}

void DashboardModel::addSceneItem(const QUuid &ruleId, int index)
{
    DashboardSceneItem *item = new DashboardSceneItem(ruleId, this);
    addItem(item, index);
}

void DashboardModel::addWebViewItem(const QUrl &url, int columnSpan, int rowSpan, bool interactive, int index)
{
    QUrl fixedUrl = url;
    // Correct url if no scheme is given as it would end up being qrc:// by default which no user will want...
    if (fixedUrl.scheme().isEmpty()) {
        fixedUrl.setScheme("https");
    }
    DashboardWebViewItem *item = new DashboardWebViewItem(fixedUrl, interactive, this);
    item->setColumnSpan(columnSpan);
    item->setRowSpan(rowSpan);
    addItem(item, index);
}

void DashboardModel::addStateItem(const QUuid &thingId, const QUuid &stateTypeId, int index)
{
    DashboardStateItem *item = new DashboardStateItem(thingId, stateTypeId, this);
    addItem(item, index);
}

void DashboardModel::addSensorItem(const QUuid &thingId, const QStringList &interfaces, int index)
{
    DashboardSensorItem *item = new DashboardSensorItem(thingId, interfaces, this);
    addItem(item, index);
}

void DashboardModel::removeItem(int index)
{
    qWarning() << "removing" << index;
    beginRemoveRows(QModelIndex(), index, index);
    m_list.removeAt(index);
    endRemoveRows();
    emit changed();
    emit countChanged();
}

void DashboardModel::move(int from, int to)
{
    // QList's and QAbstractItemModel's move implementation differ when moving an item up the list :/
    // While QList needs the index in the resulting list, beginMoveRows expects it to be in the current list
    // adjust the model's index by +1 in case we're moving upwards
    int newModelIndex = to > from ? to+1 : to;

    beginMoveRows(QModelIndex(), from, from, QModelIndex(), newModelIndex);
    m_list.move(from, to);
    endMoveRows();
    emit changed();
}

void DashboardModel::loadFromJson(const QByteArray &json)
{
    if (toJson() == json) {
        return;
    }
    beginResetModel();

    qDeleteAll(m_list);
    m_list.clear();

    QJsonDocument jsonDoc = QJsonDocument::fromJson(json);
    qCritical() << "dashboard:" << qUtf8Printable(jsonDoc.toJson());
    foreach (const QVariant &itemVariant, jsonDoc.toVariant().toList()) {
        QVariantMap itemMap = itemVariant.toMap();
        QString type = itemMap.value("type").toString();
        DashboardItem *item;
        if (type == "folder") {
            DashboardFolderItem *folderItem = new DashboardFolderItem(itemMap.value("name").toString(), itemMap.value("icon", "folder").toString(), this);
            folderItem->model()->loadFromJson(QJsonDocument::fromVariant(itemMap.value("model").toList()).toJson(QJsonDocument::Compact));
            connect(folderItem->model(), &DashboardModel::save, this, &DashboardModel::save);
            item = folderItem;
        } else if (type == "thing") {
            item = new DashboardThingItem(itemMap.value("thingId").toUuid(), this);
        } else if (type == "graph") {
            item = new DashboardGraphItem(itemMap.value("thingId").toUuid(), itemMap.value("stateTypeId").toUuid(), this);
        } else if (type == "scene") {
            item = new DashboardSceneItem(itemMap.value("ruleId").toUuid(), this);
        } else if (type == "webview") {
            item = new DashboardWebViewItem(itemMap.value("url").toUrl(), itemMap.value("interactive", false).toBool(), this);
        } else if (type == "state") {
            item = new DashboardStateItem(itemMap.value("thingId").toUuid(), itemMap.value("stateTypeId").toUuid(), this);
        } else if (type == "sensor") {
            item = new DashboardSensorItem(itemMap.value("thingId").toUuid(), itemMap.value("interfaces").toStringList(), this);
        } else {
            qWarning() << "Dashboard item type" << type << "is not implemented. Skipping...";
            continue;
        }
        item->setColumnSpan(itemMap.value("columnSpan", 1).toInt());
        item->setRowSpan(itemMap.value("rowSpan", 1).toInt());
        addItem(item);
//        connect(item, &DashboardItem::changed, this, &DashboardModel::changed);
//        m_list.append(item);
    }

    endResetModel();
    emit countChanged();
}

QByteArray DashboardModel::toJson() const
{
    QVariantList list;
    foreach (DashboardItem* item, m_list) {
        QVariantMap map;
        map.insert("type", item->type());
        if (item->type() == "thing") {
            DashboardThingItem *thingItem = dynamic_cast<DashboardThingItem*>(item);
            map.insert("thingId", thingItem->thingId());
        } else if (item->type() == "folder") {
            DashboardFolderItem *folderItem = dynamic_cast<DashboardFolderItem*>(item);
            map.insert("name", folderItem->name());
            map.insert("icon", folderItem->icon());
            QJsonDocument modelDoc = QJsonDocument::fromJson(folderItem->model()->toJson());
            map.insert("model", modelDoc.toVariant());
        } else if (item->type() == "graph") {
            DashboardGraphItem *grapItem = dynamic_cast<DashboardGraphItem*>(item);
            map.insert("thingId", grapItem->thingId());
            map.insert("stateTypeId", grapItem->stateTypeId());
        } else if (item->type() == "scene") {
            DashboardSceneItem *sceneItem = dynamic_cast<DashboardSceneItem*>(item);
            map.insert("ruleId", sceneItem->ruleId());
        } else if (item->type() == "webview") {
            DashboardWebViewItem *webViewItem = dynamic_cast<DashboardWebViewItem*>(item);
            map.insert("url", webViewItem->url());
            if (webViewItem->interactive()) {
                map.insert("interactive", true);
            }
        } else if (item->type() == "sensor") {
            DashboardSensorItem *sensorItem = dynamic_cast<DashboardSensorItem*>(item);
            map.insert("thingId", sensorItem->thingId());
            map.insert("interfaces", sensorItem->interfaces());
        } else if (item->type() == "state") {
            DashboardStateItem *stateItem = dynamic_cast<DashboardStateItem*>(item);
            map.insert("thingId", stateItem->thingId());
            map.insert("stateTypeId", stateItem->stateTypeId());
        } else {
            Q_ASSERT_X(false, Q_FUNC_INFO, "Type " + item->type().toUtf8() + " not implemented!");
            continue;
        }
        if (item->columnSpan() != 1) {
            map.insert("columnSpan", item->columnSpan());
        }
        if (item->rowSpan() != 1) {
            map.insert("rowSpan", item->rowSpan());
        }
        list.append(map);
    }
    QJsonDocument jsonDoc = QJsonDocument::fromVariant(list);
    return jsonDoc.toJson(QJsonDocument::Compact);
}

void DashboardModel::addItem(DashboardItem *item, int index)
{
    if (index < 0 || index > m_list.size()) {
        index = static_cast<int>(m_list.size());
    }
    connect(item, &DashboardItem::rowSpanChanged, this, [this, item](){
        int idx = static_cast<int>(static_cast<int>(m_list.indexOf(item)));
        if (idx >= 0) {
            emit dataChanged(this->index(idx), this->index(idx), {RoleRowSpan});
        }
    });
    connect(item, &DashboardItem::columnSpanChanged, this, [this, item](){
        int idx = static_cast<int>(static_cast<int>(m_list.indexOf(item)));
        if (idx >= 0) {
            emit dataChanged(this->index(idx), this->index(idx), {RoleColumnSpan});
        }
    });
    connect(item, &DashboardItem::changed, this, [this]() {
        emit changed();
    });
    beginInsertRows(QModelIndex(), index, index);
    m_list.insert(index, item);
    endInsertRows();
    emit changed();
    emit countChanged();
}
