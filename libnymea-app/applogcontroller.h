/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2020, nymea GmbH
* Contact: contact@nymea.io
*
* This file is part of nymea.
* This project including source code and documentation is protected by
* copyright law, and remains the property of nymea GmbH. All rights, including
* reproduction, publication, editing and translation, are reserved. The use of
* this project is subject to the terms of a license agreement to be concluded
* with nymea GmbH in accordance with the terms of use of nymea GmbH, available
* under https://nymea.io/license
*
* GNU General Public License Usage
* Alternatively, this project may be redistributed and/or modified under the
* terms of the GNU General Public License as published by the Free Software
* Foundation, GNU version 3. This project is distributed in the hope that it
* will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along with
* this project. If not, see <https://www.gnu.org/licenses/>.
*
* For any further details and any questions please contact us under
* contact@nymea.io or see our FAQ/Licensing Information on
* https://nymea.io/license/faq
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#ifndef APPLOGCONTROLLER_H
#define APPLOGCONTROLLER_H

#include <QObject>
#include <QFile>
#include <QQmlEngine>
#include <QAbstractListModel>
#include <QMutex>

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
    void messageAdded(const QString &category, const QString &message, LogLevel level);

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
        RoleCategory,
        RoleMessage,
        RoleLevel,
        RoleText
    };
    Q_ENUM(Roles)

    struct LogMessage {
        QString category;
        QString message;
        AppLogController::LogLevel level;
    };

    LogMessages(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    void append(const QString &category, const QString &message, AppLogController::LogLevel level);

private:
    QList<LogMessage> m_messages;
};

class LoggingCategories: public QAbstractListModel
{
    Q_OBJECT

public:
    enum Roles {
        RoleName,
        RoleLevel
    };
    Q_ENUM(Roles)

    LoggingCategories(AppLogController *parent);

    int rowCount(const QModelIndex &parent) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

private:
    AppLogController *m_controller = nullptr;
};

#endif // APPLOGCONTROLLER_H
