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
    Q_PROPERTY(QString eventTypeId READ eventTypeId WRITE setEventTypeId NOTIFY eventTypeIdChanged)
    Q_PROPERTY(QString eventParamTypeId READ eventParamTypeId WRITE setEventParamTypeId NOTIFY eventParamTypeIdChanged)
public:
    explicit RuleActionParam(QObject *parent = nullptr);

    QUuid paramTypeId() const;
    void setParamTypeId(const QUuid &paramTypeId);

    QVariant value() const;
    void setValue(const QVariant &value);

    QString eventTypeId() const;
    void setEventTypeId(const QString &eventTypeId);

    QString eventParamTypeId() const;
    void setEventParamTypeId(const QString &eventParamTypeId);

    RuleActionParam* clone() const;
signals:
    void paramTypeIdChanged();
    void valueChanged();
    void eventTypeIdChanged();
    void eventParamTypeIdChanged();


private:
    QUuid m_paramTypeId;
    QVariant m_value;
    QString m_eventTypeId;
    QString m_eventParamTypeId;
};

#endif // RULEACTIONPARAM_H
