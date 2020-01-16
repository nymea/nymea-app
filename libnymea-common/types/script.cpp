#include "script.h"

Script::Script(const QUuid &id, QObject *parent):
    QObject(parent),
    m_id(id)
{

}

QUuid Script::id() const
{
    return m_id;
}

QString Script::name() const
{
    return m_name;
}

void Script::setName(const QString &name)
{
    if (m_name != name) {
        m_name = name;
        emit nameChanged();
    }
}
