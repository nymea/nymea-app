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

#include "applogcontroller.h"

#include <QStandardPaths>
#include <QDebug>
#include <QSettings>
#include <QClipboard>
#include <QGuiApplication>
#include <QDir>
#include <QMutexLocker>

QtMessageHandler AppLogController::s_oldLogMessageHandler = nullptr;


QObject *AppLogController::appLogControllerProvider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)
    return instance();
}

AppLogController *AppLogController::instance()
{
    static AppLogController* thiz = nullptr;
    if (!thiz) {
        thiz = new AppLogController();
    }
    return thiz;
}

AppLogController::AppLogController(QObject *parent) : QAbstractListModel(parent)
{

    QString path = QStandardPaths::writableLocation(QStandardPaths::CacheLocation);
    QString fileName = path + "/nymea-app.log";
    m_logFile.setFileName(fileName);

    if (QFile::exists(fileName)) {
        if (QFile::exists(fileName + ".old")) {
            QFile::remove(fileName + ".old");
        }
        QFile::rename(fileName, fileName + ".old");
        QFile oldFile(fileName + ".old");
        if (oldFile.open(QFile::ReadOnly)) {
            m_buffer.append(QString(oldFile.readAll()).split('\n'));
            for (int i = 0; i < m_buffer.count(); i++) {
                m_types.append(TypeInfo);
            }
            m_types.append(TypeWarning);
            m_buffer.append("**** App restart ****");
            oldFile.close();
        }
    }
    QDir dir(path);
    if (!dir.exists()) {
        if (!dir.mkpath(path)) {
            qWarning() << "Cannot create cache location. Logging will not work.";
            return;
        }
    }

    if (!m_logFile.open(QFile::ReadWrite | QFile::Truncate)) {
        qWarning() << "Cannot open logfile for writing.";
        return;
    }
    qDebug() << "App log opened at" << fileName;

    if (enabled()) {
        activate();
    }
}

bool AppLogController::canWriteLogs() const
{
    return m_logFile.isOpen();
}

bool AppLogController::enabled() const
{
    QSettings settings;
    return settings.value("AppLoggingEnabled", false).toBool();
}

void AppLogController::setEnabled(bool enabled)
{
    if (enabled == this->enabled()) {
        return;
    }

    if (enabled) {
        if (!canWriteLogs()) {
            qWarning() << "Cannot write log file. Not enabling logging.";
            return;
        }
        activate();
    } else {
        deactivate();
    }
    QSettings settings;
    settings.setValue("AppLoggingEnabled", enabled);

    emit enabledChanged();

}

int AppLogController::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_buffer.count();
}

QVariant AppLogController::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case RoleText:
        return m_buffer.at(index.row());
    case RoleType:
        return m_types.at(index.row());
    }
    return QVariant();
}

QHash<int, QByteArray> AppLogController::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleText, "text");
    roles.insert(RoleType, "type");
    return roles;
}

void AppLogController::toClipboard()
{
    m_logFile.seek(0);
    QByteArray completeLog = m_logFile.readAll();
    QGuiApplication::clipboard()->setText(completeLog);
}

void AppLogController::logMessageHandler(QtMsgType type, const QMessageLogContext &context, const QString &message)
{
    s_oldLogMessageHandler(type, context, message);
    instance()->append(message, type == QtWarningMsg ? TypeWarning : TypeInfo);
}

void AppLogController::append(const QString &message, AppLogController::Type type)
{
    QMutexLocker locker(&m_mutex);
    QString finalMessage = message + "\n";
    m_logFile.write(finalMessage.toUtf8());
    m_logFile.flush();

    beginInsertRows(QModelIndex(), m_buffer.count(), m_buffer.count());
    m_buffer.append(message);
    m_types.append(type);
    endInsertRows();

    int maxEntries = 1024;
    if (m_buffer.size() > maxEntries) {
        beginRemoveRows(QModelIndex(), 0, 0);
        m_buffer.removeFirst();
        m_types.removeFirst();
        endRemoveRows();
    }
}

void AppLogController::activate()
{
    qDebug() << "Activating log file writing to" << m_logFile.fileName();

    s_oldLogMessageHandler = qInstallMessageHandler(&logMessageHandler);
}

void AppLogController::deactivate()
{
    qInstallMessageHandler(s_oldLogMessageHandler);
    s_oldLogMessageHandler = nullptr;

}
