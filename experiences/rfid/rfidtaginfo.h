// SPDX-License-Identifier: GPL-3.0-or-later

#ifndef RFIDTAGINFO_H
#define RFIDTAGINFO_H

#include <QObject>
#include <QUuid>
#include <QVariantMap>

class RfidTagInfo : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUuid inventoryItemId READ inventoryItemId WRITE setInventoryItemId NOTIFY inventoryItemIdChanged)
    Q_PROPERTY(QString username READ username WRITE setUsername NOTIFY usernameChanged)
    Q_PROPERTY(QString displayName READ displayName WRITE setDisplayName NOTIFY displayNameChanged)
    Q_PROPERTY(bool enabled READ enabled WRITE setEnabled NOTIFY enabledChanged)
    Q_PROPERTY(bool allowStopCharging READ allowStopCharging WRITE setAllowStopCharging NOTIFY allowStopChargingChanged)
    Q_PROPERTY(QString tagHash READ tagHash WRITE setTagHash NOTIFY tagHashChanged)
    Q_PROPERTY(QVariantMap profile READ profile WRITE setProfile NOTIFY profileChanged)

public:
    explicit RfidTagInfo(QObject *parent = nullptr);

    QUuid inventoryItemId() const;
    void setInventoryItemId(const QUuid &inventoryItemId);

    QString username() const;
    void setUsername(const QString &username);

    QString displayName() const;
    void setDisplayName(const QString &displayName);

    bool enabled() const;
    void setEnabled(bool enabled);

    bool allowStopCharging() const;
    void setAllowStopCharging(bool allowStopCharging);

    QString tagHash() const;
    void setTagHash(const QString &tagHash);

    QVariantMap profile() const;
    void setProfile(const QVariantMap &profile);

    void updateFromVariantMap(const QVariantMap &tagMap);

signals:
    void inventoryItemIdChanged();
    void usernameChanged();
    void displayNameChanged();
    void enabledChanged();
    void allowStopChargingChanged();
    void tagHashChanged();
    void profileChanged();

private:
    QUuid m_inventoryItemId;
    QString m_username;
    QString m_displayName;
    bool m_enabled = true;
    bool m_allowStopCharging = true;
    QString m_tagHash;
    QVariantMap m_profile;
};

#endif // RFIDTAGINFO_H
