#ifndef RULEACTIONPARAMS_H
#define RULEACTIONPARAMS_H

#include <QAbstractListModel>

class RuleActionParam;

class RuleActionParams : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
public:
    enum Roles {
        RoleParamTypeId,
        RoleValue,
        RoleEventTypeId,
        RoleEventParamTypeId
    };
    Q_ENUM(Roles)

    explicit RuleActionParams(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    void addRuleActionParam(RuleActionParam* ruleActionParam);

    Q_INVOKABLE void setRuleActionParam(const QString &paramTypeId, const QVariant &value);
    Q_INVOKABLE void setRuleActionParamByName(const QString &paramName, const QVariant &value);
    Q_INVOKABLE void setRuleActionParamEvent(const QString &paramTypeId, const QString &eventTypeId, const QString &eventParamTypeId);
    Q_INVOKABLE void setRuleActionParamState(const QString &paramTypeId, const QString &stateDeviceId, const QString &stateTypeId);

    Q_INVOKABLE RuleActionParam* get(int index) const;

    bool operator==(RuleActionParams *other) const;

signals:
    void countChanged();

private:
    QList<RuleActionParam*> m_list;
};

#endif // RULEACTIONPARAMS_H
