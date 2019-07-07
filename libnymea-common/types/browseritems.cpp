#include "browseritems.h"
#include "browseritem.h"

#include <QDebug>

BrowserItems::BrowserItems(QObject *parent): QAbstractListModel(parent)
{

}

BrowserItems::~BrowserItems()
{
    qDebug() << "Deleting BrowserItems";
}

bool BrowserItems::busy() const
{
    return m_busy;
}

int BrowserItems::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return m_list.count();
}

QVariant BrowserItems::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case RoleId:
        return m_list.at(index.row())->id();
    case RoleDisplayName:
        return m_list.at(index.row())->displayName();
    case RoleDescription:
        return m_list.at(index.row())->description();
    case RoleIcon:
        return m_list.at(index.row())->icon();
    case RoleThumbnail:
        return m_list.at(index.row())->thumbnail();
    case RoleExecutable:
        return m_list.at(index.row())->executable();
    case RoleBrowsable:
        return m_list.at(index.row())->browsable();

    case RoleMediaIcon:
        return m_list.at(index.row())->mediaIcon();
    }
    return QVariant();
}

QHash<int, QByteArray> BrowserItems::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleId, "id");
    roles.insert(RoleDisplayName, "displayName");
    roles.insert(RoleDescription, "description");
    roles.insert(RoleIcon, "icon");
    roles.insert(RoleThumbnail, "thumbnail");
    roles.insert(RoleExecutable, "executable");
    roles.insert(RoleBrowsable, "browsable");

    roles.insert(RoleMediaIcon, "mediaIcon");
    return roles;
}

void BrowserItems::addBrowserItem(BrowserItem *browserItem)
{
    browserItem->setParent(this);
    beginInsertRows(QModelIndex(), m_list.count(), m_list.count());
    m_list.append(browserItem);
    endInsertRows();
    emit countChanged();
}

void BrowserItems::setBusy(bool busy)
{
    if (m_busy != busy) {
        m_busy = busy;
        emit busyChanged();
    }
}
