// SPDX-License-Identifier: GPL-3.0-or-later

#ifndef RFIDMANAGER_H
#define RFIDMANAGER_H

#include <QObject>
#include <QUuid>

#include <engine.h>

#include "rfidtags.h"

class RfidManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(Engine *engine READ engine WRITE setEngine NOTIFY engineChanged)
    Q_PROPERTY(RfidTags *tags READ tags CONSTANT)
    Q_PROPERTY(int plugInTimeout READ plugInTimeout NOTIFY configChanged)
    Q_PROPERTY(int authorizationTimeout READ authorizationTimeout NOTIFY configChanged)
    Q_PROPERTY(int enrollmentTimeout READ enrollmentTimeout NOTIFY configChanged)

public:
    enum RfidError {
        RfidErrorNoError = 0,
        RfidErrorBackendError,
        RfidErrorInvalidParameter,
        RfidErrorUserNotFound,
        RfidErrorTagNotFound,
        RfidErrorDuplicateTag,
        RfidErrorInvalidProfile,
        RfidErrorEnrollmentActive,
        RfidErrorEnrollmentNotFound
    };
    Q_ENUM(RfidError)

    explicit RfidManager(QObject *parent = nullptr);
    ~RfidManager();

    Engine *engine() const;
    void setEngine(Engine *engine);

    RfidTags *tags() const;

    int plugInTimeout() const;
    int authorizationTimeout() const;
    int enrollmentTimeout() const;

    Q_INVOKABLE int refreshTags(const QString &username = QString());
    Q_INVOKABLE int addTag(const QString &username, const QString &code, const QString &displayName, bool enabled, bool allowStopCharging, const QVariantMap &profile);
    Q_INVOKABLE int updateTag(const QUuid &inventoryItemId, const QString &displayName, bool enabled, bool allowStopCharging, const QVariantMap &profile);
    Q_INVOKABLE int removeTag(const QUuid &inventoryItemId);
    Q_INVOKABLE int startEnrollment(const QUuid &thingId, const QString &username, const QString &displayName, bool enabled, bool allowStopCharging, const QVariantMap &profile);
    Q_INVOKABLE int cancelEnrollment(const QUuid &enrollmentId);

    Q_INVOKABLE int refreshConfig();
    Q_INVOKABLE int setConfig(int plugInTimeout, int authorizationTimeout, int enrollmentTimeout);

signals:
    void engineChanged();
    void configChanged();

    void refreshTagsReply(int commandId, RfidManager::RfidError error);
    void addTagReply(int commandId, RfidManager::RfidError error);
    void updateTagReply(int commandId, RfidManager::RfidError error);
    void removeTagReply(int commandId, RfidManager::RfidError error);
    void startEnrollmentReply(int commandId, RfidManager::RfidError error, const QUuid &enrollmentId, const QString &expiresAt);
    void cancelEnrollmentReply(int commandId, RfidManager::RfidError error);
    void getConfigReply(int commandId, RfidManager::RfidError error);
    void setConfigReply(int commandId, RfidManager::RfidError error);
    void enrollmentFinished(const QUuid &enrollmentId, const QUuid &thingId, RfidManager::RfidError error, RfidTagInfo *tagInfo);
    void enrollmentCanceled(const QUuid &enrollmentId, const QUuid &thingId);
    void enrollmentTimedOut(const QUuid &enrollmentId, const QUuid &thingId);

private slots:
    void notificationReceived(const QVariantMap &data);
    void getTagsResponse(int commandId, const QVariantMap &params);
    void addTagResponse(int commandId, const QVariantMap &params);
    void updateTagResponse(int commandId, const QVariantMap &params);
    void removeTagResponse(int commandId, const QVariantMap &params);
    void startEnrollmentResponse(int commandId, const QVariantMap &params);
    void cancelEnrollmentResponse(int commandId, const QVariantMap &params);
    void getConfigResponse(int commandId, const QVariantMap &params);
    void setConfigResponse(int commandId, const QVariantMap &params);

private:
    QVariantMap extractTagMap(const QVariantMap &params) const;
    RfidError parseError(const QVariantMap &params) const;
    void applyConfig(const QVariantMap &params);

    Engine *m_engine = nullptr;
    RfidTags *m_tags = nullptr;
    int m_plugInTimeout = 0;
    int m_authorizationTimeout = 0;
    int m_enrollmentTimeout = 0;
};

#endif // RFIDMANAGER_H
