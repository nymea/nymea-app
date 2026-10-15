// SPDX-License-Identifier: GPL-3.0-or-later

#include "rfidmanager.h"

#include "rfidtaginfo.h"

#include <QJsonDocument>
#include <QMetaEnum>

#include <logging.h>

NYMEA_LOGGING_CATEGORY(dcRfidExperience, "RfidExperience")

RfidManager::RfidManager(QObject *parent)
    : QObject(parent),
      m_tags(new RfidTags(this))
{
}

RfidManager::~RfidManager()
{
    if (m_engine)
        m_engine->jsonRpcClient()->unregisterNotificationHandler(this);
}

Engine *RfidManager::engine() const
{
    return m_engine;
}

void RfidManager::setEngine(Engine *engine)
{
    if (m_engine == engine)
        return;

    if (m_engine)
        m_engine->jsonRpcClient()->unregisterNotificationHandler(this);

    m_engine = engine;
    emit engineChanged();

    if (!m_engine)
        return;

    connect(engine, &Engine::destroyed, this, [engine, this]() {
        if (m_engine == engine)
            m_engine = nullptr;
    });

    m_engine->jsonRpcClient()->registerNotificationHandler(this, "Rfid", "notificationReceived");
    refreshTags();
    refreshConfig();
}

RfidTags *RfidManager::tags() const
{
    return m_tags;
}

int RfidManager::plugInTimeout() const
{
    return m_plugInTimeout;
}

int RfidManager::authorizationTimeout() const
{
    return m_authorizationTimeout;
}

int RfidManager::enrollmentTimeout() const
{
    return m_enrollmentTimeout;
}

int RfidManager::refreshTags(const QString &username)
{
    QVariantMap params;
    if (!username.trimmed().isEmpty())
        params.insert("username", username.trimmed());

    return m_engine->jsonRpcClient()->sendCommand("Rfid.GetTags", params, this, "getTagsResponse");
}

int RfidManager::addTag(const QString &username, const QString &code, const QString &displayName, bool enabled, bool allowStopCharging, const QVariantMap &profile)
{
    QVariantMap params;
    params.insert("username", username.trimmed());
    params.insert("code", code);

    if (!displayName.trimmed().isEmpty())
        params.insert("displayName", displayName.trimmed());

    params.insert("enabled", enabled);
    params.insert("allowStopCharging", allowStopCharging);

    if (!profile.isEmpty())
        params.insert("profile", profile);

    return m_engine->jsonRpcClient()->sendCommand("Rfid.AddTag", params, this, "addTagResponse");
}

int RfidManager::updateTag(const QUuid &inventoryItemId, const QString &displayName, bool enabled, bool allowStopCharging, const QVariantMap &profile)
{
    QVariantMap params;
    params.insert("inventoryItemId", inventoryItemId);
    params.insert("displayName", displayName.trimmed());
    params.insert("enabled", enabled);
    params.insert("allowStopCharging", allowStopCharging);
    params.insert("profile", profile);
    return m_engine->jsonRpcClient()->sendCommand("Rfid.UpdateTag", params, this, "updateTagResponse");
}

int RfidManager::removeTag(const QUuid &inventoryItemId)
{
    return m_engine->jsonRpcClient()->sendCommand("Rfid.RemoveTag", {{"inventoryItemId", inventoryItemId}}, this, "removeTagResponse");
}

int RfidManager::startEnrollment(const QUuid &thingId, const QString &username, const QString &displayName, bool enabled, bool allowStopCharging, const QVariantMap &profile)
{
    QVariantMap params;
    params.insert("thingId", thingId);
    params.insert("username", username.trimmed());

    if (!displayName.trimmed().isEmpty())
        params.insert("displayName", displayName.trimmed());

    params.insert("enabled", enabled);
    params.insert("allowStopCharging", allowStopCharging);

    if (!profile.isEmpty())
        params.insert("profile", profile);

    return m_engine->jsonRpcClient()->sendCommand("Rfid.StartEnrollment", params, this, "startEnrollmentResponse");
}

int RfidManager::cancelEnrollment(const QUuid &enrollmentId)
{
    return m_engine->jsonRpcClient()->sendCommand("Rfid.CancelEnrollment", {{"enrollmentId", enrollmentId}}, this, "cancelEnrollmentResponse");
}

int RfidManager::refreshConfig()
{
    return m_engine->jsonRpcClient()->sendCommand("Rfid.GetConfig", {}, this, "getConfigResponse");
}

int RfidManager::setConfig(int plugInTimeout, int authorizationTimeout, int enrollmentTimeout)
{
    QVariantMap params;
    params.insert("plugInTimeout", plugInTimeout);
    params.insert("authorizationTimeout", authorizationTimeout);
    params.insert("enrollmentTimeout", enrollmentTimeout);
    return m_engine->jsonRpcClient()->sendCommand("Rfid.SetConfig", params, this, "setConfigResponse");
}

void RfidManager::notificationReceived(const QVariantMap &data)
{
    const QString notification = data.value("notification").toString();
    const QVariantMap params = data.value("params").toMap();

    if (notification == "Rfid.TagAdded" || notification == "Rfid.TagChanged") {
        const QVariantMap tagMap = extractTagMap(params);
        if (!tagMap.isEmpty())
            m_tags->upsertTag(tagMap);
    } else if (notification == "Rfid.TagRemoved") {
        const QUuid inventoryItemId = params.value("inventoryItemId").toUuid();
        if (!inventoryItemId.isNull())
            m_tags->removeTag(inventoryItemId);
    } else if (notification == "Rfid.ConfigChanged") {
        applyConfig(params);
    } else if (notification == "Rfid.EnrollmentFinished") {
        const QUuid enrollmentId = params.value("enrollmentId").toUuid();
        const QUuid thingId = params.value("thingId").toUuid();
        const RfidError error = parseError(params);
        const QVariantMap tagMap = extractTagMap(params);
        RfidTagInfo *tagInfo = nullptr;
        if (!tagMap.isEmpty()) {
            m_tags->upsertTag(tagMap);
            tagInfo = m_tags->getTagInfo(tagMap.value("inventoryItemId").toUuid());
        }
        emit enrollmentFinished(enrollmentId, thingId, error, tagInfo);
    } else if (notification == "Rfid.EnrollmentCanceled") {
        emit enrollmentCanceled(params.value("enrollmentId").toUuid(), params.value("thingId").toUuid());
    } else if (notification == "Rfid.EnrollmentTimedOut") {
        emit enrollmentTimedOut(params.value("enrollmentId").toUuid(), params.value("thingId").toUuid());
    } else if (notification == "Rfid.Authorized" || notification == "Rfid.Denied") {
        qCDebug(dcRfidExperience()) << "RFID authorization notification:" << qUtf8Printable(QJsonDocument::fromVariant(params).toJson(QJsonDocument::Compact));
    } else {
        qCDebug(dcRfidExperience()) << "Unhandled notification received" << data;
    }
}

void RfidManager::getTagsResponse(int commandId, const QVariantMap &params)
{
    qCDebug(dcRfidExperience()) << "GetTags response:" << commandId << qUtf8Printable(QJsonDocument::fromVariant(params).toJson(QJsonDocument::Compact));
    const RfidError error = parseError(params);
    emit refreshTagsReply(commandId, error);
    if (error == RfidErrorNoError)
        m_tags->setTags(params.value("tags").toList());
}

void RfidManager::addTagResponse(int commandId, const QVariantMap &params)
{
    qCDebug(dcRfidExperience()) << "AddTag response:" << commandId << params;
    emit addTagReply(commandId, parseError(params));
}

void RfidManager::updateTagResponse(int commandId, const QVariantMap &params)
{
    qCDebug(dcRfidExperience()) << "UpdateTag response:" << commandId << params;
    emit updateTagReply(commandId, parseError(params));
}

void RfidManager::removeTagResponse(int commandId, const QVariantMap &params)
{
    qCDebug(dcRfidExperience()) << "RemoveTag response:" << commandId << params;
    emit removeTagReply(commandId, parseError(params));
}

void RfidManager::startEnrollmentResponse(int commandId, const QVariantMap &params)
{
    qCDebug(dcRfidExperience()) << "StartEnrollment response:" << commandId << params;
    emit startEnrollmentReply(commandId, parseError(params), params.value("enrollmentId").toUuid(), params.value("expiresAt").toString());
}

void RfidManager::cancelEnrollmentResponse(int commandId, const QVariantMap &params)
{
    qCDebug(dcRfidExperience()) << "CancelEnrollment response:" << commandId << params;
    emit cancelEnrollmentReply(commandId, parseError(params));
}

void RfidManager::getConfigResponse(int commandId, const QVariantMap &params)
{
    qCDebug(dcRfidExperience()) << "GetConfig response:" << commandId << params;
    const RfidError error = parseError(params);
    if (error == RfidErrorNoError)
        applyConfig(params);
    emit getConfigReply(commandId, error);
}

void RfidManager::setConfigResponse(int commandId, const QVariantMap &params)
{
    qCDebug(dcRfidExperience()) << "SetConfig response:" << commandId << params;
    const RfidError error = parseError(params);
    if (error == RfidErrorNoError)
        applyConfig(params);
    emit setConfigReply(commandId, error);
}

QVariantMap RfidManager::extractTagMap(const QVariantMap &params) const
{
    if (params.value("tag").canConvert<QVariantMap>())
        return params.value("tag").toMap();

    if (params.value("rfidTag").canConvert<QVariantMap>())
        return params.value("rfidTag").toMap();

    if (params.contains("inventoryItemId"))
        return params;

    return QVariantMap();
}

void RfidManager::applyConfig(const QVariantMap &params)
{
    bool changed = false;

    if (params.contains("plugInTimeout")) {
        const int value = params.value("plugInTimeout").toInt();
        if (value != m_plugInTimeout) {
            m_plugInTimeout = value;
            changed = true;
        }
    }

    if (params.contains("authorizationTimeout")) {
        const int value = params.value("authorizationTimeout").toInt();
        if (value != m_authorizationTimeout) {
            m_authorizationTimeout = value;
            changed = true;
        }
    }

    if (params.contains("enrollmentTimeout")) {
        const int value = params.value("enrollmentTimeout").toInt();
        if (value != m_enrollmentTimeout) {
            m_enrollmentTimeout = value;
            changed = true;
        }
    }

    if (changed)
        emit configChanged();
}

RfidManager::RfidError RfidManager::parseError(const QVariantMap &params) const
{
    const QString errorString = params.value("rfidError").toString();
    if (errorString.isEmpty())
        return RfidErrorNoError;

    const QMetaEnum metaEnum = QMetaEnum::fromType<RfidError>();
    const int value = metaEnum.keyToValue(errorString.toUtf8().constData());
    if (value < 0)
        return RfidErrorBackendError;

    return static_cast<RfidError>(value);
}
