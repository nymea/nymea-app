#include "newlogentry.h"

NewLogEntry::NewLogEntry(const QString &source, const QDateTime &timestamp, const QVariantMap &values, QObject *parent)
    : QObject{parent},
      m_source(source),
      m_timestamp(timestamp),
      m_values(values)
{

}

QString NewLogEntry::source() const
{
    return m_source;
}

QDateTime NewLogEntry::timestamp() const
{
    return m_timestamp;
}

QVariantMap NewLogEntry::values() const
{
    return m_values;
}
