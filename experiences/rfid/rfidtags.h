// SPDX-License-Identifier: GPL-3.0-or-later

#ifndef RFIDTAGS_H
#define RFIDTAGS_H

#include <QAbstractListModel>
#include <QUuid>

class RfidTagInfo;

class RfidTags : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
    enum Roles {
        RoleInventoryItemId = Qt::UserRole + 1,
        RoleUsername,
        RoleDisplayName,
        RoleEnabled,
        RoleAllowStopCharging,
        RoleTagHash,
        RoleProfile
    };
    Q_ENUM(Roles)

    explicit RfidTags(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    void setTags(const QVariantList &tags);
    void upsertTag(const QVariantMap &tagMap);
    void removeTag(const QUuid &inventoryItemId);

    Q_INVOKABLE RfidTagInfo *get(int index) const;
    Q_INVOKABLE RfidTagInfo *getTagInfo(const QUuid &inventoryItemId) const;

signals:
    void countChanged();

private:
    void connectTag(RfidTagInfo *tagInfo);

    QList<RfidTagInfo *> m_tags;
};

#endif // RFIDTAGS_H
