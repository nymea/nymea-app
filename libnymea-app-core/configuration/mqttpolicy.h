#ifndef MQTTPOLICY_H
#define MQTTPOLICY_H

#include <QObject>

class MqttPolicy : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString clientId READ clientId WRITE setClientId NOTIFY clientIdChanged)
    Q_PROPERTY(QString username READ username WRITE setUsername NOTIFY usernameChanged)
    Q_PROPERTY(QString password READ password WRITE setPassword NOTIFY passwordChanged)
    Q_PROPERTY(QStringList allowedPublishTopicFilters READ allowedPublishTopicFilters WRITE setAllowedPublishTopicFilters NOTIFY allowedPublishTopicFiltersChanged)
    Q_PROPERTY(QStringList allowedSubscribeTopicFilters READ allowedSubscribeTopicFilters WRITE setAllowedSubscribeTopicFilters NOTIFY allowedSubscribeTopicFiltersChanged)

public:
    explicit MqttPolicy(const QString &clientId = QString(),
                        const QString &username = QString(),
                        const QString &password = QString(),
                        const QStringList &allowedPublishTopicFilters = QStringList(),
                        const QStringList &allowedSubscribeTopicFilters = QStringList(),
                        QObject *parent = nullptr);

    QString clientId() const;
    void setClientId(const QString &clientId);

    QString username() const;
    void setUsername(const QString &username);

    QString password() const;
    void setPassword(const QString &password);

    QStringList allowedPublishTopicFilters() const;
    void setAllowedPublishTopicFilters(const QStringList &allowedPublishTopicFilters);

    QStringList allowedSubscribeTopicFilters() const;
    void setAllowedSubscribeTopicFilters(const QStringList &allowedSubscribeTopicFilters);

    Q_INVOKABLE MqttPolicy* clone();
signals:
    void clientIdChanged();
    void usernameChanged();
    void passwordChanged();
    void allowedPublishTopicFiltersChanged();
    void allowedSubscribeTopicFiltersChanged();

private:
    QString m_clientId;
    QString m_username;
    QString m_password;
    QStringList m_allowedPublishTopicFilters;
    QStringList m_allowedSubscribeTopicFilters;
};

#endif // MQTTPOLICY_H
