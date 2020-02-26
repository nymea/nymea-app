#include "tokeninfos.h"
#include "tokeninfo.h"

TokenInfos::TokenInfos(QObject *parent) : QAbstractListModel(parent)
{

}

int TokenInfos::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_list.count();
}

QVariant TokenInfos::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case RoleId:
        return m_list.at(index.row())->id();
    case RoleUsername:
        return m_list.at(index.row())->username();
    case RoleDeviceName:
        return m_list.at(index.row())->deviceName();
    case RoleCreationTime:
        return m_list.at(index.row())->creationTime();
    }
    return QVariant();
}

QHash<int, QByteArray> TokenInfos::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleId, "id");
    roles.insert(RoleUsername, "username");
    roles.insert(RoleDeviceName, "deviceName");
    roles.insert(RoleCreationTime, "creationTime");
    return roles;
}

void TokenInfos::addToken(TokenInfo *tokenInfo)
{
    tokenInfo->setParent(this);
    beginInsertRows(QModelIndex(), m_list.count(), m_list.count());
    m_list.append(tokenInfo);
    endInsertRows();
    emit countChanged();
}

void TokenInfos::removeToken(const QUuid &tokenId)
{
    for (int i = 0; i < m_list.count(); i++) {
        if (m_list.at(i)->id() == tokenId) {
            beginRemoveRows(QModelIndex(), i, i);
            m_list.takeAt(i)->deleteLater();
            endRemoveRows();
            emit countChanged();
            return;
        }
    }
}
