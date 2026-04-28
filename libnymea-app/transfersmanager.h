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

#ifndef TRANSFERSMANAGER_H
#define TRANSFERSMANAGER_H

#include <QAbstractSocket>
#include <QHash>
#include <QObject>
#include <QScopedPointer>
#include <QSslError>
#include <QUrl>
#include <QFile>
#include <QVariantMap>

class JsonRpcClient;
class NymeaTransportInterface;

class TransfersManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool busy READ busy NOTIFY busyChanged)
    Q_PROPERTY(qreal progress READ progress NOTIFY progressChanged)
    Q_PROPERTY(qint64 bytesTransferred READ bytesTransferred NOTIFY progressChanged)
    Q_PROPERTY(qint64 totalBytes READ totalBytes NOTIFY progressChanged)
    Q_PROPERTY(QString activeFileName READ activeFileName NOTIFY activeFileNameChanged)
    Q_PROPERTY(QString statusText READ statusText NOTIFY statusTextChanged)

public:
    explicit TransfersManager(JsonRpcClient *client, QObject *parent = nullptr);

    bool busy() const;
    qreal progress() const;
    qint64 bytesTransferred() const;
    qint64 totalBytes() const;
    QString activeFileName() const;
    QString statusText() const;

    Q_INVOKABLE void downloadFile(const QString &downloadId, const QUrl &targetUrl);
    Q_INVOKABLE void uploadFile(const QUrl &sourceUrl);
    void uploadFileWithMethod(const QUrl &sourceUrl, const QString &createUploadMethod, const QString &fileName = QString());

signals:
    void busyChanged();
    void progressChanged();
    void activeFileNameChanged();
    void statusTextChanged();

    void downloadAvailable(const QString &downloadId, const QString &fileName, qint64 size);
    void downloadFinished(const QString &downloadId, const QUrl &targetUrl);
    void downloadFailed(const QString &downloadId, const QString &errorString);
    void uploadFinished(const QString &downloadId, const QString &fileName, qint64 size);
    void uploadFailed(const QString &fileName, const QString &errorString);
    void errorOccurred(const QString &errorString);

private:
    enum TransferType {
        TransferTypeNone,
        TransferTypeDownload,
        TransferTypeUpload
    };

    enum PendingTransferCommand {
        PendingTransferCommandNone,
        PendingTransferCommandConnect,
        PendingTransferCommandRequestChunk,
        PendingTransferCommandUploadChunk,
        PendingTransferCommandFinishUpload
    };

    void setBusy(bool busy);
    void setActiveFileName(const QString &activeFileName);
    void setStatusText(const QString &statusText);
    void setProgress(qint64 bytesTransferred, qint64 totalBytes);
    void updateStatusText();

    void openTransferConnection();
    NymeaTransportInterface *createTransportForCurrentConnection() const;
    void cleanupTransport();
    void cleanupFiles();
    void resetTransferState();

    void sendTransferCommand(const QString &method, const QVariantMap &params, PendingTransferCommand command);
    void requestNextDownloadChunk();
    void uploadNextChunk();

    void finishDownload();
    void finishUpload(const QVariantMap &params);
    void failTransfer(const QString &errorString);

    QString localPathFromUrl(const QUrl &url) const;

private slots:
    void startDownloadReply(int commandId, const QVariantMap &params);
    void createUploadReply(int commandId, const QVariantMap &params);
    void notificationReceived(const QVariantMap &notification);

    void onClientConnectedChanged(bool connected);
    void onTransportConnected();
    void onTransportDisconnected();
    void onTransportError(QAbstractSocket::SocketError error);
    void onTransportSslErrors(const QList<QSslError> &errors);
    void onTransferDataAvailable(const QByteArray &data);

private:
    JsonRpcClient *m_client = nullptr;
    NymeaTransportInterface *m_transport = nullptr;

    TransferType m_transferType = TransferTypeNone;
    bool m_busy = false;
    QString m_activeFileName;
    QString m_statusText;
    qint64 m_bytesTransferred = 0;
    qint64 m_totalBytes = 0;

    QString m_downloadId;
    QUrl m_targetUrl;
    QUrl m_sourceUrl;
    QString m_createUploadMethod = QStringLiteral("Transfers.CreateUpload");
    QString m_transferId;
    QString m_transferToken;
    QByteArray m_receiveBuffer;
    int m_transferCommandId = 0;
    QHash<int, PendingTransferCommand> m_pendingTransferCommands;

    QScopedPointer<QFile> m_outputFile;
    QScopedPointer<QFile> m_inputFile;
};

#endif // TRANSFERSMANAGER_H
