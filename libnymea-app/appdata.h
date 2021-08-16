#ifndef APPDATA_H
#define APPDATA_H

#include <QQmlParserStatus>
#include <QTimer>
#include <QHash>

#include "engine.h"

class AppData : public QObject, public QQmlParserStatus
{
    Q_OBJECT
    Q_INTERFACES(QQmlParserStatus)
    Q_PROPERTY(Engine *engine READ engine WRITE setEngine NOTIFY engineChanged)
    Q_PROPERTY(QString group READ group WRITE setGroup NOTIFY groupChanged)

public:
    explicit AppData(QObject *parent = nullptr);
    ~AppData() override;

    void classBegin() override;
    void componentComplete() override;

    Engine *engine() const;
    void setEngine(Engine *engine);

    QString group() const;
    void setGroup(const QString &group);

signals:
    void engineChanged();
    void groupChanged();

private slots:
    void load();
    void store();

    void onPropertyChanged();

    void appDataReceived(int commandId, const QVariantMap &params);
    void appDataWritten(int commandId, const QVariantMap &params);

    void notificationReceived(const QVariantMap &notification);
private:
    Engine *m_engine = nullptr;
    QTimer m_syncTimer;
    QString m_group;

    bool m_loopLock = false;
    QHash<int, QString> m_readRequests;

};

#endif // APPDATA_H
