#ifndef INTERFACE_H
#define INTERFACE_H

#include <QObject>

class EventTypes;
class StateTypes;
class ActionTypes;

class Interface : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString name READ name CONSTANT)
    Q_PROPERTY(QString displayName READ displayName CONSTANT)
    Q_PROPERTY(EventTypes* eventTypes READ eventTypes CONSTANT)
    Q_PROPERTY(StateTypes* stateTypes READ stateTypes CONSTANT)
    Q_PROPERTY(ActionTypes* actionTypes READ actionTypes CONSTANT)

public:
    explicit Interface(const QString &name, const QString &displayName, QObject *parent = nullptr);

    QString name() const;
    QString displayName() const;
    EventTypes* eventTypes() const;
    StateTypes* stateTypes() const;
    ActionTypes* actionTypes() const;

private:
    QString m_name;
    QString m_displayName;
    EventTypes* m_eventTypes = nullptr;
    StateTypes* m_stateTypes = nullptr;
    ActionTypes* m_actionTypes = nullptr;
};

#endif // INTERFACE_H
