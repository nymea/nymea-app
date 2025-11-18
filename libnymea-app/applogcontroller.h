// SPDX-License-Identifier: LGPL-3.0-or-later

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright (C) 2013 - 2024, nymea GmbH
* Copyright (C) 2024 - 2025, chargebyte austria GmbH
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

#ifndef APPLOGCONTROLLER_H
#define APPLOGCONTROLLER_H

#include <QObject>
#include <QFile>
#include <QQmlEngine>
#include <QAbstractListModel>
#include <QMutex>
#include <QDateTime>

class LogMessages;
class LoggingCategories;

class AppLogController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool enabled READ enabled WRITE setEnabled NOTIFY enabledChanged)

    Q_PROPERTY(LoggingCategories* loggingCategories READ loggingCategories CONSTANT)

public:
    // Note: QtMsgType is sorted in a way that we can't compare for >= etc
    enum LogLevel {
        LogLevelCritical = 0,
        LogLevelWarning = 1,
        LogLevelInfo = 2,
        LogLevelDebug = 3
    };
    Q_ENUM(LogLevel)
    static LogLevel qtMsgTypeToLogLevel(QtMsgType msgType);
    static QtMsgType logLevelToQtMsgType(LogLevel logLevel);

    static QObject* appLogControllerProvider(QQmlEngine *engine, QJSEngine *scriptEngine);
    static AppLogController* instance();

    bool enabled() const;
    void setEnabled(bool enabled);

    LoggingCategories* loggingCategories() const;
    LogLevel logLevel(const QString &category) const;
    Q_INVOKABLE void setLogLevel(const QString &category, LogLevel logLevel);

    Q_INVOKABLE QString logPath() const;
    Q_INVOKABLE QString currentLogFile() const;
    Q_INVOKABLE QStringList logFiles() const;

    Q_INVOKABLE QString exportLogs();

signals:
    void enabledChanged();
    void logToModelChanged();

    void categoryChanged(const QString &category, LogLevel level);
    void messageAdded(const QDateTime &timestamp, const QString &category, const QString &message, LogLevel level);

private:
    explicit AppLogController(QObject *parent = nullptr);

    static QtMessageHandler s_oldLogMessageHandler;
    static void logMessageHandler(QtMsgType type, const QMessageLogContext &context, const QString &message);

    Q_INVOKABLE void append(const QString &category, const QString &message, AppLogController::LogLevel level);

    void updateFilters();
    void openLogFile();

    QHash<QString, LogLevel> m_logLevels;

    QMutex m_mutex;
    QFile m_logFile;
    LoggingCategories *m_loggingCategories = nullptr;
};
Q_DECLARE_METATYPE(AppLogController::LogLevel)

class LogMessages: public QAbstractListModel
{
    Q_OBJECT

public:
    enum Roles {
        RoleTimestamp,
        RoleCategory,
        RoleMessage,
        RoleLevel,
        RoleText
    };
    Q_ENUM(Roles)

    struct LogMessage {
        QDateTime timestamp;
        QString category;
        QString message;
        AppLogController::LogLevel level;
    };

    LogMessages(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

private slots:
    void append(const QDateTime &timestamp, const QString &category, const QString &message, AppLogController::LogLevel level);

private:
    QList<LogMessage> m_messages;
};

class LoggingCategories: public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount CONSTANT)

public:
    enum Roles {
        RoleName,
        RoleLevel
    };
    Q_ENUM(Roles)

    LoggingCategories(AppLogController *parent);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE QVariant data(int index, const QString &role);

private:
    AppLogController *m_controller = nullptr;
};

#endif // APPLOGCONTROLLER_H
