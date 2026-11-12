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

#include "nfchelper.h"

#include <logging.h>

#include <QMetaEnum>
#include <QNearFieldManager>
#include <QNearFieldTarget>

NYMEA_LOGGING_CATEGORY(dcNfcHelper, "NfcHelper")

namespace {

QString tagTypeName(QNearFieldTarget::Type type)
{
    switch (type) {
    case QNearFieldTarget::ProprietaryTag:
        return NfcHelper::tr("Proprietary tag");
    case QNearFieldTarget::NfcTagType1:
        return NfcHelper::tr("NFC tag type 1");
    case QNearFieldTarget::NfcTagType2:
        return NfcHelper::tr("NFC tag type 2");
    case QNearFieldTarget::NfcTagType3:
        return NfcHelper::tr("NFC tag type 3");
    case QNearFieldTarget::NfcTagType4:
        return NfcHelper::tr("NFC tag type 4");
    case QNearFieldTarget::NfcTagType4A:
        return NfcHelper::tr("NFC tag type 4A");
    case QNearFieldTarget::NfcTagType4B:
        return NfcHelper::tr("NFC tag type 4B");
    case QNearFieldTarget::MifareTag:
        return NfcHelper::tr("MIFARE tag");
    }
    return NfcHelper::tr("Unknown");
}

}

NfcHelper::NfcHelper(QObject *parent):
    QObject(parent),
    m_manager(new QNearFieldManager(this))
{
    qCInfo(dcNfcHelper()) << "NFC helper initialized: enabled=" << isAvailable()
                          << "tag-specific access supported="
                          << m_manager->isSupported(QNearFieldTarget::TagTypeSpecificAccess);

    connect(m_manager, &QNearFieldManager::targetDetected,
            this, &NfcHelper::targetDetected);
    connect(m_manager, &QNearFieldManager::targetLost, this, [](QNearFieldTarget *target) {
        qCInfo(dcNfcHelper()) << "NFC target lost: uid="
                              << (target ? NfcHelper::formatUid(target->uid()) : QStringLiteral("<null>"));
    });

#if QT_VERSION >= QT_VERSION_CHECK(6, 2, 0)
    connect(m_manager, &QNearFieldManager::adapterStateChanged,
            this, &NfcHelper::isAvailableChanged);
    connect(m_manager, &QNearFieldManager::adapterStateChanged, this,
            [this](QNearFieldManager::AdapterState state) {
        const QMetaEnum metaEnum = QMetaEnum::fromType<QNearFieldManager::AdapterState>();
        qCInfo(dcNfcHelper()) << "NFC adapter state changed:"
                              << metaEnum.valueToKey(static_cast<int>(state))
                              << "enabled=" << isAvailable();
    });
    connect(m_manager, &QNearFieldManager::targetDetectionStopped, this, [this]() {
        qCInfo(dcNfcHelper()) << "NFC target detection stopped; scanning was" << m_scanning;
        setScanning(false);
    });
#endif
}

NfcHelper *NfcHelper::instance()
{
    static NfcHelper *thiz = nullptr;
    if (!thiz) {
        thiz = new NfcHelper();
    }
    return thiz;
}

QObject *NfcHelper::nfcHelperProvider(QQmlEngine */*engine*/, QJSEngine */*scriptEngine*/)
{
    return instance();
}

bool NfcHelper::isAvailable() const
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    return m_manager->isAvailable();
#else
    return m_manager->isEnabled();
#endif
}

bool NfcHelper::tagUidScanningAvailable() const
{
#if defined(Q_OS_ANDROID)
    return isAvailable()
            && m_manager->isSupported(QNearFieldTarget::TagTypeSpecificAccess);
#else
    return false;
#endif
}

bool NfcHelper::scanning() const
{
    return m_scanning;
}

QString NfcHelper::formatUid(const QByteArray &uid)
{
    const QByteArray hex = uid.toHex().toUpper();
    QStringList bytes;
    bytes.reserve(uid.size());
    for (qsizetype index = 0; index < hex.size(); index += 2)
        bytes.append(QString::fromLatin1(hex.mid(index, 2)));
    return bytes.join(QLatin1Char(':'));
}

QString NfcHelper::tagCode(const QByteArray &uid)
{
    return QString::fromLatin1(uid.toHex());
}

bool NfcHelper::startTagUidScan()
{
    qCInfo(dcNfcHelper()) << "NFC UID scan requested: scanning=" << m_scanning
                          << "enabled=" << isAvailable()
                          << "tag-specific access supported="
                          << m_manager->isSupported(QNearFieldTarget::TagTypeSpecificAccess);

    if (m_scanning) {
        qCInfo(dcNfcHelper()) << "NFC UID scan is already running";
        return true;
    }

    if (!tagUidScanningAvailable()) {
        qCWarning(dcNfcHelper()) << "Cannot start NFC UID scan: scanning is not available";
        emit scanFailed(tr("NFC tag scanning is not available."));
        return false;
    }

#if defined(Q_OS_ANDROID)
#if QT_VERSION >= QT_VERSION_CHECK(6, 2, 0)
    m_manager->setUserInformation(tr("Hold the RFID tag near the phone."));
#endif
    if (!m_manager->startTargetDetection(QNearFieldTarget::TagTypeSpecificAccess)) {
        qCWarning(dcNfcHelper()) << "QNearFieldManager rejected the NFC UID scan request";
        emit scanFailed(tr("Could not start NFC tag scanning."));
        return false;
    }

    qCInfo(dcNfcHelper()) << "NFC UID scan started";
    setScanning(true);
    return true;
#else
    qCWarning(dcNfcHelper()) << "Cannot start NFC UID scan on this platform";
    emit scanFailed(tr("NFC tag scanning is not available."));
    return false;
#endif
}

void NfcHelper::stopTagUidScan()
{
    if (!m_scanning) {
        qCDebug(dcNfcHelper()) << "Ignoring NFC UID scan stop request: no scan is running";
        return;
    }

    qCInfo(dcNfcHelper()) << "Stopping NFC UID scan";
    m_manager->stopTargetDetection();
    setScanning(false);
}

void NfcHelper::setScanning(bool scanning)
{
    if (m_scanning == scanning)
        return;

    qCInfo(dcNfcHelper()) << "NFC UID scanning state changed from" << m_scanning << "to" << scanning;
    m_scanning = scanning;
    emit scanningChanged();
}

void NfcHelper::targetDetected(QNearFieldTarget *target)
{
    if (!target) {
        qCWarning(dcNfcHelper()) << "QNearFieldManager reported a null NFC target";
        return;
    }

    qCInfo(dcNfcHelper()) << "NFC target detected: scanning=" << m_scanning
                          << "uid=" << formatUid(target->uid())
                          << "type=" << tagTypeName(target->type())
                          << "access methods=0x"
                          << QString::number(static_cast<int>(target->accessMethods()), 16);

    if (!m_scanning) {
        qCWarning(dcNfcHelper()) << "Ignoring NFC target because no UID scan is active";
        return;
    }

    const QByteArray uid = target->uid();
    if (uid.isEmpty()) {
        qCWarning(dcNfcHelper()) << "NFC target has an empty UID";
        m_manager->stopTargetDetection(tr("The RFID tag UID could not be read."));
        setScanning(false);
        emit scanFailed(tr("The RFID tag UID could not be read."));
        return;
    }

    const QVariantMap information = tagInformation(target);
    qCInfo(dcNfcHelper()) << "NFC tag information ready for QML:" << information;
    stopTagUidScan();
    emit tagDetected(information);
    qCInfo(dcNfcHelper()) << "NFC tagDetected signal emitted";
}

QVariantMap NfcHelper::tagInformation(QNearFieldTarget *target) const
{
    const QNearFieldTarget::AccessMethods accessMethods = target->accessMethods();
    QStringList accessMethodNames;
    if (accessMethods.testFlag(QNearFieldTarget::NdefAccess))
        accessMethodNames.append(tr("NDEF"));
    if (accessMethods.testFlag(QNearFieldTarget::TagTypeSpecificAccess))
        accessMethodNames.append(tr("Tag-specific"));
    if (accessMethodNames.isEmpty())
        accessMethodNames.append(tr("Unknown"));

    QVariantMap information;
    information.insert(QStringLiteral("uid"), formatUid(target->uid()));
    information.insert(QStringLiteral("code"), tagCode(target->uid()));
    information.insert(QStringLiteral("tagType"), tagTypeName(target->type()));
    information.insert(QStringLiteral("accessMethods"), accessMethodNames);
    information.insert(QStringLiteral("hasNdefMessage"), target->hasNdefMessage());

    const int maxCommandLength = target->maxCommandLength();
    if (maxCommandLength > 0)
        information.insert(QStringLiteral("maxCommandLength"), maxCommandLength);

    return information;
}
