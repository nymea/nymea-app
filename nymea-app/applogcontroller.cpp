#include "applogcontroller.h"

#include <QStandardPaths>
#include <QDebug>
#include <QSettings>
#include <QClipboard>
#include <QGuiApplication>

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

    QString fileName = QStandardPaths::writableLocation(QStandardPaths::CacheLocation) + "/nymea-app.log";
    m_logFile.setFileName(fileName);

    if (QFile::exists(fileName)) {
        if (QFile::exists(fileName + ".old")) {
            QFile::remove(fileName + ".old");
        }
        QFile::rename(fileName, fileName + ".old");
    }

    if (!m_logFile.open(QFile::ReadWrite | QFile::Truncate)) {
        qDebug() << "Cannot open logfile for writing";
        return;
    }

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
