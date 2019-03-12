#ifndef APPLOGCONTROLLER_H
#define APPLOGCONTROLLER_H

#include <QObject>
#include <QFile>
#include <QQmlEngine>
#include <QAbstractListModel>

class AppLogController : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(bool canWriteLogs READ canWriteLogs CONSTANT)
    Q_PROPERTY(bool enabled READ enabled WRITE setEnabled NOTIFY enabledChanged)

public:
    enum Type {
        TypeInfo,
        TypeWarning
    };
    Q_ENUM(Type)

    enum Roles {
        RoleText,
        RoleType
    };
    Q_ENUM(Roles)

    static QObject* appLogControllerProvider(QQmlEngine *engine, QJSEngine *scriptEngine);
    static AppLogController* instance();

    bool canWriteLogs() const;

    bool enabled() const;
    void setEnabled(bool enabled);

    int rowCount(const QModelIndex &parent) const override;
    QVariant data(const QModelIndex &parent, int role) const override;
    QHash<int, QByteArray> roleNames() const override;


    Q_INVOKABLE void toClipboard();

signals:
    void enabledChanged();

private:
    explicit AppLogController(QObject *parent = nullptr);
    static QtMessageHandler s_oldLogMessageHandler;
    static void logMessageHandler(QtMsgType type, const QMessageLogContext &context, const QString &message);

    void append(const QString &message, Type type = TypeInfo);

    void activate();
    void deactivate();

    QFile m_logFile;
    QStringList m_buffer;
    QList<Type> m_types;
};

#endif // APPLOGCONTROLLER_H
