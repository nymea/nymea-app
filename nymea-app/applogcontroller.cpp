#include "applogcontroller.h"

#include <QStandardPaths>
#include <QDebug>
#include <QSettings>

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

AppLogController::AppLogController(QObject *parent) : QObject(parent)
{

    QString fileName = QStandardPaths::writableLocation(QStandardPaths::CacheLocation) + "/nymea-app.log";
    m_logFile.setFileName(fileName);
    qDebug() << "App log file:" << fileName;

    if (!m_logFile.open(QFile::ReadWrite)) {
        qDebug() << "Cannot open logfile for writing";
        return;
    }

    qDebug() << "Logging is" << (enabled() ? "enabled" : "disabled");
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

QByteArray AppLogController::content()
{
    return m_buffer;
}

void AppLogController::logMessageHandler(QtMsgType type, const QMessageLogContext &context, const QString &message)
{
    s_oldLogMessageHandler(type, context, message);

    QString finalMessage = message + "\n";
    instance()->m_logFile.write(finalMessage.toUtf8());
    instance()->m_logFile.flush();
    instance()->m_buffer.append(finalMessage);

    int maxBuffer = 1024 * 1024;
    if (instance()->m_buffer.size() > maxBuffer) {
        instance()->m_buffer.remove(0, instance()->m_buffer.size() - maxBuffer);
    }
    emit instance()->contentChanged();
    emit instance()->contentAdded(finalMessage.toUtf8());
}

void AppLogController::activate()
{
    qDebug() << "Activating log file writing";
    s_oldLogMessageHandler = qInstallMessageHandler(&logMessageHandler);
}

void AppLogController::deactivate()
{
    qInstallMessageHandler(s_oldLogMessageHandler);
    s_oldLogMessageHandler = nullptr;

}
