#include "tag.h"

#include <QDebug>

Tag::Tag(const QString &tagId, const QString &value, QObject *parent):
    QObject(parent),
    m_tagId(tagId),
    m_value(value)
{

}

QUuid Tag::deviceId() const
{
    return m_deviceId;
}

void Tag::setDeviceId(const QUuid &deviceId)
{
    m_deviceId = deviceId;
}

QUuid Tag::ruleId() const
{
    return m_ruleId;
}

void Tag::setRuleId(const QUuid &ruleId)
{
    m_ruleId = ruleId;
}

QString Tag::tagId() const
{
    return m_tagId;
}

QString Tag::value() const
{
    return m_value;
}

void Tag::setValue(const QString &value)
{
    if (m_value != value) {
        m_value = value;
        qDebug() << "tags value changed" << m_deviceId << m_tagId << value;
        emit valueChanged();
    }
}
