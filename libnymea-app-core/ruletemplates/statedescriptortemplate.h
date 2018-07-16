#ifndef STATEDESCRIPTORTEMPLATE_H
#define STATEDESCRIPTORTEMPLATE_H

#include <QObject>
#include <QVariant>

class StateDescriptorTemplate : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString interfaceName READ interfaceName CONSTANT)
    Q_PROPERTY(QString interfaceState READ interfaceState CONSTANT)
    Q_PROPERTY(int selectionId READ selectionId CONSTANT)
    Q_PROPERTY(ValueOperator valueOperator READ valueOperator CONSTANT)
    Q_PROPERTY(QVariant value READ value CONSTANT)

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

    explicit StateDescriptorTemplate(const QString &interfaceName, const QString &interfaceState, int selectionId, ValueOperator valueOperator = ValueOperatorEquals, const QVariant &value = QVariant(), QObject *parent = nullptr);

    QString interfaceName() const;
    QString interfaceState() const;
    int selectionId() const;
    ValueOperator valueOperator() const;
    QVariant value() const;

private:
    QString m_interfaceName;
    QString m_interfaceState;
    ValueOperator m_valueOperator = ValueOperatorEquals;
    QVariant m_value;
    int m_selectionId = 0;
};

#endif // STATEDESCRIPTORTEMPLATE_H
