#ifndef APPLOGCONTROLLER_H
#define APPLOGCONTROLLER_H

#include <QObject>
#include <QFile>
#include <QQmlEngine>

class AppLogController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool canWriteLogs READ canWriteLogs CONSTANT)
    Q_PROPERTY(bool enabled READ enabled WRITE setEnabled NOTIFY enabledChanged)
    Q_PROPERTY(QByteArray content READ content NOTIFY contentChanged)

public:
    static QObject* appLogControllerProvider(QQmlEngine *engine, QJSEngine *scriptEngine);
    static AppLogController* instance();

    bool canWriteLogs() const;

    bool enabled() const;
    void setEnabled(bool enabled);

    QByteArray content();

signals:
    void enabledChanged();
    void contentChanged();
    void contentAdded(const QByteArray &newContent);

private:
    explicit AppLogController(QObject *parent = nullptr);
    static QtMessageHandler s_oldLogMessageHandler;
    static void logMessageHandler(QtMsgType type, const QMessageLogContext &context, const QString &message);

    void activate();
    void deactivate();

    QFile m_logFile;
    QByteArray m_buffer;
};

#endif // APPLOGCONTROLLER_H
