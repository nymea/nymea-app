#ifndef RULEACTIONPARAM_H
#define RULEACTIONPARAM_H

#include <QObject>
#include <QUuid>
#include <QVariant>

#include "param.h"

class RuleActionParam : public Param
{
    Q_OBJECT
    Q_PROPERTY(QString paramName READ paramName WRITE setParamName NOTIFY paramNameChanged)
    Q_PROPERTY(QString eventTypeId READ eventTypeId WRITE setEventTypeId NOTIFY eventTypeIdChanged)
    Q_PROPERTY(QString eventParamTypeId READ eventParamTypeId WRITE setEventParamTypeId NOTIFY eventParamTypeIdChanged)
public:
    explicit RuleActionParam(const QString &paramName, const QVariant &value, QObject *parent = nullptr);
    explicit RuleActionParam(QObject *parent = nullptr);

    QString paramName() const;
    void setParamName(const QString &paramName);

    QString eventTypeId() const;
    void setEventTypeId(const QString &eventTypeId);

    QString eventParamTypeId() const;
    void setEventParamTypeId(const QString &eventParamTypeId);

    RuleActionParam* clone() const;
    bool operator==(RuleActionParam *other) const;
signals:
    void paramNameChanged();
    void eventTypeIdChanged();
    void eventParamTypeIdChanged();

protected:
    QString m_paramName;
    QString m_eventTypeId;
    QString m_eventParamTypeId;
};

#endif // RULEACTIONPARAM_H
