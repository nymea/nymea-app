#ifndef STATEDESCRIPTOR_H
#define STATEDESCRIPTOR_H

#include <QObject>
#include <QUuid>
#include <QVariant>

class StateDescriptor : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUuid deviceId READ deviceId WRITE setDeviceId NOTIFY deviceIdChanged)
    Q_PROPERTY(QUuid stateTypeId READ stateTypeId WRITE setStateTypeId NOTIFY stateTypeIdChanged)
    Q_PROPERTY(QString interfaceName READ interfaceName WRITE setInterfaceName NOTIFY interfaceNameChanged)
    Q_PROPERTY(QString interfaceState READ interfaceState WRITE setInterfaceState NOTIFY interfaceStateChanged)
    Q_PROPERTY(ValueOperator valueOperator READ valueOperator WRITE setValueOperator NOTIFY valueOperatorChanged)
    Q_PROPERTY(QVariant value READ value WRITE setValue NOTIFY valueChanged)

public:
    enum ValueOperator {
        ValueOperatorEquals,
        ValueOperatorNotEquals,
        ValueOperatorLess,
        ValueOperatorGreater,
        ValueOperatorLessOrEqual,
        ValueOperatorGreaterOrEqual
    };
    Q_ENUM(ValueOperator)

    explicit StateDescriptor(const QUuid &deviceId, const QUuid &stateTypeId, ValueOperator valueOperator, const QVariant &value, QObject *parent = nullptr);
    explicit StateDescriptor(const QString &interfaceName, const QString &interfaceState, ValueOperator valueOperator, const QVariant &value, QObject *parent = nullptr);
    StateDescriptor(QObject *parent = nullptr);

    QUuid deviceId() const;
    void setDeviceId(const QUuid &deviceId);

    QUuid stateTypeId() const;
    void setStateTypeId(const QUuid &stateTypeId);

    QString interfaceName() const;
    void setInterfaceName(const QString &interfaceName);

    QString interfaceState() const;
    void setInterfaceState(const QString &interfaceState);

    ValueOperator valueOperator() const;
    void setValueOperator(ValueOperator valueOperator);

    QVariant value() const;
    void setValue(const QVariant &value);

    StateDescriptor* clone() const;

signals:
    void deviceIdChanged();
    void stateTypeIdChanged();
    void interfaceNameChanged();
    void interfaceStateChanged();
    void valueOperatorChanged();
    void valueChanged();

private:
    QUuid m_deviceId;
    QUuid m_stateTypeId;
    QString m_interfaceName;
    QString m_interfaceState;
    ValueOperator m_operator = ValueOperatorEquals;
    QVariant m_value;
};

#endif // STATEDESCRIPTOR_H
