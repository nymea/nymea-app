#ifndef MQTTPOLICIES_H
#define MQTTPOLICIES_H

#include <QObject>
#include <QAbstractListModel>

class MqttPolicy;

class MqttPolicies : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
public:
    enum Roles {
        RoleClientId,
        RoleUsername,
        RolePassword,
        RoleAllowedPublishTopicFilters,
        RoleAllowedSubscribeTopicFilters
    };

    explicit MqttPolicies(QObject *parent = nullptr);

    int rowCount(const QModelIndex &index = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    void addPolicy(MqttPolicy *policy);
    void removePolicy(MqttPolicy *policy);

    Q_INVOKABLE MqttPolicy* getPolicy(const QString &clientId) const;
    Q_INVOKABLE MqttPolicy* get(int index) const;

    void clear();
signals:
    void countChanged();

private:
    QList<MqttPolicy*> m_list;
};

#endif // MQTTPOLICIES_H
