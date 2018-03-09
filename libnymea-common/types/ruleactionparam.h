#ifndef RULEACTIONPARAM_H
#define RULEACTIONPARAM_H

#include <QObject>
#include <QUuid>
#include <QVariant>

class RuleActionParam : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUuid paramTypeId READ paramTypeId NOTIFY paramTypeIdChanged)
    Q_PROPERTY(QVariant value READ value NOTIFY valueChanged)
public:
    explicit RuleActionParam(QObject *parent = nullptr);

    QUuid paramTypeId() const;
    void setParamTypeId(const QUuid &paramTypeId);

    QVariant value() const;
    void setValue(const QVariant &value);

    RuleActionParam* clone() const;
signals:
    void paramTypeIdChanged();
    void valueChanged();

private:
    QUuid m_paramTypeId;
    QVariant m_value;
};

#endif // RULEACTIONPARAM_H
