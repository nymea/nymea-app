// SPDX-License-Identifier: LGPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright (C) 2013 - 2024, nymea GmbH
* Copyright (C) 2024 - 2026, chargebyte austria GmbH
*
* This file is part of libnymea-app.
*
* libnymea-app is free software: you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public License
* as published by the Free Software Foundation, either version 3
* of the License, or (at your option) any later version.
*
* libnymea-app is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License
* along with libnymea-app. If not, see <https://www.gnu.org/licenses/>.
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include "transfersmanager.h"

#include "connection/bluetoothtransport.h"
#include "connection/tcpsockettransport.h"
#include "connection/tunnelproxytransport.h"
#include "connection/websockettransport.h"
#include "jsonrpc/jsonrpcclient.h"

#include <QDir>
#include <QFileInfo>
#include <QJsonDocument>
#include <QtQml/qqmlfile.h>

#include "logging.h"
NYMEA_LOGGING_CATEGORY(dcTransfersManager, "TransfersManager")

namespace {

static const qint64 chunkSize = 64 * 1024;

}

TransfersManager::TransfersManager(JsonRpcClient *client, QObject *parent)
    : QObject(parent)
    , m_client(client)
{
    m_client->registerNotificationHandler(this, "Transfers", "notificationReceived");
    connect(m_client, &JsonRpcClient::connectedChanged, this, &TransfersManager::onClientConnectedChanged);
}

bool TransfersManager::busy() const
{
    return m_busy;
}

qreal TransfersManager::progress() const
{
    if (m_totalBytes <= 0) {
        return 0;
    }

    return qBound<qreal>(0, static_cast<qreal>(m_bytesTransferred) / static_cast<qreal>(m_totalBytes), 1);
}

qint64 TransfersManager::bytesTransferred() const
{
    return m_bytesTransferred;
}

qint64 TransfersManager::totalBytes() const
{
    return m_totalBytes;
}

QString TransfersManager::activeFileName() const
{
    return m_activeFileName;
}

QString TransfersManager::statusText() const
{
    return m_statusText;
}

void TransfersManager::downloadFile(const QString &downloadId, const QUrl &targetUrl)
{
    if (m_busy) {
        emit errorOccurred(tr("Another transfer is already running."));
        return;
    }

    if (!m_client->connected() || !m_client->currentConnection()) {
        emit errorOccurred(tr("Not connected to a nymea server."));
        return;
    }

    const QString localPath = localPathFromUrl(targetUrl);
    if (localPath.isEmpty()) {
        emit errorOccurred(tr("Invalid download target."));
        return;
    }

    if (targetUrl.scheme().isEmpty() || targetUrl.scheme() == "file" || targetUrl.isLocalFile()) {
        QFileInfo fileInfo(localPath);
        if (!QDir().mkpath(fileInfo.absolutePath())) {
            emit errorOccurred(tr("Could not create the selected download directory."));
            return;
        }
    }

    resetTransferState();
    m_transferType = TransferTypeDownload;
    m_downloadId = downloadId;
    m_targetUrl = targetUrl;
    setBusy(true);
    setStatusText(tr("Preparing download..."));

    QVariantMap params;
    params.insert("downloadId", downloadId);
    m_client->sendCommand("Transfers.StartDownload", params, this, "startDownloadReply");
}

void TransfersManager::uploadFile(const QUrl &sourceUrl)
{
    if (m_busy) {
        emit errorOccurred(tr("Another transfer is already running."));
        return;
    }

    if (!m_client->connected() || !m_client->currentConnection()) {
        emit errorOccurred(tr("Not connected to a nymea server."));
        return;
    }

    const QString localPath = localPathFromUrl(sourceUrl);
    if (localPath.isEmpty()) {
        emit errorOccurred(tr("Invalid upload source."));
        return;
    }

    QScopedPointer<QFile> inputFile(new QFile(localPath));
    if (!inputFile->open(QIODevice::ReadOnly)) {
        emit errorOccurred(tr("The selected upload file could not be opened."));
        return;
    }

    QString fileName = sourceUrl.fileName();
    if (fileName.isEmpty()) {
        fileName = QFileInfo(localPath).fileName();
    }

    resetTransferState();
    m_transferType = TransferTypeUpload;
    m_sourceUrl = sourceUrl;
    m_inputFile.reset(inputFile.take());
    setActiveFileName(fileName);
    setBusy(true);
    setProgress(0, m_inputFile->size());
    setStatusText(tr("Preparing upload..."));

    QVariantMap params;
    params.insert("fileName", fileName);
    params.insert("size", m_inputFile->size());
    m_client->sendCommand("Transfers.CreateUpload", params, this, "createUploadReply");
}

void TransfersManager::setBusy(bool busy)
{
    if (m_busy == busy) {
        return;
    }

    m_busy = busy;
    emit busyChanged();
}

void TransfersManager::setActiveFileName(const QString &activeFileName)
{
    if (m_activeFileName == activeFileName) {
        return;
    }

    m_activeFileName = activeFileName;
    emit activeFileNameChanged();
    updateStatusText();
}

void TransfersManager::setStatusText(const QString &statusText)
{
    if (m_statusText == statusText) {
        return;
    }

    m_statusText = statusText;
    emit statusTextChanged();
}

void TransfersManager::setProgress(qint64 bytesTransferred, qint64 totalBytes)
{
    const bool changed = m_bytesTransferred != bytesTransferred || m_totalBytes != totalBytes;
    m_bytesTransferred = bytesTransferred;
    m_totalBytes = totalBytes;
    if (changed) {
        emit progressChanged();
        updateStatusText();
    }
}

void TransfersManager::updateStatusText()
{
    if (!m_busy) {
        setStatusText(QString());
        return;
    }

    if (m_transferType == TransferTypeDownload) {
        if (m_totalBytes > 0 && !m_activeFileName.isEmpty()) {
            setStatusText(tr("Downloading %1 (%2%)").arg(m_activeFileName).arg(qRound(progress() * 100)));
        } else if (!m_activeFileName.isEmpty()) {
            setStatusText(tr("Downloading %1").arg(m_activeFileName));
        }
    } else if (m_transferType == TransferTypeUpload) {
        if (m_totalBytes > 0 && !m_activeFileName.isEmpty()) {
            setStatusText(tr("Uploading %1 (%2%)").arg(m_activeFileName).arg(qRound(progress() * 100)));
        } else if (!m_activeFileName.isEmpty()) {
            setStatusText(tr("Uploading %1").arg(m_activeFileName));
        }
    }
}

void TransfersManager::openTransferConnection()
{
    cleanupTransport();

    m_transport = createTransportForCurrentConnection();
    if (!m_transport) {
        failTransfer(tr("The current connection does not support file transfers."));
        return;
    }

    connect(m_transport, &NymeaTransportInterface::connected, this, &TransfersManager::onTransportConnected);
    connect(m_transport, &NymeaTransportInterface::disconnected, this, &TransfersManager::onTransportDisconnected);
    connect(m_transport, &NymeaTransportInterface::error, this, &TransfersManager::onTransportError);
    connect(m_transport, &NymeaTransportInterface::sslErrors, this, &TransfersManager::onTransportSslErrors);
    connect(m_transport, &NymeaTransportInterface::dataReady, this, &TransfersManager::onTransferDataAvailable);

    if (!m_transport->connect(m_client->currentConnection()->url())) {
        failTransfer(tr("Could not open the transfer connection."));
    }
}

NymeaTransportInterface *TransfersManager::createTransportForCurrentConnection() const
{
    if (!m_client->currentConnection()) {
        return nullptr;
    }

    const QString scheme = m_client->currentConnection()->url().scheme();
    if (scheme == "ws" || scheme == "wss") {
        return new WebsocketTransport(const_cast<TransfersManager *>(this));
    }
    if (scheme == "nymea" || scheme == "nymeas") {
        return new TcpSocketTransport(const_cast<TransfersManager *>(this));
    }
    if (scheme == "tunnel" || scheme == "tunnels") {
        return new TunnelProxyTransport(const_cast<TransfersManager *>(this));
    }
    if (scheme == "rfcom") {
        return new BluetoothTransport(const_cast<TransfersManager *>(this));
    }

    return nullptr;
}

void TransfersManager::cleanupTransport()
{
    if (!m_transport) {
        return;
    }

    disconnect(m_transport, nullptr, this, nullptr);
    m_transport->disconnect();
    m_transport->deleteLater();
    m_transport = nullptr;
    m_receiveBuffer.clear();
    m_pendingTransferCommands.clear();
}

void TransfersManager::cleanupFiles()
{
    if (m_outputFile) {
        if (m_outputFile->isOpen()) {
            m_outputFile->close();
        }
        m_outputFile.reset();
    }

    if (m_inputFile) {
        if (m_inputFile->isOpen()) {
            m_inputFile->close();
        }
        m_inputFile.reset();
    }
}

void TransfersManager::resetTransferState()
{
    cleanupTransport();
    cleanupFiles();

    m_transferType = TransferTypeNone;
    m_downloadId.clear();
    m_targetUrl = QUrl();
    m_sourceUrl = QUrl();
    m_transferId.clear();
    m_transferToken.clear();
    setActiveFileName(QString());
    setProgress(0, 0);
    setStatusText(QString());
    setBusy(false);
}

void TransfersManager::sendTransferCommand(const QString &method, const QVariantMap &params, PendingTransferCommand command)
{
    if (!m_transport) {
        failTransfer(tr("Transfer connection is not available."));
        return;
    }

    ++m_transferCommandId;
    QVariantMap request;
    request.insert("id", m_transferCommandId);
    request.insert("method", method);
    if (!params.isEmpty()) {
        request.insert("params", params);
    }

    m_pendingTransferCommands.insert(m_transferCommandId, command);
    m_transport->sendData(QJsonDocument::fromVariant(request).toJson(QJsonDocument::Compact) + "\n");
}

void TransfersManager::requestNextDownloadChunk()
{
    QVariantMap params;
    params.insert("maxBytes", chunkSize);
    sendTransferCommand("Transfer.RequestChunk", params, PendingTransferCommandRequestChunk);
}

void TransfersManager::uploadNextChunk()
{
    if (!m_inputFile) {
        failTransfer(tr("Upload source is not available."));
        return;
    }

    const QByteArray data = m_inputFile->read(chunkSize);
    if (data.isEmpty()) {
        if (m_inputFile->atEnd()) {
            sendTransferCommand("Transfer.FinishUpload", QVariantMap(), PendingTransferCommandFinishUpload);
        } else {
            failTransfer(tr("Failed to read the upload file."));
        }
        return;
    }

    QVariantMap params;
    params.insert("data", data.toBase64());
    sendTransferCommand("Transfer.UploadChunk", params, PendingTransferCommandUploadChunk);
}

void TransfersManager::finishDownload()
{
    const QString downloadId = m_downloadId;
    const QUrl targetUrl = m_targetUrl;

    if (!m_outputFile) {
        failTransfer(tr("Download target is not available."));
        return;
    }

    cleanupTransport();
    if (m_outputFile->isOpen()) {
        m_outputFile->close();
    }
    m_outputFile.reset();
    setBusy(false);
    setStatusText(QString());

    m_transferType = TransferTypeNone;
    m_transferId.clear();
    m_transferToken.clear();

    emit downloadFinished(downloadId, targetUrl);
    resetTransferState();
}

void TransfersManager::finishUpload(const QVariantMap &params)
{
    const QString downloadId = params.value("downloadId").toString();
    const QString fileName = params.value("fileName").toString();
    const qint64 size = params.value("size").toLongLong();

    cleanupTransport();
    cleanupFiles();
    setBusy(false);
    setStatusText(QString());

    emit uploadFinished(downloadId, fileName, size);
    resetTransferState();
}

void TransfersManager::failTransfer(const QString &errorString)
{
    qCWarning(dcTransfersManager()) << "Transfer failed:" << errorString;

    const TransferType transferType = m_transferType;
    const QString downloadId = m_downloadId;
    const QString activeFileName = m_activeFileName;

    cleanupTransport();
    cleanupFiles();
    emit errorOccurred(errorString);

    if (transferType == TransferTypeDownload) {
        emit downloadFailed(downloadId, errorString);
    } else if (transferType == TransferTypeUpload) {
        emit uploadFailed(activeFileName, errorString);
    }

    resetTransferState();
}

QString TransfersManager::localPathFromUrl(const QUrl &url) const
{
    if (!url.isValid()) {
        return QString();
    }

    return QQmlFile::urlToLocalFileOrQrc(url);
}

void TransfersManager::startDownloadReply(int commandId, const QVariantMap &params)
{
    Q_UNUSED(commandId)

    if (m_transferType != TransferTypeDownload) {
        return;
    }

    m_transferId = params.value("transferId").toString();
    m_transferToken = params.value("transferToken").toString();
    setActiveFileName(params.value("fileName").toString());
    setProgress(0, params.value("size").toLongLong());

    if (m_transferId.isEmpty() || m_transferToken.isEmpty()) {
        failTransfer(tr("The server rejected the download request."));
        return;
    }

    openTransferConnection();
}

void TransfersManager::createUploadReply(int commandId, const QVariantMap &params)
{
    Q_UNUSED(commandId)

    if (m_transferType != TransferTypeUpload) {
        return;
    }

    m_transferId = params.value("transferId").toString();
    m_transferToken = params.value("transferToken").toString();
    if (m_activeFileName.isEmpty()) {
        setActiveFileName(params.value("fileName").toString());
    }
    if (m_totalBytes <= 0) {
        setProgress(0, params.value("size").toLongLong());
    }

    if (m_transferId.isEmpty() || m_transferToken.isEmpty()) {
        failTransfer(tr("The server rejected the upload request."));
        return;
    }

    if (!m_inputFile) {
        failTransfer(tr("Could not open the selected upload file."));
        return;
    }

    if (!m_inputFile->isOpen() && !m_inputFile->open(QIODevice::ReadOnly)) {
        failTransfer(tr("Could not open the selected upload file."));
        return;
    }

    openTransferConnection();
}

void TransfersManager::notificationReceived(const QVariantMap &notification)
{
    qCDebug(dcTransfersManager()) << "Transfers notification received" << qUtf8Printable(QJsonDocument::fromVariant(notification).toJson());

    const QString notif = notification.value("notification").toString();
    const QVariantMap params = notification.value("params").toMap();
    if (notif == "Transfers.DownloadAvailable") {
        emit downloadAvailable(params.value("downloadId").toString(),
                               params.value("fileName").toString(),
                               params.value("size").toLongLong());
    }
}

void TransfersManager::onClientConnectedChanged(bool connected)
{
    if (!connected && m_busy) {
        failTransfer(tr("The server connection was lost."));
    }
}

void TransfersManager::onTransportConnected()
{
    setStatusText(tr("Connecting transfer..."));

    QVariantMap params;
    params.insert("transferId", m_transferId);
    params.insert("transferToken", m_transferToken);
    sendTransferCommand("Transfer.Connect", params, PendingTransferCommandConnect);
}

void TransfersManager::onTransportDisconnected()
{
    if (m_busy) {
        failTransfer(tr("The transfer connection was closed unexpectedly."));
    }
}

void TransfersManager::onTransportError(QAbstractSocket::SocketError error)
{
    Q_UNUSED(error)
    failTransfer(tr("The transfer connection reported an error."));
}

void TransfersManager::onTransportSslErrors(const QList<QSslError> &errors)
{
    if (!m_transport) {
        return;
    }

    QList<QSslError> ignoredErrors;
    for (const QSslError &error : errors) {
        if (error.error() == QSslError::HostNameMismatch
                || error.error() == QSslError::SelfSignedCertificate
                || error.error() == QSslError::CertificateUntrusted) {
            ignoredErrors.append(error);
        }
    }

    if (ignoredErrors.count() == errors.count()) {
        m_transport->ignoreSslErrors(ignoredErrors);
        return;
    }

    failTransfer(tr("The transfer connection could not be secured."));
}

void TransfersManager::onTransferDataAvailable(const QByteArray &data)
{
    m_receiveBuffer.append(data);

    int splitIndex = static_cast<int>(m_receiveBuffer.indexOf("}\n{")) + 1;
    if (splitIndex <= 0) {
        splitIndex = m_receiveBuffer.length();
    }

    QJsonParseError error;
    const QJsonDocument jsonDoc = QJsonDocument::fromJson(m_receiveBuffer.left(splitIndex), &error);
    if (error.error != QJsonParseError::NoError) {
        return;
    }

    m_receiveBuffer = m_receiveBuffer.right(m_receiveBuffer.length() - splitIndex - 1);
    if (!m_receiveBuffer.isEmpty()) {
        staticMetaObject.invokeMethod(this, "onTransferDataAvailable", Qt::QueuedConnection, Q_ARG(QByteArray, QByteArray()));
    }

    const QVariantMap response = jsonDoc.toVariant().toMap();
    const int commandId = response.value("id").toInt();
    const PendingTransferCommand command = m_pendingTransferCommands.take(commandId);

    if (response.value("status").toString() == "error") {
        failTransfer(response.value("error").toString().isEmpty() ? tr("The transfer failed.") : response.value("error").toString());
        return;
    }

    const QVariantMap params = response.value("params").toMap();
    switch (command) {
    case PendingTransferCommandConnect: {
        const QString direction = params.value("direction").toString();
        setActiveFileName(params.value("fileName").toString());
        const qint64 size = params.value("size").toLongLong();
        const qint64 offset = params.value("offset").toLongLong();
        if (m_transferType == TransferTypeDownload) {
            if (direction != "download") {
                failTransfer(tr("The server returned an unexpected transfer direction."));
                return;
            }

            if (offset != 0) {
                failTransfer(tr("Resuming downloads is not supported yet."));
                return;
            }

            setProgress(offset, size);
            m_outputFile.reset(new QFile(localPathFromUrl(m_targetUrl)));
            if (!m_outputFile->open(QIODevice::WriteOnly)) {
                failTransfer(tr("Could not open the selected download target."));
                return;
            }

            requestNextDownloadChunk();
        } else if (m_transferType == TransferTypeUpload) {
            if (direction != "upload") {
                failTransfer(tr("The server returned an unexpected transfer direction."));
                return;
            }

            if (!m_inputFile) {
                failTransfer(tr("Upload source is not available."));
                return;
            }

            if (!m_inputFile->seek(offset)) {
                failTransfer(tr("Could not resume the upload file."));
                return;
            }

            setProgress(offset, size);
            uploadNextChunk();
        }
        break;
    }
    case PendingTransferCommandRequestChunk: {
        if (!m_outputFile) {
            failTransfer(tr("Download target is not available."));
            return;
        }

        const QByteArray chunk = QByteArray::fromBase64(params.value("data").toByteArray());
        const bool finished = params.value("finished").toBool();

        if (m_outputFile->write(chunk) != chunk.length()) {
            failTransfer(tr("Could not write the downloaded data."));
            return;
        }

        setProgress(m_bytesTransferred + chunk.length(), m_totalBytes);
        if (finished) {
            finishDownload();
        } else if (!chunk.isEmpty()) {
            requestNextDownloadChunk();
        } else {
            failTransfer(tr("The server returned an empty download chunk."));
        }
        break;
    }
    case PendingTransferCommandUploadChunk:
        setProgress(params.value("bytesReceived").toLongLong(), m_totalBytes);
        uploadNextChunk();
        break;
    case PendingTransferCommandFinishUpload:
        finishUpload(params);
        break;
    case PendingTransferCommandNone:
    default:
        qCWarning(dcTransfersManager()) << "Unexpected transfer response" << response;
        break;
    }
}
