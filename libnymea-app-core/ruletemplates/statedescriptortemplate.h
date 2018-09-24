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
    Q_PROPERTY(SelectionMode selectionMode READ selectionMode CONSTANT)
    Q_PROPERTY(ValueOperator valueOperator READ valueOperator CONSTANT)
    Q_PROPERTY(QVariant value READ value CONSTANT)

public:
    enum SelectionMode {
        SelectionModeAny,
        SelectionModeDevice,
        SelectionModeInterface,
    };
    Q_ENUM(SelectionMode)
    enum ValueOperator {
        ValueOperatorEquals,
        ValueOperatorNotEquals,
        ValueOperatorLess,
        ValueOperatorGreater,
        ValueOperatorLessOrEqual,
        ValueOperatorGreaterOrEqual
    };
    Q_ENUM(ValueOperator)

    explicit StateDescriptorTemplate(const QString &interfaceName, const QString &interfaceState, int selectionId, SelectionMode selectionMode, ValueOperator valueOperator = ValueOperatorEquals, const QVariant &value = QVariant(), QObject *parent = nullptr);

    QString interfaceName() const;
    QString interfaceState() const;
    int selectionId() const;
    SelectionMode selectionMode() const;
    ValueOperator valueOperator() const;
    QVariant value() const;

private:
    QString m_interfaceName;
    QString m_interfaceState;
    int m_selectionId = 0;
    SelectionMode m_selectionMode = SelectionModeAny;
    ValueOperator m_valueOperator = ValueOperatorEquals;
    QVariant m_value;
};

#endif // STATEDESCRIPTORTEMPLATE_H
